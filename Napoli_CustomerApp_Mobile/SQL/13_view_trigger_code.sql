-- ============================================================================
-- VER CÓDIGO DE LOS TRIGGERS
-- ============================================================================

-- Ver el código del trigger que genera order_number
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'generate_order_number';

-- Ver el código del trigger de dashboard
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'update_restaurant_dashboard';

-- Ver el código de update_stats_on_order
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'update_stats_on_order';

-- Ver el código de log_order_status_change
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'log_order_status_change';

-- Ver todos los triggers en orders
SELECT 
    t.tgname AS trigger_name,
    p.proname AS function_name,
    pg_get_functiondef(p.oid) AS function_code
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'orders';
