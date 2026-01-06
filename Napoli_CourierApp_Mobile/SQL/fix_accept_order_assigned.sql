-- ========================================
-- FIX: accept_order - Permitir aceptar pedidos asignados
-- ========================================
-- Problema: Solo permite aceptar pedidos sin driver (driver_id IS NULL)
-- Solución: Permitir aceptar si:
--   1. Pedido está ready y sin driver (caso original)
--   2. Pedido está ready y YA asignado al driver que intenta aceptar
-- ========================================

CREATE OR REPLACE FUNCTION accept_order(
  p_order_id UUID,
  p_driver_id UUID
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result json;
BEGIN
  -- Validar que el pedido existe y está disponible
  -- CASO 1: Pedido ready sin driver asignado
  -- CASO 2: Pedido ready YA asignado a este driver
  IF NOT EXISTS (
    SELECT 1 FROM orders 
    WHERE id = p_order_id 
      AND status = 'ready' 
      AND (driver_id IS NULL OR driver_id = p_driver_id)
  ) THEN
    RAISE EXCEPTION 'Pedido no disponible';
  END IF;
  
  -- Actualizar pedido
  UPDATE orders
  SET 
    driver_id = p_driver_id,
    status = 'accepted',
    accepted_at = NOW()
  WHERE id = p_order_id;
  
  -- Retornar pedido actualizado con TODOS los campos
  SELECT json_build_object(
    'id', o.id::text,
    'order_number', o.order_number,
    'customer_id', o.customer_id::text,
    'customer_name', o.customer_snapshot->>'name',
    'customer_phone', o.customer_snapshot->>'phone',
    'delivery_address', o.address_snapshot->>'street',
    'delivery_latitude', (o.address_snapshot->>'lat')::float,
    'delivery_longitude', (o.address_snapshot->>'lng')::float,
    'subtotal_cents', o.subtotal_cents,
    'delivery_fee_cents', o.delivery_fee_cents,
    'tax_cents', o.tax_cents,
    'total_cents', o.total_cents,
    'status', o.status::text,
    'created_at', o.created_at::text,
    'accepted_at', o.accepted_at::text,
    'picked_up_at', o.picked_up_at::text
  ) INTO v_result
  FROM orders o
  WHERE o.id = p_order_id;
  
  RETURN v_result;
END;
$$;
