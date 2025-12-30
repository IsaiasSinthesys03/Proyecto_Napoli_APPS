-- ============================================================================
-- STORED PROCEDURES: Product Management (Create, Update, Delete, Toggle)
-- ============================================================================
-- Propósito: Operaciones CRUD para productos
-- ============================================================================

-- ============================================================================
-- 1. CREATE PRODUCT
-- ============================================================================
CREATE OR REPLACE FUNCTION create_admin_product(
  p_restaurant_id UUID,
  p_name VARCHAR,
  p_price_cents INTEGER,
  p_description TEXT DEFAULT NULL,
  p_short_description VARCHAR DEFAULT NULL,
  p_compare_at_price_cents INTEGER DEFAULT NULL,
  p_category_id UUID DEFAULT NULL,
  p_image_url VARCHAR DEFAULT NULL,
  p_is_available BOOLEAN DEFAULT TRUE,
  p_is_featured BOOLEAN DEFAULT FALSE,
  p_tags JSONB DEFAULT '[]'::jsonb,
  p_allergens JSONB DEFAULT '[]'::jsonb,
  p_preparation_time_minutes INTEGER DEFAULT NULL,
  p_calories INTEGER DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_product JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - create_admin_product called';
  RAISE NOTICE '📦 DATA - name: %, price_cents: %', p_name, p_price_cents;
  
  INSERT INTO products (
    restaurant_id,
    name,
    description,
    short_description,
    price_cents,
    compare_at_price_cents,
    category_id,
    image_url,
    is_available,
    is_featured,
    tags,
    allergens,
    preparation_time_minutes,
    calories
  ) VALUES (
    p_restaurant_id,
    p_name,
    p_description,
    p_short_description,
    p_price_cents,
    p_compare_at_price_cents,
    p_category_id,
    p_image_url,
    p_is_available,
    p_is_featured,
    p_tags,
    p_allergens,
    p_preparation_time_minutes,
    p_calories
  )
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'category_id', category_id,
    'name', name,
    'description', description,
    'short_description', short_description,
    'price_cents', price_cents,
    'compare_at_price_cents', compare_at_price_cents,
    'cost_cents', cost_cents,
    'image_url', image_url,
    'images', images,
    'is_available', is_available,
    'track_inventory', track_inventory,
    'inventory_count', inventory_count,
    'low_stock_threshold', low_stock_threshold,
    'is_featured', is_featured,
    'is_new', is_new,
    'is_bestseller', is_bestseller,
    'calories', calories,
    'preparation_time_minutes', preparation_time_minutes,
    'tags', tags,
    'allergens', allergens,
    'display_order', display_order,
    'total_sold', total_sold,
    'total_revenue_cents', total_revenue_cents,
    'rating_sum', rating_sum,
    'rating_count', rating_count,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_product;
  
  RAISE NOTICE '✅ SUCCESS - Product created with id: %', (v_product->>'id');
  
  RETURN v_product;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in create_admin_product: %', SQLERRM;
    RAISE EXCEPTION 'Error al crear producto: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. UPDATE PRODUCT
-- ============================================================================
CREATE OR REPLACE FUNCTION update_admin_product(
  p_product_id UUID,
  p_name VARCHAR DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_short_description VARCHAR DEFAULT NULL,
  p_price_cents INTEGER DEFAULT NULL,
  p_compare_at_price_cents INTEGER DEFAULT NULL,
  p_category_id UUID DEFAULT NULL,
  p_image_url VARCHAR DEFAULT NULL,
  p_is_available BOOLEAN DEFAULT NULL,
  p_is_featured BOOLEAN DEFAULT NULL,
  p_is_new BOOLEAN DEFAULT NULL,
  p_is_bestseller BOOLEAN DEFAULT NULL,
  p_tags JSONB DEFAULT NULL,
  p_allergens JSONB DEFAULT NULL,
  p_preparation_time_minutes INTEGER DEFAULT NULL,
  p_calories INTEGER DEFAULT NULL,
  p_display_order INTEGER DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_product JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_product called';
  RAISE NOTICE '📦 DATA - product_id: %', p_product_id;
  
  UPDATE products
  SET
    name = COALESCE(p_name, name),
    description = COALESCE(p_description, description),
    short_description = COALESCE(p_short_description, short_description),
    price_cents = COALESCE(p_price_cents, price_cents),
    compare_at_price_cents = COALESCE(p_compare_at_price_cents, compare_at_price_cents),
    category_id = CASE WHEN p_category_id IS NOT NULL THEN p_category_id ELSE category_id END,
    image_url = COALESCE(p_image_url, image_url),
    is_available = COALESCE(p_is_available, is_available),
    is_featured = COALESCE(p_is_featured, is_featured),
    is_new = COALESCE(p_is_new, is_new),
    is_bestseller = COALESCE(p_is_bestseller, is_bestseller),
    tags = COALESCE(p_tags, tags),
    allergens = COALESCE(p_allergens, allergens),
    preparation_time_minutes = COALESCE(p_preparation_time_minutes, preparation_time_minutes),
    calories = COALESCE(p_calories, calories),
    display_order = COALESCE(p_display_order, display_order),
    updated_at = NOW()
  WHERE id = p_product_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'category_id', category_id,
    'name', name,
    'description', description,
    'short_description', short_description,
    'price_cents', price_cents,
    'compare_at_price_cents', compare_at_price_cents,
    'cost_cents', cost_cents,
    'image_url', image_url,
    'images', images,
    'is_available', is_available,
    'track_inventory', track_inventory,
    'inventory_count', inventory_count,
    'low_stock_threshold', low_stock_threshold,
    'is_featured', is_featured,
    'is_new', is_new,
    'is_bestseller', is_bestseller,
    'calories', calories,
    'preparation_time_minutes', preparation_time_minutes,
    'tags', tags,
    'allergens', allergens,
    'display_order', display_order,
    'total_sold', total_sold,
    'total_revenue_cents', total_revenue_cents,
    'rating_sum', rating_sum,
    'rating_count', rating_count,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_product;
  
  IF v_product IS NULL THEN
    RAISE EXCEPTION 'Producto no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Product updated';
  
  RETURN v_product;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_admin_product: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar producto: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 3. DELETE PRODUCT
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_admin_product(
  p_product_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - delete_admin_product called';
  RAISE NOTICE '📦 DATA - product_id: %', p_product_id;
  
  DELETE FROM products
  WHERE id = p_product_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Producto no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Product deleted';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in delete_admin_product: %', SQLERRM;
    RAISE EXCEPTION 'Error al eliminar producto: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 4. TOGGLE PRODUCT AVAILABILITY
-- ============================================================================
CREATE OR REPLACE FUNCTION toggle_admin_product_availability(
  p_product_id UUID,
  p_is_available BOOLEAN
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_product JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - toggle_admin_product_availability called';
  RAISE NOTICE '📦 DATA - product_id: %, is_available: %', p_product_id, p_is_available;
  
  UPDATE products
  SET
    is_available = p_is_available,
    updated_at = NOW()
  WHERE id = p_product_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'category_id', category_id,
    'name', name,
    'description', description,
    'short_description', short_description,
    'price_cents', price_cents,
    'compare_at_price_cents', compare_at_price_cents,
    'cost_cents', cost_cents,
    'image_url', image_url,
    'images', images,
    'is_available', is_available,
    'track_inventory', track_inventory,
    'inventory_count', inventory_count,
    'low_stock_threshold', low_stock_threshold,
    'is_featured', is_featured,
    'is_new', is_new,
    'is_bestseller', is_bestseller,
    'calories', calories,
    'preparation_time_minutes', preparation_time_minutes,
    'tags', tags,
    'allergens', allergens,
    'display_order', display_order,
    'total_sold', total_sold,
    'total_revenue_cents', total_revenue_cents,
    'rating_sum', rating_sum,
    'rating_count', rating_count,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_product;
  
  IF v_product IS NULL THEN
    RAISE EXCEPTION 'Producto no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Product availability toggled';
  
  RETURN v_product;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in toggle_admin_product_availability: %', SQLERRM;
    RAISE EXCEPTION 'Error al cambiar disponibilidad: %', SQLERRM;
END;
$$;

-- Comentarios de las funciones
COMMENT ON FUNCTION create_admin_product IS 'Crea un nuevo producto para el restaurante';
COMMENT ON FUNCTION update_admin_product IS 'Actualiza un producto existente';
COMMENT ON FUNCTION delete_admin_product IS 'Elimina un producto';
COMMENT ON FUNCTION toggle_admin_product_availability IS 'Cambia la disponibilidad de un producto';
