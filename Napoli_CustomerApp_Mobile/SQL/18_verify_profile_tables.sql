-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA: Profile Management Tables
-- ============================================================================
-- Propósito: Verificar estructura de tablas para gestión de perfil
-- Autor: AI Assistant
-- Fecha: 2024-12-27
-- ============================================================================

-- 1. Verificar estructura de customer_addresses
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customer_addresses'
ORDER BY ordinal_position;

-- 2. Ver ejemplos de direcciones
SELECT * FROM customer_addresses LIMIT 3;

-- 3. Verificar estructura de customer_payment_methods
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customer_payment_methods'
ORDER BY ordinal_position;

-- 4. Ver ejemplos de métodos de pago
SELECT * FROM customer_payment_methods LIMIT 3;

-- 5. Verificar RLS policies
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename IN ('customer_addresses', 'customer_payment_methods')
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
WHERE tc.table_name IN ('customer_addresses', 'customer_payment_methods')
ORDER BY tc.table_name, tc.constraint_type;
