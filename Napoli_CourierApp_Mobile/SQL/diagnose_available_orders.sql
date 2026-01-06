-- Diagnóstico completo de por qué no aparecen pedidos disponibles

-- 1. Ver todos los pedidos ready del driver
SELECT 
  order_number,
  status,
  driver_id,
  restaurant_id,
  created_at
FROM orders
WHERE driver_id = '792b8aa0-c10a-411d-973f-e0434b303f9a'
ORDER BY created_at DESC;

-- 2. Ver pedidos ready sin filtro de driver (para ver si RLS los oculta)
SELECT 
  order_number,
  status,
  driver_id,
  restaurant_id
FROM orders
WHERE status = 'ready'
ORDER BY created_at DESC;

-- 3. Verificar las políticas RLS activas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'orders';

-- 4. Ver el restaurant_id del driver
SELECT 
  id,
  name,
  restaurant_id,
  is_online
FROM drivers
WHERE id = '792b8aa0-c10a-411d-973f-e0434b303f9a';
