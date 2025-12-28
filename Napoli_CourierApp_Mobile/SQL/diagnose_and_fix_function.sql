-- ========================================
-- DIAGNÓSTICO: Verificar todas las versiones de get_available_orders
-- ========================================

-- Ver TODAS las versiones de la función
SELECT 
  routine_name,
  routine_type,
  data_type,
  type_udt_name,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'get_available_orders';

-- Ver los parámetros de cada versión
SELECT 
  r.routine_name,
  p.parameter_name,
  p.data_type,
  p.parameter_mode
FROM information_schema.routines r
LEFT JOIN information_schema.parameters p 
  ON r.specific_name = p.specific_name
WHERE r.routine_name = 'get_available_orders'
ORDER BY r.routine_name, p.ordinal_position;

-- ========================================
-- SOLUCIÓN: Eliminar TODAS las versiones
-- ========================================

-- Eliminar todas las versiones posibles
DROP FUNCTION IF EXISTS get_available_orders(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_available_orders(TEXT) CASCADE;
DROP FUNCTION IF EXISTS get_available_orders() CASCADE;

-- Crear la función correcta
CREATE FUNCTION get_available_orders(
  p_restaurant_id UUID
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN (
    SELECT COALESCE(
      json_agg(
        json_build_object(
          'id', o.id::text,
          'order_number', o.order_number,
          'customer_id', o.customer_id::text,
          'customer_name', o.customer_snapshot->>'name',
          'customer_phone', o.customer_snapshot->>'phone',
          'delivery_address', o.address_snapshot->>'street',
          'delivery_latitude', (o.address_snapshot->>'lat')::float,
          'delivery_longitude', (o.address_snapshot->>'lng')::float,
          'total_cents', o.total_cents,
          'status', o.status::text,
          'created_at', o.created_at::text,
          'ready_at', o.ready_at::text,
          'estimated_delivery_minutes', 30
        )
      ),
      '[]'::json
    )
    FROM orders o
    WHERE o.restaurant_id = p_restaurant_id
      AND o.status = 'ready'
      AND o.driver_id IS NULL
    ORDER BY o.created_at ASC
  );
END;
$$;

-- ========================================
-- PROBAR DIRECTAMENTE
-- ========================================

-- Probar la función
SELECT get_available_orders('06a5284c-0ef8-4efe-a882-ce1fc8319452'::uuid);
