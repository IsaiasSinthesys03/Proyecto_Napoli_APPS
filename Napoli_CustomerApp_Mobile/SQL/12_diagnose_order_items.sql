-- ============================================================================
-- DIAGNÓSTICO COMPLETO: Order Items
-- ============================================================================
-- Propósito: Examinar datos existentes en order_items para encontrar el problema
-- ============================================================================

-- 1. Ver TODOS los campos de order_items
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'order_items'
ORDER BY ordinal_position;

-- 2. Ver datos existentes en order_items (TODOS los campos)
SELECT * FROM order_items LIMIT 10;

-- 3. Buscar específicamente "TEST001" en order_items
SELECT * FROM order_items 
WHERE product_id::text LIKE '%TEST001%'
   OR product_name LIKE '%TEST001%'
   OR variant_id::text LIKE '%TEST001%'
   OR variant_name LIKE '%TEST001%';

-- 4. Ver estructura completa de orders
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'orders'
ORDER BY ordinal_position;

-- 5. Ver órdenes de prueba existentes
SELECT id, customer_id, status, created_at 
FROM orders 
ORDER BY created_at DESC 
LIMIT 5;

-- 6. Verificar si hay triggers o constraints que puedan estar causando el problema
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_table IN ('orders', 'order_items');

-- 7. Ver constraints de order_items
SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'order_items';
