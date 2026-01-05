-- ============================================================================
-- STORED PROCEDURE: get_admin_drivers
-- ============================================================================
-- Propósito: Obtener lista de repartidores del restaurante
-- Parámetros:
--   - p_restaurant_id: UUID del restaurante
-- Retorna: JSON array de drivers
-- ============================================================================

CREATE OR REPLACE FUNCTION get_admin_drivers(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_drivers JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_drivers called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;
  
  SELECT json_agg(
    json_build_object(
      'id', id,
      'restaurant_id', restaurant_id,
      'name', name,
      'email', email,
      'phone', phone,
      'photo_url', photo_url,
      'vehicle_type', vehicle_type,
      'vehicle_brand', vehicle_brand,
      'vehicle_model', vehicle_model,
      'vehicle_color', vehicle_color,
      'vehicle_year', vehicle_year,
      'license_plate', license_plate,
      'id_document_url', id_document_url,
      'license_url', license_url,
      'vehicle_registration_url', vehicle_registration_url,
      'insurance_url', insurance_url,
      'status', status,
      'is_online', is_online,
      'is_on_delivery', is_on_delivery,
      'current_latitude', current_latitude,
      'current_longitude', current_longitude,
      'last_location_update', last_location_update,
      'notifications_enabled', notifications_enabled,
      'email_notifications_enabled', email_notifications_enabled,
      'preferred_language', preferred_language,
      'fcm_token', fcm_token,
      'max_concurrent_orders', max_concurrent_orders,
      'total_deliveries', total_deliveries,
      'total_earnings_cents', total_earnings_cents,
      'rating_sum', rating_sum,
      'rating_count', rating_count,
      'average_rating', average_rating,
      'average_delivery_minutes', average_delivery_minutes,
      'created_at', created_at,
      'updated_at', updated_at,
      'approved_at', approved_at,
      'last_delivery_at', last_delivery_at
    )
    ORDER BY created_at DESC
  )
  INTO v_drivers
  FROM drivers
  WHERE restaurant_id = p_restaurant_id
    AND is_online = true
    AND status = 'active';
  
  RAISE NOTICE '✅ SUCCESS - Returning % online drivers', json_array_length(COALESCE(v_drivers, '[]'::json));
  
  RETURN COALESCE(v_drivers, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_drivers: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener repartidores: %', SQLERRM;
END;
$$;

-- Comentario
COMMENT ON FUNCTION get_admin_drivers IS 'Obtiene lista de repartidores del restaurante';
