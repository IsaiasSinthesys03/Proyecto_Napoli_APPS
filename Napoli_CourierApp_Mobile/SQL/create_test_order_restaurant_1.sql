-- ========================================
-- CREAR PEDIDO PARA RESTAURANT 00000000-0000-0000-0000-000000000001
-- ========================================

WITH new_order AS (
  INSERT INTO orders (
    id,
    restaurant_id,
    order_number,
    customer_id,
    customer_snapshot,
    address_snapshot,
    subtotal_cents,
    delivery_fee_cents,
    tax_cents,
    tip_cents,
    discount_cents,
    total_cents,
    order_type,
    payment_method,
    payment_status,
    status,
    created_at,
    ready_at
  ) VALUES (
    gen_random_uuid(),
    '00000000-0000-0000-0000-000000000001',
    '#TEST002',
    '4d23b895-5ba2-4cd4-ad80-7dd96376f671',
    '{"name": "josegaspar", "email": "josegaspar@gmail.com", "phone": "+5215512345678"}'::jsonb,
    '{"street": "Av. Insurgentes 123, Col. Roma", "city": "CDMX", "lat": 19.4326, "lng": -99.1332}'::jsonb,
    8000,
    200,
    820,
    0,
    0,
    9020,
    'delivery',
    'cash',
    'paid',
    'ready',
    NOW(),
    NOW()
  )
  RETURNING id, order_number, status
)
INSERT INTO order_items (
  id,
  order_id,
  product_id,
  product_name,
  quantity,
  unit_price_cents,
  total_price_cents
)
SELECT 
  gen_random_uuid(),
  new_order.id,
  '7978c1c9-467e-46f9-ac27-e8e3321244f9',
  'Pizza',
  1,
  8000,
  8000
FROM new_order
RETURNING *;

-- Verificar
SELECT 
  id,
  order_number,
  status,
  restaurant_id,
  customer_snapshot->>'name' as customer_name,
  total_cents
FROM orders
WHERE order_number = '#TEST002';
