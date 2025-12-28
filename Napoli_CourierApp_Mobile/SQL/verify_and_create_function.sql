-- ========================================
-- PASO 1: VERIFICAR SI LA FUNCIÓN EXISTE
-- ========================================

SELECT COUNT(*) as function_count
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'get_available_orders'
  AND n.nspname = 'public';

-- Si muestra 0, la función NO existe (correcto)
-- Si muestra 1 o más, la función SIGUE existiendo (problema)

-- ========================================
-- PASO 2: VER DEFINICIÓN ACTUAL (si existe)
-- ========================================

SELECT pg_get_functiondef(p.oid) as current_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'get_available_orders'
  AND n.nspname = 'public';

-- ========================================
-- PASO 3: CREAR FUNCIÓN NUEVA
-- ========================================

CREATE OR REPLACE FUNCTION get_available_orders(
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
-- PASO 4: VERIFICAR QUE SE CREÓ
-- ========================================

SELECT pg_get_functiondef(p.oid) as new_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'get_available_orders'
  AND n.nspname = 'public';

-- ========================================
-- PASO 5: PROBAR LA FUNCIÓN
-- ========================================

SELECT get_available_orders('06a5284c-0ef8-4efe-a882-ce1fc8319452'::uuid);
