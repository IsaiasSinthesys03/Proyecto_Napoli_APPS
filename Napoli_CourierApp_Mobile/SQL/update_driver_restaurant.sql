-- ========================================
-- ACTUALIZAR DRIVER A RESTAURANT CORRECTO
-- ========================================

-- Ver drivers actuales y sus restaurants
SELECT 
  id,
  email,
  name,
  restaurant_id,
  status
FROM drivers
ORDER BY created_at DESC
LIMIT 5;

-- Actualizar el driver más reciente al restaurant correcto
UPDATE drivers
SET restaurant_id = '06a5284c-0ef8-4efe-a882-ce1fc8319452'
WHERE email = 'TU_EMAIL_AQUI';  -- Reemplaza con el email que usaste para login

-- Verificar el cambio
SELECT 
  id,
  email,
  name,
  restaurant_id,
  status
FROM drivers
WHERE email = 'TU_EMAIL_AQUI';
