-- ============================================================================
-- STORED PROCEDURE: update_admin_order_status
-- ============================================================================
-- Propósito: Actualizar estado de una orden con timestamp correspondiente
-- Parámetros:
--   - p_order_id: ID de la orden
--   - p_status: Nuevo estado
--   - p_timestamp_field: Campo de timestamp a actualizar (opcional)
-- Retorna: void
-- Autor: AI Assistant
-- Fecha: 2024-12-28
-- ============================================================================

CREATE OR REPLACE FUNCTION update_admin_order_status(
  p_order_id UUID,
  p_status order_status,
  p_timestamp_field TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_sql TEXT;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_order_status called';
  RAISE NOTICE '📦 DATA - order_id: %, status: %, timestamp_field: %', 
    p_order_id, p_status, p_timestamp_field;
  
  -- Build dynamic SQL based on timestamp field
  IF p_timestamp_field IS NOT NULL THEN
    v_sql := format(
      'UPDATE orders SET status = $1, %I = NOW(), updated_at = NOW() WHERE id = $2',
      p_timestamp_field
    );
    EXECUTE v_sql USING p_status, p_order_id;
  ELSE
    UPDATE orders 
    SET status = p_status, updated_at = NOW() 
    WHERE id = p_order_id;
  END IF;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Order not found: %', p_order_id;
    RAISE EXCEPTION 'Orden no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Order status updated to: %', p_status;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_admin_order_status: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar estado de orden: %', SQLERRM;
END;
$$;

-- ============================================================================
-- STORED PROCEDURE: cancel_admin_order
-- ============================================================================
-- Propósito: Cancelar una orden con razón
-- Parámetros:
--   - p_order_id: ID de la orden
--   - p_reason: Razón de cancelación (opcional)
-- Retorna: void
-- ============================================================================

CREATE OR REPLACE FUNCTION cancel_admin_order(
  p_order_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - cancel_admin_order called for order: %', p_order_id;
  
  UPDATE orders
  SET 
    status = 'cancelled',
    cancelled_at = NOW(),
    cancellation_reason = p_reason,
    cancelled_by = 'restaurant',
    updated_at = NOW()
  WHERE id = p_order_id;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Order not found: %', p_order_id;
    RAISE EXCEPTION 'Orden no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Order cancelled';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in cancel_admin_order: %', SQLERRM;
    RAISE EXCEPTION 'Error al cancelar orden: %', SQLERRM;
END;
$$;

-- ============================================================================
-- STORED PROCEDURE: assign_driver_to_order
-- ============================================================================
-- Propósito: Asignar un repartidor a una orden
-- Parámetros:
--   - p_order_id: ID de la orden
--   - p_driver_id: ID del repartidor
-- Retorna: void
-- ============================================================================

CREATE OR REPLACE FUNCTION assign_driver_to_order(
  p_order_id UUID,
  p_driver_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - assign_driver_to_order called';
  RAISE NOTICE '📦 DATA - order_id: %, driver_id: %', p_order_id, p_driver_id;
  
  UPDATE orders
  SET 
    driver_id = p_driver_id,
    updated_at = NOW()
  WHERE id = p_order_id;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Order not found: %', p_order_id;
    RAISE EXCEPTION 'Orden no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Driver assigned to order';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in assign_driver_to_order: %', SQLERRM;
    RAISE EXCEPTION 'Error al asignar repartidor: %', SQLERRM;
END;
$$;

-- Comments
COMMENT ON FUNCTION update_admin_order_status(UUID, order_status, TEXT) IS 
'Actualiza el estado de una orden con timestamp opcional';

COMMENT ON FUNCTION cancel_admin_order(UUID, TEXT) IS 
'Cancela una orden con razón opcional';

COMMENT ON FUNCTION assign_driver_to_order(UUID, UUID) IS 
'Asigna un repartidor a una orden';
