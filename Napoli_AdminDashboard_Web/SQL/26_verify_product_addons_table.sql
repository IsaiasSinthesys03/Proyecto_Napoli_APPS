-- ============================================================================
-- VERIFICACIÓN: Tabla de relación product_addons
-- ============================================================================
-- Propósito: Verificar si existe tabla para asignar addons a productos
-- ============================================================================

-- 1. Verificar si existe la tabla product_addons
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'product_addons'
) as table_exists;

-- 2. Si existe, ver su estructura
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'product_addons'
ORDER BY ordinal_position;

-- 3. Ver constraints
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'product_addons'
ORDER BY tc.constraint_type;

-- 4. Ver datos de ejemplo
SELECT * FROM product_addons LIMIT 5;
