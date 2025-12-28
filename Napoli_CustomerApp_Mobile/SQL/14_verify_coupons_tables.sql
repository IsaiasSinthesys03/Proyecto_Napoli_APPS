-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA DE TABLAS: Coupons
-- ============================================================================
-- Propósito: Verificar estructura de tablas relacionadas con cupones
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

-- 1. Verificar estructura de la tabla coupons
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'coupons'
ORDER BY ordinal_position;

-- 2. Ver ejemplo de datos de coupons
SELECT * FROM coupons LIMIT 3;

-- 3. Verificar estructura de la tabla customer_coupons
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customer_coupons'
ORDER BY ordinal_position;

-- 4. Ver ejemplo de datos de customer_coupons
SELECT * FROM customer_coupons LIMIT 3;

-- 5. Verificar RLS policies en coupons
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename IN ('coupons', 'customer_coupons')
ORDER BY tablename, policyname;

-- 6. Ver stored procedure existente increment_coupon_usage
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'increment_coupon_usage';
