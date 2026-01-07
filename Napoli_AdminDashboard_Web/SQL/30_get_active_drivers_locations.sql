-- ============================================================================
-- STORED PROCEDURE: get_active_drivers_locations
-- ============================================================================
-- Propósito: Obtener ubicaciones de conductores activos/online
-- Parámetros: Ninguno (retorna todos los conductores online)
-- Retorna: JSON array de ubicaciones de conductores
-- ============================================================================

CREATE OR REPLACE FUNCTION get_active_drivers_locations()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_locations JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_active_drivers_locations called';
  
  SELECT json_agg(
    json_build_object(
      'id', id,
      'name', name,
      'lat', current_latitude,
      'lng', current_longitude,
      'vehicle', vehicle_type,
      'busy', is_on_delivery,
      'last_upd', last_location_update
    )
  )
  INTO v_locations
  FROM drivers
  WHERE is_online = true
    AND current_latitude IS NOT NULL
    AND current_longitude IS NOT NULL
    AND status = 'active';
  
  RAISE NOTICE '✅ SUCCESS - Returning % active driver locations', json_array_length(COALESCE(v_locations, '[]'::json));
  
  RETURN COALESCE(v_locations, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_active_drivers_locations: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener ubicaciones de conductores: %', SQLERRM;
END;
$$;

-- Comentario
COMMENT ON FUNCTION get_active_drivers_locations IS 'Obtiene ubicaciones GPS de conductores activos y online';
