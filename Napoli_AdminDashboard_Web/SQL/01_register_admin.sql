-- ============================================================================
-- STORED PROCEDURE: register_admin
-- ============================================================================
-- Propósito: Registrar un nuevo restaurante y su administrador
-- Parámetros:
--   - p_email: Email del administrador
--   - p_restaurant_name: Nombre del restaurante
--   - p_manager_name: Nombre del administrador
--   - p_phone: Teléfono
-- Retorna: JSON con restaurant_id y admin_id
-- Autor: AI Assistant
-- Fecha: 2024-12-28
-- ============================================================================

CREATE OR REPLACE FUNCTION register_admin(
  p_email TEXT,
  p_restaurant_name TEXT,
  p_manager_name TEXT,
  p_phone TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_restaurant_id UUID;
  v_admin_id UUID;
  v_slug TEXT;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - register_admin called';
  RAISE NOTICE '📦 DATA - email: %, restaurant: %', p_email, p_restaurant_name;
  
  -- Generate slug from restaurant name
  v_slug := lower(regexp_replace(p_restaurant_name, '[^a-z0-9]+', '-', 'g'));
  v_slug := regexp_replace(v_slug, '(^-|-$)', '', 'g');
  v_slug := v_slug || '-' || extract(epoch from now())::bigint;
  
  RAISE NOTICE '📦 DATA - Generated slug: %', v_slug;
  
  -- Create restaurant
  INSERT INTO restaurants (
    name,
    slug,
    email,
    phone
  )
  VALUES (
    p_restaurant_name,
    v_slug,
    p_email,
    p_phone
  )
  RETURNING id INTO v_restaurant_id;
  
  RAISE NOTICE '✅ SUCCESS - Restaurant created with ID: %', v_restaurant_id;
  
  -- Create restaurant admin
  INSERT INTO restaurant_admins (
    restaurant_id,
    name,
    email,
    phone,
    role,
    is_primary
  )
  VALUES (
    v_restaurant_id,
    p_manager_name,
    p_email,
    p_phone,
    'owner',
    true
  )
  RETURNING id INTO v_admin_id;
  
  RAISE NOTICE '✅ SUCCESS - Admin created with ID: %', v_admin_id;
  
  -- Build response
  SELECT json_build_object(
    'restaurant_id', v_restaurant_id,
    'admin_id', v_admin_id,
    'restaurant_name', p_restaurant_name,
    'manager_name', p_manager_name,
    'email', p_email
  )
  INTO v_result;
  
  RAISE NOTICE '✅ SUCCESS - Registration complete';
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in register_admin: %', SQLERRM;
    RAISE EXCEPTION 'Error al registrar administrador: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION register_admin(TEXT, TEXT, TEXT, TEXT) IS 
'Registra un nuevo restaurante y su administrador principal';

-- Ejemplo de uso:
-- SELECT register_admin(
--   'admin@example.com',
--   'Pizzería Napoli',
--   'Juan Pérez',
--   '+1234567890'
-- );
