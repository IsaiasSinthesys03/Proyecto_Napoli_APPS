-- ============================================================================
-- STORED PROCEDURES: Categories Management
-- ============================================================================
-- Propósito: Operaciones CRUD para categorías
-- ============================================================================

-- ============================================================================
-- 1. GET CATEGORIES (List)
-- ============================================================================
CREATE OR REPLACE FUNCTION get_admin_categories(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_categories JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_categories called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;
  
  SELECT json_agg(
    json_build_object(
      'id', id,
      'restaurant_id', restaurant_id,
      'name', name,
      'description', description,
      'image_url', image_url,
      'display_order', display_order,
      'is_active', is_active,
      'created_at', created_at,
      'updated_at', updated_at
    )
    ORDER BY display_order ASC, name ASC
  )
  INTO v_categories
  FROM categories
  WHERE restaurant_id = p_restaurant_id;
  
  RAISE NOTICE '✅ SUCCESS - Returning % categories', json_array_length(COALESCE(v_categories, '[]'::json));
  
  RETURN COALESCE(v_categories, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_categories: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener categorías: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. GET CATEGORY (Single)
-- ============================================================================
CREATE OR REPLACE FUNCTION get_admin_category(
  p_category_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_category JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_category called';
  RAISE NOTICE '📦 DATA - category_id: %', p_category_id;
  
  SELECT json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'description', description,
    'image_url', image_url,
    'display_order', display_order,
    'is_active', is_active,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_category
  FROM categories
  WHERE id = p_category_id;
  
  IF v_category IS NULL THEN
    RAISE EXCEPTION 'Categoría no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Category retrieved';
  
  RETURN v_category;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_category: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener categoría: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 3. CREATE CATEGORY
-- ============================================================================
CREATE OR REPLACE FUNCTION create_admin_category(
  p_restaurant_id UUID,
  p_name VARCHAR,
  p_description TEXT DEFAULT NULL,
  p_image_url VARCHAR DEFAULT NULL,
  p_display_order INTEGER DEFAULT 0,
  p_is_active BOOLEAN DEFAULT TRUE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_category JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - create_admin_category called';
  RAISE NOTICE '📦 DATA - name: %', p_name;
  
  INSERT INTO categories (
    restaurant_id,
    name,
    description,
    image_url,
    display_order,
    is_active
  ) VALUES (
    p_restaurant_id,
    p_name,
    p_description,
    p_image_url,
    p_display_order,
    p_is_active
  )
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'description', description,
    'image_url', image_url,
    'display_order', display_order,
    'is_active', is_active,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_category;
  
  RAISE NOTICE '✅ SUCCESS - Category created with id: %', (v_category->>'id');
  
  RETURN v_category;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in create_admin_category: %', SQLERRM;
    RAISE EXCEPTION 'Error al crear categoría: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 4. UPDATE CATEGORY
-- ============================================================================
CREATE OR REPLACE FUNCTION update_admin_category(
  p_category_id UUID,
  p_name VARCHAR DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_image_url VARCHAR DEFAULT NULL,
  p_display_order INTEGER DEFAULT NULL,
  p_is_active BOOLEAN DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_category JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_category called';
  RAISE NOTICE '📦 DATA - category_id: %', p_category_id;
  
  UPDATE categories
  SET
    name = COALESCE(p_name, name),
    description = COALESCE(p_description, description),
    image_url = COALESCE(p_image_url, image_url),
    display_order = COALESCE(p_display_order, display_order),
    is_active = COALESCE(p_is_active, is_active),
    updated_at = NOW()
  WHERE id = p_category_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'description', description,
    'image_url', image_url,
    'display_order', display_order,
    'is_active', is_active,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_category;
  
  IF v_category IS NULL THEN
    RAISE EXCEPTION 'Categoría no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Category updated';
  
  RETURN v_category;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_admin_category: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar categoría: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 5. DELETE CATEGORY
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_admin_category(
  p_category_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - delete_admin_category called';
  RAISE NOTICE '📦 DATA - category_id: %', p_category_id;
  
  DELETE FROM categories
  WHERE id = p_category_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Categoría no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Category deleted';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in delete_admin_category: %', SQLERRM;
    RAISE EXCEPTION 'Error al eliminar categoría: %', SQLERRM;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION get_admin_categories IS 'Obtiene lista de categorías del restaurante';
COMMENT ON FUNCTION get_admin_category IS 'Obtiene detalles de una categoría';
COMMENT ON FUNCTION create_admin_category IS 'Crea una nueva categoría';
COMMENT ON FUNCTION update_admin_category IS 'Actualiza una categoría existente';
COMMENT ON FUNCTION delete_admin_category IS 'Elimina una categoría';
