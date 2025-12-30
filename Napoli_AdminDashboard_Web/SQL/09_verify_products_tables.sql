-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA: Tablas de Products
-- ============================================================================
-- Propósito: Verificar estructura de tablas de productos antes de crear SPs
-- Autor: AI Assistant
-- Fecha: 2024-12-29
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

-- 3. Verificar estructura de product_variants (si existe)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'product_variants'
ORDER BY ordinal_position;

-- 4. Ver ejemplo de product_variants
SELECT * FROM product_variants LIMIT 3;

-- 5. Verificar constraints y foreign keys
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name IN ('products', 'product_variants')
ORDER BY tc.table_name, tc.constraint_type;
