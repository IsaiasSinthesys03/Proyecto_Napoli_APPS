-- ============================================================================
-- FIX PERMISOS: Asegurar que los repartidores puedan ejecutar la función
-- ============================================================================

-- 1. Otorgar permiso de ejecución al rol 'authenticated' (usuarios logueados)
GRANT EXECUTE ON FUNCTION toggle_driver_online_status(UUID, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION toggle_driver_online_status(UUID, BOOLEAN) TO service_role;

-- 2. Asegurarse de que el usuario 'anon' NO pueda ejecutarla (seguridad)
REVOKE EXECUTE ON FUNCTION toggle_driver_online_status(UUID, BOOLEAN) FROM anon;

-- Nota: Si el usuario 'otro' no existe en la tabla 'drivers', la función fallará con
-- el error 'Repartidor no encontrado'. Asegúrate de que el ID del usuario en 
-- 'auth.users' coincida con el ID en la tabla 'drivers'.
