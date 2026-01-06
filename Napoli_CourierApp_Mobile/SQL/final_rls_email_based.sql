-- ============================================================================
-- SOLUCIÓN FINAL: RLS BASADO EN EMAIL (NO EN auth.uid())
-- ============================================================================

-- 1. Habilitar RLS nuevamente
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 2. Eliminar política que usa auth.uid()
DROP POLICY IF EXISTS "drivers_view_restaurant_orders_secure" ON orders;

-- 3. Crear política basada SOLO en email (más confiable)
CREATE POLICY "drivers_view_by_email"
ON orders
FOR SELECT
TO authenticated
USING (
  -- Permitir si existe un driver con este email
  EXISTS (
    SELECT 1 
    FROM drivers d 
    WHERE d.email = auth.email()
      AND d.restaurant_id = orders.restaurant_id
  )
);

-- 4. Verificar
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'orders' 
  AND policyname = 'drivers_view_by_email';

-- ============================================================================
-- POR QUÉ FUNCIONA:
-- ============================================================================
-- ✅ auth.email() es MÁS confiable que auth.uid()
-- ✅ Filtra por restaurant_id para seguridad
-- ✅ No depende de tabla de mapeo
-- ✅ Simple y directo
-- ============================================================================
