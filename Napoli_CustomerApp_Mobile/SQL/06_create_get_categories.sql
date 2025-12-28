-- ============================================================================
-- STORED PROCEDURE: get_categories
-- ============================================================================
-- Propósito: Obtener todas las categorías activas del restaurante
-- Parámetros:
--   - p_restaurant_id: ID del restaurante
-- Retorna: JSON array con categorías
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION get_categories(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Log inicio de función
  RAISE NOTICE '🔍 DEBUG - get_categories called for restaurant_id: %', p_restaurant_id;
  
  -- Construir JSON con categorías
  SELECT json_agg(
    json_build_object(
      'id', c.id,
      'restaurant_id', c.restaurant_id,
      'name', c.name,
      'description', c.description,
      'image_url', c.image_url,
      'is_active', c.is_active,
      'display_order', COALESCE(c.display_order, 0),
      'created_at', c.created_at,
      'updated_at', c.updated_at
    )
    ORDER BY c.display_order, c.name
  )
  INTO v_result
  FROM categories c
  WHERE c.restaurant_id = p_restaurant_id
    AND c.is_active = true;
  
  -- Si no hay categorías, retornar array vacío
  IF v_result IS NULL THEN
    v_result := '[]'::json;
    RAISE NOTICE '📦 DATA - No categories found for restaurant';
  ELSE
    RAISE NOTICE '✅ SUCCESS - Categories retrieved successfully';
  END IF;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_categories: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener categorías: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION get_categories(UUID) IS 
'Obtiene todas las categorías activas del restaurante';

-- Ejemplo de uso:
-- SELECT get_categories('restaurant-uuid-here');
