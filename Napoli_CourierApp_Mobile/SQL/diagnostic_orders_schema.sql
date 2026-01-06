-- ============================================================================
-- DIAGNÓSTICO: Por qué no aparecen los pedidos disponibles
-- ============================================================================

-- 1. Ver estructura de la tabla ORDERS (especialmente customer_id y status)
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;

-- 2. Ver si existen Foreign Keys en la tabla ORDERS (vital para la query de la app)
SELECT
    tc.constraint_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'orders' AND tc.constraint_type = 'FOREIGN KEY';

-- 3. Ver si hay pedidos en estado 'ready' (disponibles)
SELECT 
  COUNT(*) as total_ready_orders,
  COUNT(*) FILTER (WHERE driver_id IS NULL) as ready_no_driver
FROM orders 
WHERE status = 'ready';

-- 4. Ver si existen pedidos recientes (últimas 24h)
SELECT id, order_number, status, driver_id, created_at 
FROM orders 
WHERE created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC
LIMIT 5;

-- 5. Examinar el Stored Procedure 'get_available_orders' (por si la app lo usa)
SELECT 
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'get_available_orders'
  AND routine_schema = 'public';

-- 6. Examinar el Stored Procedure 'get_order_details' (usado para detalles)
SELECT 
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'get_order_details'
  AND routine_schema = 'public';
