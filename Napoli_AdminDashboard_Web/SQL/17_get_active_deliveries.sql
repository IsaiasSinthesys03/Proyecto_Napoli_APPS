-- ============================================================================
-- STORED PROCEDURE: get_active_deliveries
-- ============================================================================
-- Propósito: Obtener entregas activas con información de driver
-- Parámetros:
--   - p_restaurant_id: UUID del restaurante
-- Retorna: JSON array de entregas activas
-- ============================================================================

CREATE OR REPLACE FUNCTION get_active_deliveries(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_deliveries JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_active_deliveries called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;
  
  SELECT json_agg(
    json_build_object(
      'order_id', o.id,
      'driver_id', o.driver_id,
      'driver_name', d.name,
      'driver_phone', d.phone,
      'driver_vehicle_type', d.vehicle_type,
      'delivery_address', COALESCE(
        o.address_snapshot->>'street_address',
        o.address_snapshot->>'label',
        'Sin dirección'
      ),
      'customer_name', COALESCE(
        o.customer_snapshot->>'name',
        'Cliente'
      )
    )
  )
  INTO v_deliveries
  FROM orders o
  INNER JOIN drivers d ON o.driver_id = d.id
  WHERE o.restaurant_id = p_restaurant_id
    AND o.status = 'delivering'
    AND o.driver_id IS NOT NULL;
  
  RAISE NOTICE '✅ SUCCESS - Returning % active deliveries', json_array_length(COALESCE(v_deliveries, '[]'::json));
  
  RETURN COALESCE(v_deliveries, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_active_deliveries: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener entregas activas: %', SQLERRM;
END;
$$;

-- Comentario
COMMENT ON FUNCTION get_active_deliveries IS 'Obtiene lista de entregas activas con información del driver';
