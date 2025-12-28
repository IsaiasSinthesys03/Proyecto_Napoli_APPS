-- ========================================
-- CORREGIR: get_driver_orders (con subquery)
-- ========================================
-- Error: column "o.created_at" must appear in the GROUP BY clause
-- Solución: Usar subquery igual que en get_available_orders
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
        'total_cents', o.total_cents,
        'status', o.status::text,
        'created_at', o.created_at::text,
        'delivered_at', o.delivered_at::text
      ) as order_data
      FROM orders o
      WHERE o.driver_id = p_driver_id
        AND (p_status IS NULL OR o.status::text = p_status)
      ORDER BY o.created_at DESC
    ) subquery
  );
END;
$$;
