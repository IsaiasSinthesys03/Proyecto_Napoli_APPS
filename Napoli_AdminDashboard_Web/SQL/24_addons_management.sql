-- ============================================================================
-- STORED PROCEDURES: Addons Management (Updated with image_url)
-- ============================================================================
-- Propósito: Operaciones CRUD para complementos/extras
-- ============================================================================

-- ============================================================================
-- 1. GET ADDONS
-- ============================================================================
CREATE OR REPLACE FUNCTION get_admin_addons(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_addons JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_addons called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;
  
  SELECT json_agg(
    json_build_object(
      'id', id,
      'restaurant_id', restaurant_id,
      'name', name,
      'description', description,
      'price_cents', price_cents,
      'image_url', image_url,
      'is_available', is_available,
      'max_quantity', max_quantity,
      'created_at', created_at,
      'updated_at', updated_at
    )
    ORDER BY name ASC
  )
  INTO v_addons
  FROM addons
  WHERE restaurant_id = p_restaurant_id;
  
  RAISE NOTICE '✅ SUCCESS - Returning % addons', json_array_length(COALESCE(v_addons, '[]'::json));
  
  RETURN COALESCE(v_addons, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_addons: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener complementos: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. CREATE ADDON
-- ============================================================================
CREATE OR REPLACE FUNCTION create_admin_addon(
  p_restaurant_id UUID,
  p_name VARCHAR,
  p_price_cents INTEGER,
  p_description TEXT DEFAULT NULL,
  p_image_url VARCHAR DEFAULT NULL,
  p_is_available BOOLEAN DEFAULT TRUE,
  p_max_quantity INTEGER DEFAULT 10
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_addon JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - create_admin_addon called';
  RAISE NOTICE '📦 DATA - name: %, price_cents: %', p_name, p_price_cents;
  
  INSERT INTO addons (
    restaurant_id,
    name,
    description,
    price_cents,
    image_url,
    is_available,
    max_quantity
  ) VALUES (
    p_restaurant_id,
    p_name,
    p_description,
    p_price_cents,
    p_image_url,
    p_is_available,
    p_max_quantity
  )
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'description', description,
    'price_cents', price_cents,
    'image_url', image_url,
    'is_available', is_available,
    'max_quantity', max_quantity,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_addon;
  
  RAISE NOTICE '✅ SUCCESS - Addon created with id: %', (v_addon->>'id');
  
  RETURN v_addon;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in create_admin_addon: %', SQLERRM;
    RAISE EXCEPTION 'Error al crear complemento: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 3. UPDATE ADDON
-- ============================================================================
CREATE OR REPLACE FUNCTION update_admin_addon(
  p_addon_id UUID,
  p_name VARCHAR DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_price_cents INTEGER DEFAULT NULL,
  p_image_url VARCHAR DEFAULT NULL,
  p_is_available BOOLEAN DEFAULT NULL,
  p_max_quantity INTEGER DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_addon JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_addon called';
  RAISE NOTICE '📦 DATA - addon_id: %', p_addon_id;
  
  UPDATE addons
  SET
    name = COALESCE(p_name, name),
    description = COALESCE(p_description, description),
    price_cents = COALESCE(p_price_cents, price_cents),
    image_url = COALESCE(p_image_url, image_url),
    is_available = COALESCE(p_is_available, is_available),
    max_quantity = COALESCE(p_max_quantity, max_quantity),
    updated_at = NOW()
  WHERE id = p_addon_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'description', description,
    'price_cents', price_cents,
    'image_url', image_url,
    'is_available', is_available,
    'max_quantity', max_quantity,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_addon;
  
  IF v_addon IS NULL THEN
    RAISE EXCEPTION 'Complemento no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Addon updated';
  
  RETURN v_addon;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_admin_addon: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar complemento: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 4. DELETE ADDON
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_admin_addon(
  p_addon_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - delete_admin_addon called';
  RAISE NOTICE '📦 DATA - addon_id: %', p_addon_id;
  
  DELETE FROM addons
  WHERE id = p_addon_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Complemento no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Addon deleted';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in delete_admin_addon: %', SQLERRM;
    RAISE EXCEPTION 'Error al eliminar complemento: %', SQLERRM;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION get_admin_addons IS 'Obtiene lista de complementos del restaurante';
COMMENT ON FUNCTION create_admin_addon IS 'Crea un nuevo complemento';
COMMENT ON FUNCTION update_admin_addon IS 'Actualiza un complemento existente';
COMMENT ON FUNCTION delete_admin_addon IS 'Elimina un complemento';
