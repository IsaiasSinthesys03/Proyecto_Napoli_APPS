-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA: Tabla de Addons
-- ============================================================================
-- Propósito: Verificar estructura de tabla addons antes de crear SPs
-- ============================================================================

-- 1. Verificar estructura de la tabla addons
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'addons'
ORDER BY ordinal_position;

-- 2. Ver ejemplo de datos de addons
SELECT * FROM addons LIMIT 2;

-- 3. Verificar constraints y foreign keys
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'addons'
ORDER BY tc.constraint_type;
