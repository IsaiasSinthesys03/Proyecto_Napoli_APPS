-- ============================================================================
-- SOLUCIÓN SEGURA: TABLA DE MAPEO AUTH -> DRIVER
-- ============================================================================

-- 1. Crear tabla de mapeo
CREATE TABLE IF NOT EXISTS driver_auth_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(auth_user_id),
  UNIQUE(driver_id)
);

-- 2. Insertar el mapeo para tu usuario actual
INSERT INTO driver_auth_mapping (auth_user_id, driver_id)
VALUES (
  'a0442967-0d2a-4006-a96f-2785beb4dc06',  -- Tu auth.uid()
  '792b8aa0-c10a-411d-973f-e0434b303f9a'   -- Tu driver.id
)
ON CONFLICT (auth_user_id) DO NOTHING;

-- 3. Eliminar política insegura
DROP POLICY IF EXISTS "authenticated_users_view_orders" ON orders;
DROP POLICY IF EXISTS "drivers_view_own_restaurant_orders" ON orders;

-- 4. Crear política SEGURA usando la tabla de mapeo
CREATE POLICY "drivers_view_restaurant_orders_secure"
ON orders
FOR SELECT
TO authenticated
USING (
  -- El pedido pertenece al restaurante del driver logueado
  restaurant_id IN (
    SELECT d.restaurant_id 
    FROM drivers d
    INNER JOIN driver_auth_mapping dam ON d.id = dam.driver_id
    WHERE dam.auth_user_id = auth.uid()
  )
);

-- 5. Habilitar RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 6. Verificar
SELECT 
  policyname, 
  cmd, 
  qual 
FROM pg_policies 
WHERE tablename = 'orders' 
  AND policyname = 'drivers_view_restaurant_orders_secure';

-- ============================================================================
-- SEGURIDAD GARANTIZADA:
-- ============================================================================
-- ✅ Solo ves pedidos de TU restaurante
-- ✅ Usa auth.uid() que es seguro
-- ✅ Mapeo explícito entre usuario Auth y Driver
-- ✅ Aislamiento completo entre restaurantes
-- ============================================================================
