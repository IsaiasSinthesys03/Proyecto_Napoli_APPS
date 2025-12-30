-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA: Tabla de Promotions
-- ============================================================================
-- Propósito: Verificar estructura de tabla promotions
-- ============================================================================

-- 1. Verificar estructura de la tabla promotions
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'promotions'
ORDER BY ordinal_position;

-- 2. Ver ejemplo de datos de promotions
SELECT * FROM promotions LIMIT 2;

-- 3. Verificar constraints y foreign keys
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'promotions'
ORDER BY tc.constraint_type;
