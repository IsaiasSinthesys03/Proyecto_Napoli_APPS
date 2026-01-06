-- ============================================================================
-- LIMPIAR Y CORREGIR POLÍTICAS RLS PARA DRIVERS
-- ============================================================================
-- Problema: Múltiples políticas conflictivas + auth.uid() != driver.id
-- Solución: Eliminar políticas que asumen auth.uid() = driver.id

-- 1. ELIMINAR todas las políticas antiguas/conflictivas
DROP POLICY IF EXISTS "driver_orders" ON orders;
DROP POLICY IF EXISTS "drivers_can_view_orders" ON orders;
DROP POLICY IF EXISTS "Drivers can view assigned or available orders" ON orders;

-- 2. CREAR política correcta que NO depende de auth.uid() = driver.id
-- Esta política permite ver pedidos basándose en el restaurant_id del driver
CREATE POLICY "drivers_view_restaurant_orders"
ON orders
FOR SELECT
TO authenticated
USING (
  -- El pedido pertenece al mismo restaurante que el driver logueado
  restaurant_id IN (
    SELECT d.restaurant_id 
    FROM drivers d
    WHERE d.id IN (
      -- Buscar el driver_id asociado al auth.uid() actual
      SELECT driver_id 
      FROM driver_auth_mapping 
      WHERE auth_user_id = auth.uid()
    )
  )
);

-- 3. Verificar que RLS está activo
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- NOTA IMPORTANTE:
-- ============================================================================
-- Esta política asume que existe una tabla 'driver_auth_mapping' que mapea
-- auth.uid() -> driver.id. Si NO existe, necesitamos crearla primero.
-- 
-- Alternativa temporal: Crear la política sin depender de auth.uid()
-- y confiar en que la app filtra correctamente por driver_id.
-- ============================================================================
