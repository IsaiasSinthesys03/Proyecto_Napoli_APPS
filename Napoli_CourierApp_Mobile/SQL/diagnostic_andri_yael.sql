-- ============================================================================
-- DIAGNÓSTICO ESPECÍFICO: Andri Yael - Problema de conexión
-- ============================================================================
-- Esta consulta analiza en detalle por qué Andri Yael no aparece conectado
-- en el Admin Dashboard aunque esté conectado en la CourierApp
-- ============================================================================

-- 1. Información completa de Andri Yael
SELECT 
  '=== DATOS DEL DRIVER ===' as seccion,
  d.id as driver_id,
  d.name,
  d.email,
  d.phone,
  d.status,
  d.is_online,
  d.updated_at as ultima_actualizacion
FROM drivers d
WHERE d.email = 'andriyaelr12@gmail.com';

-- 2. Verificar si existe en auth.users
SELECT 
  '=== VERIFICACIÓN AUTH ===' as seccion,
  au.id as auth_user_id,
  au.email as auth_email,
  au.confirmed_at,
  au.created_at as auth_created_at,
  -- Comparar con el ID en drivers
  (SELECT id FROM drivers WHERE email = 'andriyaelr12@gmail.com') as driver_table_id,
  -- ¿Coinciden?
  CASE 
    WHEN au.id = (SELECT id FROM drivers WHERE email = 'andriyaelr12@gmail.com') 
    THEN '✅ IDs COINCIDEN'
    ELSE '❌ IDs NO COINCIDEN - ESTE ES EL PROBLEMA'
  END as diagnostico
FROM auth.users au
WHERE au.email = 'andriyaelr12@gmail.com';

-- 3. Ver qué consulta usa el Admin Dashboard para obtener drivers
-- Esta es la query que usa get_admin_drivers
SELECT 
  '=== LO QUE VE EL ADMIN ===' as seccion,
  d.id,
  d.name,
  d.email,
  d.phone,
  d.vehicle_type,
  d.status,
  d.is_online,
  COUNT(o.id) as active_deliveries
FROM drivers d
LEFT JOIN orders o ON o.driver_id = d.id 
  AND o.status = 'delivering'
WHERE d.status = 'active'
  AND d.is_online = true  -- ← Filtro crítico
  AND d.email = 'andriyaelr12@gmail.com'
GROUP BY d.id, d.name, d.email, d.phone, d.vehicle_type, d.status, d.is_online;

-- 4. Verificar el stored procedure toggle_driver_online_status
-- Ver si se ejecutó correctamente
SELECT 
  '=== HISTORIAL DE CAMBIOS ===' as seccion,
  updated_at,
  is_online,
  status
FROM drivers
WHERE email = 'andriyaelr12@gmail.com';

-- 5. SOLUCIÓN: Si los IDs no coinciden, este es el fix
-- (NO EJECUTAR TODAVÍA, solo para referencia)
/*
UPDATE drivers 
SET id = (SELECT id FROM auth.users WHERE email = 'andriyaelr12@gmail.com')
WHERE email = 'andriyaelr12@gmail.com';
*/
