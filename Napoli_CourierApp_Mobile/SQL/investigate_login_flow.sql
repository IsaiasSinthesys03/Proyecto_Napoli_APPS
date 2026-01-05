-- ============================================================================
-- INVESTIGACIÓN: ¿Cómo funciona login_driver si los IDs no coinciden?
-- ============================================================================

-- 1. Ver el código del stored procedure login_driver
SELECT 
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'login_driver'
  AND routine_schema = 'public';

-- 2. Probar manualmente lo que hace login_driver con el email de Braulio
SELECT 
  id,
  name,
  email,
  phone,
  status,
  is_online
FROM drivers
WHERE email = 'braulioisaiasbernalpadron@gmail.com';

-- 3. Ver qué ID está guardado en la sesión de Braulio
-- (Esto lo veremos en los logs de la app)

-- 4. TEORÍA: Si login_driver retorna el ID de la tabla drivers (no de auth.users),
--    entonces la app usa ESE ID para llamar a toggle_driver_online_status
--    Verificar si toggle_driver_online_status actualiza por ID o por email

SELECT 
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'toggle_driver_online_status'
  AND routine_schema = 'public';
