-- ============================================================================
-- FIX RLS POLICIES FOR DRIVERS
-- ============================================================================
-- Problema: Los drivers no pueden ver pedidos 'ready' asignados a ellos.
-- Solución: Permitir SELECT si driver_id es el usuario actual O si está disponible.

-- 1. Eliminar políticas antiguas (para asegurar limpieza)
DROP POLICY IF EXISTS "Drivers can view their own orders" ON orders;
DROP POLICY IF EXISTS "Drivers can view available orders" ON orders;
DROP POLICY IF EXISTS "Drivers can view assigned or available orders" ON orders;

-- 2. Crear política unificada y permisiva
CREATE POLICY "Drivers can view assigned or available orders"
ON orders
FOR SELECT
TO authenticated
USING (
  -- Caso 1: Asignado al driver actual (sin importar el status)
  (driver_id = auth.uid())
  OR
  -- Caso 2: Disponible (Ready y sin driver)
  (status = 'ready' AND driver_id IS NULL)
);

-- 3. Asegurar que RLS está activo
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Verificación
SELECT count(*) FROM orders WHERE driver_id IS NOT NULL;
