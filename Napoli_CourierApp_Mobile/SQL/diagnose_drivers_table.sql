-- ========================================
-- DIAGNÓSTICO: Estructura de tabla drivers
-- ========================================

-- Ver estructura de la tabla drivers
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'drivers'
ORDER BY ordinal_position;

-- Ver un driver de ejemplo para entender los datos
SELECT * FROM drivers LIMIT 1;

-- Ver configuraciones si existe tabla de settings
SELECT 
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name LIKE '%setting%' OR table_name LIKE '%config%';
