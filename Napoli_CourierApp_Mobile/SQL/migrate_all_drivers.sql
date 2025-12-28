-- ========================================
-- MIGRAR DRIVERS AL RESTAURANT CORRECTO
-- ========================================

-- 1. Ver cuántos drivers tienen el restaurant ID viejo
SELECT 
  COUNT(*) as drivers_con_id_viejo,
  restaurant_id
FROM drivers
WHERE restaurant_id = '00000000-0000-0000-0000-000000000001'
GROUP BY restaurant_id;

-- 2. Ver detalles de esos drivers
SELECT 
  id,
  email,
  name,
  restaurant_id,
  status,
  created_at
FROM drivers
WHERE restaurant_id = '00000000-0000-0000-0000-000000000001'
ORDER BY created_at DESC;

-- 3. MIGRAR todos los drivers al restaurant correcto
UPDATE drivers
SET restaurant_id = '06a5284c-0ef8-4efe-a882-ce1fc8319452'
WHERE restaurant_id = '00000000-0000-0000-0000-000000000001';

-- 4. Verificar que se actualizaron
SELECT 
  id,
  email,
  name,
  restaurant_id,
  status
FROM drivers
WHERE restaurant_id = '06a5284c-0ef8-4efe-a882-ce1fc8319452'
ORDER BY created_at DESC;

-- 5. Verificar que no queden drivers con el ID viejo
SELECT COUNT(*) as drivers_restantes_con_id_viejo
FROM drivers
WHERE restaurant_id = '00000000-0000-0000-0000-000000000001';
