-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA: Tablas de Authentication
-- ============================================================================
-- Propósito: Verificar estructura de tablas antes de crear stored procedures
-- Autor: AI Assistant
-- Fecha: 2024-12-28
-- ============================================================================

-- 1. Verificar estructura de la tabla restaurants
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'restaurants'
ORDER BY ordinal_position;

-- 2. Ver ejemplo de datos de restaurants
SELECT * FROM restaurants LIMIT 3;

-- 3. Verificar estructura de la tabla restaurant_admins
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'restaurant_admins'
ORDER BY ordinal_position;

-- 4. Ver ejemplo de datos de restaurant_admins
SELECT * FROM restaurant_admins LIMIT 3;

-- 5. Verificar RLS policies en restaurants
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename IN ('restaurants', 'restaurant_admins')
ORDER BY tablename, policyname;

-- 6. Verificar constraints y foreign keys
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name IN ('restaurants', 'restaurant_admins')
ORDER BY tc.table_name, tc.constraint_type;

-- 7. Verificar índices
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename IN ('restaurants', 'restaurant_admins')
ORDER BY tablename, indexname;

-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================
-- 
-- CAMPOS ESPERADOS EN restaurants:
-- - id (uuid, PK)
-- - name (varchar, NOT NULL)
-- - slug (varchar, UNIQUE, NOT NULL)
-- - email (varchar)
-- - phone (varchar)
-- - logo_url (varchar)
-- - is_active (boolean, default true)
-- - created_at (timestamp)
-- - updated_at (timestamp)
--
-- CAMPOS ESPERADOS EN restaurant_admins:
-- - id (uuid, PK)
-- - restaurant_id (uuid, FK → restaurants.id, NOT NULL)
-- - name (varchar, NOT NULL)
-- - email (varchar, NOT NULL)
-- - phone (varchar)
-- - role (varchar, NOT NULL)
-- - is_primary (boolean, default false)
-- - created_at (timestamp)
--
-- ============================================================================
