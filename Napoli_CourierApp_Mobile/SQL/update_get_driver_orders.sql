-- ========================================
-- ACTUALIZAR: get_driver_orders (con items y costos)
-- ========================================
-- Agregar items del pedido y desglose de costos
-- Mantener privacidad (sin teléfono ni dirección exacta)
-- ========================================

CREATE OR REPLACE FUNCTION get_driver_orders(
  p_driver_id UUID,
  p_status TEXT DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN (
    SELECT COALESCE(json_agg(order_data), '[]'::json)
    FROM (
      SELECT json_build_object(
        'id', o.id::text,
        'order_number', o.order_number,
        'customer_name', o.customer_snapshot->>'name',
        'delivery_address', o.address_snapshot->>'street',
        'subtotal_cents', o.subtotal_cents,
        'delivery_fee_cents', o.delivery_fee_cents,
        'tax_cents', o.tax_cents,
        'total_cents', o.total_cents,
        'status', o.status::text,
        'created_at', o.created_at::text,
        'delivered_at', o.delivered_at::text,
        'items', (
          SELECT COALESCE(json_agg(
            json_build_object(
              'id', oi.id::text,
              'product_name', oi.product_name,
              'quantity', oi.quantity,
              'unit_price_cents', oi.unit_price_cents,
              'total_price_cents', oi.total_price_cents,
              'notes', oi.notes
            )
          ), '[]'::json)
          FROM order_items oi
          WHERE oi.order_id = o.id
        )
      ) as order_data
      FROM orders o
      WHERE o.driver_id = p_driver_id
        AND (p_status IS NULL OR o.status::text = p_status)
      ORDER BY o.created_at DESC
    ) subquery
  );
END;
$$;
