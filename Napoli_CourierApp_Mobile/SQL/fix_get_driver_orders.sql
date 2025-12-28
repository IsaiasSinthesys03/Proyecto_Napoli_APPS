-- ========================================
-- CORREGIR: get_driver_orders
-- ========================================
-- Error: operator does not exist: order_status = text
-- Solución: Cast explícito del parámetro a order_status
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
    SELECT json_agg(
      json_build_object(
        'id', o.id::text,
        'order_number', o.order_number,
        'customer_name', o.customer_snapshot->>'name',
        'delivery_address', o.address_snapshot->>'street',
        'total_cents', o.total_cents,
        'status', o.status::text,
        'created_at', o.created_at::text,
        'delivered_at', o.delivered_at::text
      )
    )
    FROM orders o
    WHERE o.driver_id = p_driver_id
      AND (p_status IS NULL OR o.status::text = p_status)
    ORDER BY o.created_at DESC
  );
END;
$$;

-- Verificar que se creó correctamente
SELECT routine_definition
FROM information_schema.routines
WHERE routine_name = 'get_driver_orders';
