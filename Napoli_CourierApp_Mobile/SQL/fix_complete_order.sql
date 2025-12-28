-- ========================================
-- CORREGIR: complete_order
-- ========================================
-- Error: null value in column "restaurant_id" violates not-null constraint
-- Solución: Obtener restaurant_id del pedido antes de insertar en driver_earnings
-- ========================================

CREATE OR REPLACE FUNCTION complete_order(
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
  v_restaurant_id UUID;
  v_driver_earnings_cents INT;
BEGIN
  -- Validar que el pedido pertenece al driver y está en delivering
  IF NOT EXISTS (
    SELECT 1 FROM orders 
    WHERE id = p_order_id 
      AND driver_id = p_driver_id
      AND status = 'delivering'
  ) THEN
    RAISE EXCEPTION 'Pedido no válido para completar';
  END IF;
  
  -- Obtener restaurant_id y earnings del pedido
  SELECT 
    restaurant_id,
    delivery_fee_cents
  INTO 
    v_restaurant_id,
    v_driver_earnings_cents
  FROM orders
  WHERE id = p_order_id;
  
  -- Actualizar pedido a delivered
  UPDATE orders
  SET 
    status = 'delivered',
    delivered_at = NOW()
  WHERE id = p_order_id;
  
  -- Registrar ganancia del driver
  INSERT INTO driver_earnings (
    id,
    driver_id,
    restaurant_id,
    order_id,
    amount_cents,
    created_at
  ) VALUES (
    gen_random_uuid(),
    p_driver_id,
    v_restaurant_id,
    p_order_id,
    v_driver_earnings_cents,
    NOW()
  );
  
  -- Actualizar total de ganancias del driver
  UPDATE drivers
  SET total_earnings_cents = COALESCE(total_earnings_cents, 0) + v_driver_earnings_cents
  WHERE id = p_driver_id;
  
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
    'picked_up_at', o.picked_up_at::text,
    'delivered_at', o.delivered_at::text
  ) INTO v_result
  FROM orders o
  WHERE o.id = p_order_id;
  
  RETURN v_result;
END;
$$;
