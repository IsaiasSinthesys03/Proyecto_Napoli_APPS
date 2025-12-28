-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA DE TABLAS: Products
-- ============================================================================
-- Propósito: Verificar estructura de tablas relacionadas con productos
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

-- 1. Verificar estructura de la tabla products
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
ORDER BY ordinal_position;

-- 2. Ver ejemplo de datos de products
SELECT * FROM products LIMIT 2;

-- 3. Verificar estructura de la tabla categories
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'categories'
ORDER BY ordinal_position;

-- 4. Ver ejemplo de datos de categories
SELECT * FROM categories LIMIT 2;

-- 5. Verificar estructura de la tabla addons
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'addons'
ORDER BY ordinal_position;

-- 6. Ver ejemplo de datos de addons
SELECT * FROM addons LIMIT 2;

-- 7. Verificar estructura de la tabla product_addons (junction table)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'product_addons'
ORDER BY ordinal_position;

-- 8. Ver ejemplo de relación product_addons
SELECT * FROM product_addons LIMIT 5;

-- 9. Verificar RLS policies en products
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename IN ('products', 'categories', 'addons', 'product_addons');
