-- ============================================================================
-- PRUEBA TEMPORAL: DESHABILITAR RLS PARA DIAGNOSTICAR
-- ============================================================================
-- ADVERTENCIA: Solo para prueba, NO dejar en producción

-- 1. Deshabilitar RLS temporalmente
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;

-- 2. Verificar que está deshabilitado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'orders';

-- ============================================================================
-- INSTRUCCIONES:
-- ============================================================================
-- 1. Ejecuta este script
-- 2. Haz Hot Restart en la app
-- 3. Si los pedidos APARECEN, confirma que el problema es RLS
-- 4. Si NO aparecen, el problema es otro (query, parsing, etc.)
--
-- IMPORTANTE: Después de la prueba, vuelve a habilitar RLS con:
-- ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
-- ============================================================================
