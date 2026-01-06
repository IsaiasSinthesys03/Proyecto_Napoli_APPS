-- ============================================================================
-- OPCIÓN INTERMEDIA: RLS POR ROL (Sin tabla de mapeo)
-- ============================================================================
-- Más seguro que USING(true), sin agregar tablas nuevas

-- 1. Eliminar políticas anteriores
DROP POLICY IF EXISTS "authenticated_users_view_orders" ON orders;
DROP POLICY IF EXISTS "drivers_view_own_restaurant_orders" ON orders;
DROP POLICY IF EXISTS "drivers_view_restaurant_orders_secure" ON orders;

-- 2. Crear política que confía en que solo DRIVERS se autentican en la app
CREATE POLICY "driver_app_users_view_orders"
ON orders
FOR SELECT
TO authenticated
USING (
  -- Permitir si el usuario autenticado tiene un registro en la tabla drivers
  -- (asumiendo que solo drivers tienen cuentas en la app móvil)
  EXISTS (
    SELECT 1 
    FROM drivers d 
    WHERE d.email = auth.email()
  )
);

-- 3. Habilitar RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 4. Verificar
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'orders' 
  AND policyname = 'driver_app_users_view_orders';

-- ============================================================================
-- SEGURIDAD:
-- ============================================================================
-- ✅ Solo usuarios con registro en 'drivers' pueden ver pedidos
-- ✅ Clientes NO pueden ver pedidos (no están en tabla drivers)
-- ⚠️ Un driver puede ver pedidos de TODOS los restaurantes
-- 
-- NOTA: Para aislar por restaurante, necesitas la tabla de mapeo
-- ============================================================================
