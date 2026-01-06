-- Ver el último pedido actualizado para diagnosticar su estado
SELECT 
  id, 
  order_number, 
  status, 
  driver_id, 
  updated_at
FROM orders
ORDER BY updated_at DESC
LIMIT 1;
