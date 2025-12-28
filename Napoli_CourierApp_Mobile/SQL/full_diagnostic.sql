-- ========================================
-- DIAGNÓSTICO COMPLETO - Por qué no aparece el pedido
-- ========================================

-- 1. Verificar que el pedido existe y está en estado correcto
SELECT 
  id,
  order_number,
  restaurant_id,
  status,
  driver_id,
  customer_snapshot->>'name' as customer,
  total_cents,
  created_at
FROM orders
WHERE order_number = '#TEST001';

-- 2. Verificar que el driver tiene el restaurant_id correcto
SELECT 
  id,
  email,
  name,
  restaurant_id,
  status
FROM drivers
ORDER BY created_at DESC
LIMIT 5;

-- 3. Probar la stored procedure directamente con ambos restaurant IDs
-- Con el ID nuevo (debería devolver el pedido)
SELECT get_available_orders('06a5284c-0ef8-4efe-a882-ce1fc8319452'::uuid);

-- Con el ID viejo (debería devolver vacío)
SELECT get_available_orders('00000000-0000-0000-0000-000000000001'::uuid);

-- 4. Verificar que no hay problemas de RLS
SELECT 
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'orders';
