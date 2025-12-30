-- ============================================================================
-- STORED PROCEDURE: get_admin_products
-- ============================================================================
-- Propósito: Obtener lista de productos del restaurante con categoría
-- Parámetros:
--   - p_restaurant_id: UUID del restaurante
-- Retorna: JSON array de productos con categoría
-- ============================================================================

CREATE OR REPLACE FUNCTION get_admin_products(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_products JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_products called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;
  
  SELECT json_agg(
    json_build_object(
      'id', p.id,
      'restaurant_id', p.restaurant_id,
      'category_id', p.category_id,
      'name', p.name,
      'description', p.description,
      'short_description', p.short_description,
      'price_cents', p.price_cents,
      'compare_at_price_cents', p.compare_at_price_cents,
      'cost_cents', p.cost_cents,
      'image_url', p.image_url,
      'images', p.images,
      'is_available', p.is_available,
      'track_inventory', p.track_inventory,
      'inventory_count', p.inventory_count,
      'low_stock_threshold', p.low_stock_threshold,
      'is_featured', p.is_featured,
      'is_new', p.is_new,
      'is_bestseller', p.is_bestseller,
      'calories', p.calories,
      'preparation_time_minutes', p.preparation_time_minutes,
      'tags', p.tags,
      'allergens', p.allergens,
      'display_order', p.display_order,
      'total_sold', p.total_sold,
      'total_revenue_cents', p.total_revenue_cents,
      'rating_sum', p.rating_sum,
      'rating_count', p.rating_count,
      'created_at', p.created_at,
      'updated_at', p.updated_at,
      'category', CASE 
        WHEN c.id IS NOT NULL THEN json_build_object(
          'id', c.id,
          'name', c.name
        )
        ELSE NULL
      END
    )
    ORDER BY p.display_order ASC, p.created_at DESC
  )
  INTO v_products
  FROM products p
  LEFT JOIN categories c ON p.category_id = c.id
  WHERE p.restaurant_id = p_restaurant_id;
  
  RAISE NOTICE '✅ SUCCESS - Returning % products', json_array_length(COALESCE(v_products, '[]'::json));
  
  RETURN COALESCE(v_products, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_products: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener productos: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION get_admin_products IS 'Obtiene lista de productos del restaurante con información de categoría';
