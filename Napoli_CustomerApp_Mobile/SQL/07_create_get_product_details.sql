-- ============================================================================
-- STORED PROCEDURE: get_product_details
-- ============================================================================
-- Propósito: Obtener detalles completos de un producto específico
-- Parámetros:
--   - p_product_id: ID del producto
-- Retorna: JSON con detalles del producto, categoría y addons
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION get_product_details(
  p_product_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Log inicio de función
  RAISE NOTICE '🔍 DEBUG - get_product_details called for product_id: %', p_product_id;
  
  -- Construir JSON con detalles del producto
  SELECT json_build_object(
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
        'name', c.name,
        'description', c.description
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
  INTO v_result
  FROM products p
  LEFT JOIN categories c ON c.id = p.category_id
  WHERE p.id = p_product_id;
  
  IF v_result IS NULL THEN
    RAISE NOTICE '❌ ERROR - Product not found: %', p_product_id;
    RETURN NULL;
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Product details retrieved successfully';
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_product_details: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener detalles del producto: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION get_product_details(UUID) IS 
'Obtiene los detalles completos de un producto específico con categoría y addons';

-- Ejemplo de uso:
-- SELECT get_product_details('product-uuid-here');
