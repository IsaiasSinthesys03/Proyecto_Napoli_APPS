-- ========================================
-- FORZAR RECREACIÓN: get_available_orders
-- ========================================
-- Paso 1: ELIMINAR la función vieja completamente
-- Paso 2: CREAR la función nueva sin items_count
-- ========================================

-- PASO 1: Eliminar función vieja
DROP FUNCTION IF EXISTS get_available_orders(UUID);

-- PASO 2: Crear función nueva (SIN items_count)
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
      AND o.status = 'ready'
      AND o.driver_id IS NULL
    ORDER BY o.created_at ASC
  );
END;
$$;

-- ========================================
-- VERIFICAR QUE SE CREÓ CORRECTAMENTE
-- ========================================

-- Ver la definición de la función
SELECT routine_definition
FROM information_schema.routines
WHERE routine_name = 'get_available_orders';
