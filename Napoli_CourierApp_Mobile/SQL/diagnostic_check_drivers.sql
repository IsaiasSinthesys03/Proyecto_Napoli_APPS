-- ============================================================================
-- DIAGNÓSTICO: Verificar estado de todos los repartidores
-- ============================================================================
-- Esta consulta muestra información completa de todos los repartidores
-- para diagnosticar problemas de conexión
-- ============================================================================

SELECT 
  d.id,
  d.name,
  d.email,
  d.phone,
  d.vehicle_type,
  d.status,
  d.is_online,
  d.created_at,
  d.updated_at,
  -- Verificar si existe en auth.users
  CASE 
    WHEN au.id IS NOT NULL THEN 'SÍ'
    ELSE 'NO'
  END as existe_en_auth,
  au.email as email_auth,
  au.confirmed_at as email_confirmado
FROM drivers d
LEFT JOIN auth.users au ON d.id = au.id
ORDER BY d.created_at DESC;

-- ============================================================================
-- CONSULTA ADICIONAL: Ver permisos de la función
-- ============================================================================
-- Ejecuta esto también para ver si la función tiene los permisos correctos

SELECT 
  routine_name,
  routine_type,
  security_type,
  specific_name
FROM information_schema.routines
WHERE routine_name = 'toggle_driver_online_status';
