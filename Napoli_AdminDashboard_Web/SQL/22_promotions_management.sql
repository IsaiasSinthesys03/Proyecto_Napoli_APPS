-- ============================================================================
-- STORED PROCEDURES: Promotions Management
-- ============================================================================
-- Propósito: Operaciones CRUD para promociones
-- ============================================================================

-- ============================================================================
-- 1. GET PROMOTIONS
-- ============================================================================
CREATE OR REPLACE FUNCTION get_admin_promotions(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_promotions JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_promotions called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;
  
  SELECT json_agg(
    json_build_object(
      'id', id,
      'restaurant_id', restaurant_id,
      'name', name,
      'description', description,
      'type', type,
      'discount_percentage', discount_percentage,
      'discount_amount_cents', discount_amount_cents,
      'minimum_order_cents', minimum_order_cents,
      'maximum_discount_cents', maximum_discount_cents,
      'start_date', start_date,
      'end_date', end_date,
      'max_uses', max_uses,
      'max_uses_per_customer', max_uses_per_customer,
      'current_uses', current_uses,
      'image_url', image_url,
      'banner_url', banner_url,
      'is_active', is_active,
      'is_featured', is_featured,
      'created_at', created_at,
      'updated_at', updated_at
    )
    ORDER BY created_at DESC
  )
  INTO v_promotions
  FROM promotions
  WHERE restaurant_id = p_restaurant_id;
  
  RAISE NOTICE '✅ SUCCESS - Returning % promotions', json_array_length(COALESCE(v_promotions, '[]'::json));
  
  RETURN COALESCE(v_promotions, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_promotions: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener promociones: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. CREATE PROMOTION
-- ============================================================================
CREATE OR REPLACE FUNCTION create_admin_promotion(
  p_restaurant_id UUID,
  p_name VARCHAR,
  p_type VARCHAR,
  p_start_date TIMESTAMPTZ,
  p_end_date TIMESTAMPTZ,
  p_description TEXT DEFAULT NULL,
  p_discount_percentage INTEGER DEFAULT NULL,
  p_discount_amount_cents INTEGER DEFAULT NULL,
  p_minimum_order_cents INTEGER DEFAULT 0,
  p_maximum_discount_cents INTEGER DEFAULT NULL,
  p_max_uses INTEGER DEFAULT NULL,
  p_max_uses_per_customer INTEGER DEFAULT 1,
  p_image_url VARCHAR DEFAULT NULL,
  p_banner_url VARCHAR DEFAULT NULL,
  p_is_active BOOLEAN DEFAULT TRUE,
  p_is_featured BOOLEAN DEFAULT FALSE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_promotion JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - create_admin_promotion called';
  RAISE NOTICE '📦 DATA - name: %, type: %', p_name, p_type;
  
  INSERT INTO promotions (
    restaurant_id,
    name,
    description,
    type,
    discount_percentage,
    discount_amount_cents,
    minimum_order_cents,
    maximum_discount_cents,
    start_date,
    end_date,
    max_uses,
    max_uses_per_customer,
    image_url,
    banner_url,
    is_active,
    is_featured
  ) VALUES (
    p_restaurant_id,
    p_name,
    p_description,
    p_type,
    p_discount_percentage,
    p_discount_amount_cents,
    p_minimum_order_cents,
    p_maximum_discount_cents,
    p_start_date,
    p_end_date,
    p_max_uses,
    p_max_uses_per_customer,
    p_image_url,
    p_banner_url,
    p_is_active,
    p_is_featured
  )
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'description', description,
    'type', type,
    'discount_percentage', discount_percentage,
    'discount_amount_cents', discount_amount_cents,
    'minimum_order_cents', minimum_order_cents,
    'maximum_discount_cents', maximum_discount_cents,
    'start_date', start_date,
    'end_date', end_date,
    'max_uses', max_uses,
    'max_uses_per_customer', max_uses_per_customer,
    'current_uses', current_uses,
    'image_url', image_url,
    'banner_url', banner_url,
    'is_active', is_active,
    'is_featured', is_featured,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_promotion;
  
  RAISE NOTICE '✅ SUCCESS - Promotion created with id: %', (v_promotion->>'id');
  
  RETURN v_promotion;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in create_admin_promotion: %', SQLERRM;
    RAISE EXCEPTION 'Error al crear promoción: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 3. UPDATE PROMOTION
-- ============================================================================
CREATE OR REPLACE FUNCTION update_admin_promotion(
  p_promotion_id UUID,
  p_name VARCHAR DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_type VARCHAR DEFAULT NULL,
  p_discount_percentage INTEGER DEFAULT NULL,
  p_discount_amount_cents INTEGER DEFAULT NULL,
  p_minimum_order_cents INTEGER DEFAULT NULL,
  p_maximum_discount_cents INTEGER DEFAULT NULL,
  p_start_date TIMESTAMPTZ DEFAULT NULL,
  p_end_date TIMESTAMPTZ DEFAULT NULL,
  p_max_uses INTEGER DEFAULT NULL,
  p_max_uses_per_customer INTEGER DEFAULT NULL,
  p_image_url VARCHAR DEFAULT NULL,
  p_banner_url VARCHAR DEFAULT NULL,
  p_is_active BOOLEAN DEFAULT NULL,
  p_is_featured BOOLEAN DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_promotion JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_promotion called';
  RAISE NOTICE '📦 DATA - promotion_id: %', p_promotion_id;
  
  UPDATE promotions
  SET
    name = COALESCE(p_name, name),
    description = COALESCE(p_description, description),
    type = COALESCE(p_type, type),
    discount_percentage = COALESCE(p_discount_percentage, discount_percentage),
    discount_amount_cents = COALESCE(p_discount_amount_cents, discount_amount_cents),
    minimum_order_cents = COALESCE(p_minimum_order_cents, minimum_order_cents),
    maximum_discount_cents = COALESCE(p_maximum_discount_cents, maximum_discount_cents),
    start_date = COALESCE(p_start_date, start_date),
    end_date = COALESCE(p_end_date, end_date),
    max_uses = COALESCE(p_max_uses, max_uses),
    max_uses_per_customer = COALESCE(p_max_uses_per_customer, max_uses_per_customer),
    image_url = COALESCE(p_image_url, image_url),
    banner_url = COALESCE(p_banner_url, banner_url),
    is_active = COALESCE(p_is_active, is_active),
    is_featured = COALESCE(p_is_featured, is_featured),
    updated_at = NOW()
  WHERE id = p_promotion_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'description', description,
    'type', type,
    'discount_percentage', discount_percentage,
    'discount_amount_cents', discount_amount_cents,
    'minimum_order_cents', minimum_order_cents,
    'maximum_discount_cents', maximum_discount_cents,
    'start_date', start_date,
    'end_date', end_date,
    'max_uses', max_uses,
    'max_uses_per_customer', max_uses_per_customer,
    'current_uses', current_uses,
    'image_url', image_url,
    'banner_url', banner_url,
    'is_active', is_active,
    'is_featured', is_featured,
    'created_at', created_at,
    'updated_at', updated_at
  )
  INTO v_promotion;
  
  IF v_promotion IS NULL THEN
    RAISE EXCEPTION 'Promoción no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Promotion updated';
  
  RETURN v_promotion;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_admin_promotion: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar promoción: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 4. DELETE PROMOTION
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_admin_promotion(
  p_promotion_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - delete_admin_promotion called';
  RAISE NOTICE '📦 DATA - promotion_id: %', p_promotion_id;
  
  DELETE FROM promotions
  WHERE id = p_promotion_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Promoción no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Promotion deleted';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in delete_admin_promotion: %', SQLERRM;
    RAISE EXCEPTION 'Error al eliminar promoción: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 5. TOGGLE PROMOTION STATUS
-- ============================================================================
CREATE OR REPLACE FUNCTION toggle_promotion_status(
  p_promotion_id UUID,
  p_is_active BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - toggle_promotion_status called';
  RAISE NOTICE '📦 DATA - promotion_id: %, is_active: %', p_promotion_id, p_is_active;
  
  UPDATE promotions
  SET 
    is_active = p_is_active,
    updated_at = NOW()
  WHERE id = p_promotion_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Promoción no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Promotion status toggled';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in toggle_promotion_status: %', SQLERRM;
    RAISE EXCEPTION 'Error al cambiar estado de la promoción: %', SQLERRM;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION get_admin_promotions IS 'Obtiene lista de promociones del restaurante';
COMMENT ON FUNCTION create_admin_promotion IS 'Crea una nueva promoción';
COMMENT ON FUNCTION update_admin_promotion IS 'Actualiza una promoción existente';
COMMENT ON FUNCTION delete_admin_promotion IS 'Elimina una promoción';
COMMENT ON FUNCTION toggle_promotion_status IS 'Cambia el estado activo/inactivo de una promoción';
