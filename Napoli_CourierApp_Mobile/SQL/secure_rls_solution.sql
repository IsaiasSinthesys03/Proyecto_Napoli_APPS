-- ============================================================================
-- SOLUCIÓN SEGURA: RLS BASADO EN EMAIL Y RESTAURANT_ID
-- ============================================================================
-- Problema: auth.uid() != driver.id
-- Solución: Usar auth.email() para identificar al driver y filtrar por restaurant

-- 1. ELIMINAR TODAS las políticas de drivers antiguas
DROP POLICY IF EXISTS "driver_orders" ON orders;
DROP POLICY IF EXISTS "drivers_can_view_orders" ON orders;
DROP POLICY IF EXISTS "Drivers can view assigned or available orders" ON orders;

-- 2. CREAR política segura basada en restaurant_id + email
CREATE POLICY "drivers_view_own_restaurant_orders"
ON orders
FOR SELECT
TO authenticated
USING (
  -- El pedido pertenece al restaurante del driver logueado (identificado por email)
  restaurant_id IN (
    SELECT d.restaurant_id 
    FROM drivers d
    WHERE d.email = auth.email()
  )
);

-- 3. Verificar que RLS está activo
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 4. Verificar la política creada
SELECT 
  policyname, 
  cmd, 
  qual 
FROM pg_policies 
WHERE tablename = 'orders' 
  AND policyname = 'drivers_view_own_restaurant_orders';

-- ============================================================================
-- SEGURIDAD:
-- ============================================================================
-- ✅ Un driver solo puede ver pedidos de SU restaurante
-- ✅ No puede ver pedidos de otros restaurantes
-- ✅ No depende de que auth.uid() = driver.id
-- ✅ Usa el email (que sí coincide entre auth.users y drivers)
-- ============================================================================
