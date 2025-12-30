-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA: Tablas de Orders
-- ============================================================================
-- Propósito: Verificar estructura de tablas de órdenes antes de crear SPs
-- Autor: AI Assistant
-- Fecha: 2024-12-28
-- ============================================================================

-- 1. Verificar estructura de la tabla orders
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'orders'
ORDER BY ordinal_position;

-- 2. Ver ejemplo de datos de orders
SELECT * FROM orders LIMIT 2;

-- 3. Verificar estructura de order_items
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'order_items'
ORDER BY ordinal_position;

-- 4. Ver ejemplo de order_items
SELECT * FROM order_items LIMIT 3;

-- 5. Verificar ENUM de order status
SELECT 
    enumlabel 
FROM pg_enum 
WHERE enumtypid = (
    SELECT oid 
    FROM pg_type 
    WHERE typname = 'order_status'
);

-- 6. Verificar constraints y foreign keys
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name IN ('orders', 'order_items')
ORDER BY tc.table_name, tc.constraint_type;
