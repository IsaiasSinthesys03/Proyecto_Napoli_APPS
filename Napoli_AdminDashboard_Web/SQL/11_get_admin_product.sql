-- ============================================================================
-- STORED PROCEDURE: get_admin_product
-- ============================================================================
-- Propósito: Obtener detalles de un producto específico con categoría
-- Parámetros:
--   - p_product_id: UUID del producto
-- Retorna: JSON object con detalles del producto
-- ============================================================================

CREATE OR REPLACE FUNCTION get_admin_product(
  p_product_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_product JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_product called';
  RAISE NOTICE '📦 DATA - product_id: %', p_product_id;
  
  SELECT json_build_object(
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
  INTO v_product
  FROM products p
  LEFT JOIN categories c ON p.category_id = c.id
  WHERE p.id = p_product_id;
  
  IF v_product IS NULL THEN
    RAISE EXCEPTION 'Producto no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Product retrieved';
  
  RETURN v_product;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_product: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener producto: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION get_admin_product IS 'Obtiene detalles de un producto específico con información de categoría';
