-- ============================================================================
-- VERIFICACIÓN: Tabla de Categories
-- ============================================================================

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'categories'
ORDER BY ordinal_position;

-- Ver datos de ejemplo
SELECT * FROM categories LIMIT 3;
