-- ============================================================================
-- STORED PROCEDURE: get_menu_items
-- ============================================================================
-- Propósito: Obtener todos los productos del menú con sus categorías y addons
-- Parámetros:
--   - p_restaurant_id: ID del restaurante
-- Retorna: JSON array con productos, categorías y addons
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION get_menu_items(
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
  RAISE NOTICE '🔍 DEBUG - get_menu_items called for restaurant_id: %', p_restaurant_id;
  
  -- Construir JSON con productos, categorías y addons
  SELECT json_agg(
    json_build_object(
      'id', p.id,
      'restaurant_id', p.restaurant_id,
      'category_id', p.category_id,
      'name', p.name,
      'description', p.description,
      'price_cents', p.price_cents,
      'image_url', p.image_url,
      'images', COALESCE(p.images, '[]'::jsonb),
      'is_available', p.is_available,
      'is_featured', COALESCE(p.is_featured, false),
      'tags', COALESCE(p.tags, '[]'::jsonb),
      'allergens', COALESCE(p.allergens, '[]'::jsonb),
      'preparation_time_minutes', p.preparation_time_minutes,
      'display_order', COALESCE(p.display_order, 0),
      'created_at', p.created_at,
      'updated_at', p.updated_at,
      'category', CASE 
        WHEN c.id IS NOT NULL THEN json_build_object(
          'id', c.id,
          'name', c.name
        )
        ELSE NULL
      END,
      'addons', COALESCE((
        SELECT json_agg(
          json_build_object(
            'id', a.id,
            'name', a.name,
            'description', a.description,
            'price_cents', a.price_cents,
            'is_available', a.is_available,
            'max_quantity', a.max_quantity
          )
          ORDER BY a.name
        )
        FROM product_addons pa
        INNER JOIN addons a ON a.id = pa.addon_id
        WHERE pa.product_id = p.id
          AND a.is_available = true
      ), '[]'::json)
    )
    ORDER BY p.display_order, p.name
  )
  INTO v_result
  FROM products p
  LEFT JOIN categories c ON c.id = p.category_id
  WHERE p.restaurant_id = p_restaurant_id
    AND p.is_available = true;
  
  -- Si no hay productos, retornar array vacío
  IF v_result IS NULL THEN
    v_result := '[]'::json;
    RAISE NOTICE '📦 DATA - No products found for restaurant';
  ELSE
    RAISE NOTICE '✅ SUCCESS - Products retrieved successfully';
  END IF;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_menu_items: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener productos: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION get_menu_items(UUID) IS 
'Obtiene todos los productos disponibles del menú con sus categorías y addons';

-- Ejemplo de uso:
-- SELECT get_menu_items('restaurant-uuid-here');
