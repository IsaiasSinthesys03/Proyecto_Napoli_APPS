-- ============================================================================
-- STORED PROCEDURE: login_admin
-- ============================================================================
-- Propósito: Obtener información del administrador y su restaurante al hacer login
-- Parámetros:
--   - p_email: Email del administrador
-- Retorna: JSON con datos del admin y restaurante
-- Autor: AI Assistant
-- Fecha: 2024-12-28
-- ============================================================================

CREATE OR REPLACE FUNCTION login_admin(
  p_email TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin RECORD;
  v_restaurant RECORD;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - login_admin called for email: %', p_email;
  
  -- Get admin data
  SELECT *
  INTO v_admin
  FROM restaurant_admins
  WHERE email = p_email;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Admin not found for email: %', p_email;
    RAISE EXCEPTION 'Administrador no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Admin found: %', v_admin.id;
  
  -- Get restaurant data
  SELECT *
  INTO v_restaurant
  FROM restaurants
  WHERE id = v_admin.restaurant_id;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Restaurant not found: %', v_admin.restaurant_id;
    RAISE EXCEPTION 'Restaurante no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Restaurant found: %', v_restaurant.id;
  
  -- Build response
  SELECT json_build_object(
    'admin', json_build_object(
      'id', v_admin.id,
      'name', v_admin.name,
      'email', v_admin.email,
      'phone', v_admin.phone,
      'role', v_admin.role,
      'is_primary', v_admin.is_primary,
      'restaurant_id', v_admin.restaurant_id
    ),
    'restaurant', json_build_object(
      'id', v_restaurant.id,
      'name', v_restaurant.name,
      'slug', v_restaurant.slug,
      'email', v_restaurant.email,
      'phone', v_restaurant.phone,
      'logo_url', v_restaurant.logo_url,
      'is_active', v_restaurant.is_active
    )
  )
  INTO v_result;
  
  RAISE NOTICE '✅ SUCCESS - Login data prepared';
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in login_admin: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener datos de login: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION login_admin(TEXT) IS 
'Obtiene información del administrador y su restaurante para el login';

-- Ejemplo de uso:
-- SELECT login_admin('admin@example.com');
