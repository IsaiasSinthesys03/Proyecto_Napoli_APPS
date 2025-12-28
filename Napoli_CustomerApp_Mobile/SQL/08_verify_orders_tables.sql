-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA DE TABLAS: Orders
-- ============================================================================
-- Propósito: Verificar estructura de tablas relacionadas con órdenes
-- Autor: AI Assistant
-- Fecha: 2024-12-26
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
SELECT * FROM orders LIMIT 1;

-- 3. Verificar estructura de la tabla order_items
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'order_items'
ORDER BY ordinal_position;

-- 4. Ver ejemplo de datos de order_items
SELECT * FROM order_items LIMIT 2;

-- 5. Verificar RLS policies en orders
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename IN ('orders', 'order_items')
ORDER BY tablename, policyname;
