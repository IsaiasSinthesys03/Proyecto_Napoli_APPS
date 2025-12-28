-- ========================================
-- CREAR: pickup_order (Confirmar Recogida)
-- ========================================
-- Para el botón "Confirmar Recogida"
-- Transición: accepted → delivering
-- ========================================

CREATE OR REPLACE FUNCTION pickup_order(
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
  -- Validar que el pedido pertenece al driver y está en status 'accepted'
  IF NOT EXISTS (
    SELECT 1 FROM orders 
    WHERE id = p_order_id 
      AND driver_id = p_driver_id
      AND status = 'accepted'
  ) THEN
    RAISE EXCEPTION 'Pedido no válido para confirmar recogida';
  END IF;
  
  -- Actualizar pedido a delivering
  UPDATE orders
  SET 
    status = 'delivering',
    picked_up_at = NOW()
  WHERE id = p_order_id;
  
  -- Retornar pedido actualizado
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
