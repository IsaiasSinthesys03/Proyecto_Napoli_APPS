-- ============================================================================
-- STORED PROCEDURE: toggle_driver_online_status
-- ============================================================================
-- Propósito: Cambiar el estado online/offline de un repartidor
-- Parámetros:
--   - p_driver_id: UUID del repartidor
--   - p_is_online: Nuevo estado online (true/false)
-- Retorna: JSON con el estado actualizado
-- ============================================================================

CREATE OR REPLACE FUNCTION toggle_driver_online_status(
  p_driver_id UUID,
  p_is_online BOOLEAN
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - toggle_driver_online_status called';
  RAISE NOTICE '📦 DATA - driver_id: %, is_online: %', p_driver_id, p_is_online;
  
  -- Actualizar estado online del repartidor
  UPDATE drivers
  SET 
    is_online = p_is_online,
    updated_at = NOW()
  WHERE id = p_driver_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Repartidor no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Driver online status updated';
  
  -- Retornar resultado
  SELECT json_build_object(
    'success', true,
    'is_online', p_is_online
  )
  INTO v_result;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in toggle_driver_online_status: %', SQLERRM;
    RAISE EXCEPTION 'Error al cambiar estado online: %', SQLERRM;
END;
$$;

-- Comentario
COMMENT ON FUNCTION toggle_driver_online_status(UUID, BOOLEAN) IS 
'Cambia el estado online/offline de un repartidor';

-- Ejemplo de uso:
-- SELECT toggle_driver_online_status(
--   'driver-uuid',
--   true
-- );
