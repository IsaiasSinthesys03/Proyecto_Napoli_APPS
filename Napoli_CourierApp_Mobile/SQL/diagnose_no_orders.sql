-- ========================================
-- DIAGNÓSTICO: Por qué no aparece el pedido
-- ========================================

-- 1. Verificar que el pedido existe y está en status 'ready'
SELECT 
  id,
  order_number,
  status,
  driver_id,
  restaurant_id,
  customer_snapshot->>'name' as customer_name,
  total_cents
FROM orders
WHERE order_number = '#TEST001';

-- 2. Verificar que el restaurant_id coincide con el configurado en la app
-- El app_config.dart tiene: '06a5284c-0ef8-4efe-a882-ce1fc8319452'
SELECT 
  COUNT(*) as orders_for_restaurant
FROM orders
WHERE restaurant_id = '06a5284c-0ef8-4efe-a882-ce1fc8319452'
  AND status = 'ready'
  AND driver_id IS NULL;

-- 3. Probar la stored procedure directamente
SELECT get_available_orders('06a5284c-0ef8-4efe-a882-ce1fc8319452'::uuid);

-- 4. Verificar RLS policies para orders
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

-- 5. Ver si hay algún driver autenticado
SELECT 
  id,
  email,
  name,
  status
FROM drivers
LIMIT 5;
