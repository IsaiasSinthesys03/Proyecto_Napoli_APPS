-- ========================================
-- CORREGIR: get_order_details
-- ========================================
-- Cambios:
-- 1. payment_type → payment_method
-- 2. subtotal_cents → total_price_cents (en order_items)
-- 3. special_instructions → notes (en order_items)
-- ========================================

CREATE OR REPLACE FUNCTION get_order_details(
  p_order_id UUID
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result json;
BEGIN
  SELECT json_build_object(
    'id', o.id::text,
    'order_number', o.order_number,
    'restaurant_id', o.restaurant_id::text,
    'customer', json_build_object(
      'id', o.customer_id::text,
      'name', o.customer_snapshot->>'name',
      'phone', o.customer_snapshot->>'phone',
      'email', o.customer_snapshot->>'email'
    ),
    'delivery_address', o.address_snapshot->>'street',
    'delivery_latitude', (o.address_snapshot->>'lat')::float,
    'delivery_longitude', (o.address_snapshot->>'lng')::float,
    'delivery_instructions', o.driver_notes,
    'subtotal_cents', o.subtotal_cents,
    'delivery_fee_cents', o.delivery_fee_cents,
    'tax_cents', o.tax_cents,
    'total_cents', o.total_cents,
    'payment_method', o.payment_method,
    'status', o.status,
    'created_at', o.created_at::text,
    'accepted_at', o.accepted_at::text,
    'ready_at', o.ready_at::text,
    'picked_up_at', o.picked_up_at::text,
    'delivered_at', o.delivered_at::text,
    'estimated_delivery_minutes', 30,
    'items', (
      SELECT json_agg(
        json_build_object(
          'id', oi.id::text,
          'product_name', oi.product_name,
          'quantity', oi.quantity,
          'unit_price_cents', oi.unit_price_cents,
          'total_price_cents', oi.total_price_cents,
          'notes', oi.notes
        )
      )
      FROM order_items oi
      WHERE oi.order_id = o.id
    )
  ) INTO v_result
  FROM orders o
  WHERE o.id = p_order_id;
  
  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Pedido no encontrado';
  END IF;
  
  RETURN v_result;
END;
$$;
