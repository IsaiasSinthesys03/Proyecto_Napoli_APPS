-- ========================================
-- PASO 1: ELIMINAR TODAS LAS VERSIONES
-- ========================================

DROP FUNCTION IF EXISTS get_available_orders(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_available_orders(TEXT) CASCADE;
DROP FUNCTION IF EXISTS get_available_orders() CASCADE;

-- ========================================
-- PASO 2: CREAR FUNCIÓN LIMPIA
-- ========================================

CREATE FUNCTION get_available_orders(
  p_restaurant_id UUID
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
        'customer_id', o.customer_id::text,
        'customer_name', o.customer_snapshot->>'name',
        'customer_phone', o.customer_snapshot->>'phone',
        'delivery_address', o.address_snapshot->>'street',
        'delivery_latitude', (o.address_snapshot->>'lat')::float,
        'delivery_longitude', (o.address_snapshot->>'lng')::float,
        'total_cents', o.total_cents,
        'status', o.status::text,
        'created_at', o.created_at::text,
        'ready_at', o.ready_at::text,
        'estimated_delivery_minutes', 30
      )
    )
    FROM orders o
    WHERE o.restaurant_id = p_restaurant_id
      AND o.status = 'ready'::order_status
      AND o.driver_id IS NULL
    ORDER BY o.created_at ASC
  );
END;
$$;

-- ========================================
-- ✅ LISTO - NO EJECUTAR NADA MÁS AQUÍ
-- ========================================
-- Ahora ejecuta create_test_order.sql
