-- ============================================================================
-- SOLUCIÓN SIMPLE: ELIMINAR POLÍTICAS CONFLICTIVAS
-- ============================================================================
-- Problema: auth.uid() != driver.id, causando que las políticas RLS bloqueen
-- Solución: Eliminar políticas que dependen de auth.uid() = driver.id
--           y confiar en que la app filtra correctamente

-- 1. ELIMINAR políticas conflictivas
DROP POLICY IF EXISTS "driver_orders" ON orders;
DROP POLICY IF EXISTS "drivers_can_view_orders" ON orders;

-- 2. MANTENER solo las políticas que funcionan:
--    - "Drivers can view assigned or available orders" (la que creamos)
--    - Las políticas de customers (no interfieren)

-- 3. Verificar políticas restantes
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'orders' 
  AND policyname LIKE '%driver%';

-- ============================================================================
-- RESULTADO ESPERADO:
-- Solo debe quedar "Drivers can view assigned or available orders"
-- ============================================================================
