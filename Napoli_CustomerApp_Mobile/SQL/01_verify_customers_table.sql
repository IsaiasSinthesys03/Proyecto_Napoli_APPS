-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA DE TABLA: customers
-- ============================================================================
-- Propósito: Verificar que la tabla customers existe y tiene la estructura correcta
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

-- 1. Verificar estructura de la tabla customers
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customers'
ORDER BY ordinal_position;

-- 2. Ver ejemplo de datos (si existen)
SELECT * FROM customers LIMIT 1;

-- 3. Verificar estructura de customer_addresses
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customer_addresses'
ORDER BY ordinal_position;

-- 4. Verificar estructura de customer_payment_methods
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customer_payment_methods'
ORDER BY ordinal_position;

-- 5. Verificar RLS policies en customers
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'customers';
