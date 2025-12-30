-- ============================================================================
-- STORED PROCEDURES: Coupons Management
-- ============================================================================
-- Propósito: Operaciones CRUD para cupones
-- ============================================================================

-- ============================================================================
-- 1. GET COUPONS
-- ============================================================================
CREATE OR REPLACE FUNCTION get_admin_coupons(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_coupons JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_coupons called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;
  
  SELECT json_agg(
    json_build_object(
      'id', id,
      'restaurant_id', restaurant_id,
      'code', code,
      'description', description,
      'type', type,
      'discount_percentage', discount_percentage,
      'discount_amount_cents', discount_amount_cents,
      'minimum_order_cents', minimum_order_cents,
      'maximum_discount_cents', maximum_discount_cents,
      'valid_from', valid_from,
      'valid_until', valid_until,
      'max_uses', max_uses,
      'max_uses_per_customer', max_uses_per_customer,
      'current_uses', current_uses,
      'is_active', is_active,
      'first_order_only', first_order_only,
      'specific_customer_ids', specific_customer_ids,
      'created_at', created_at
    )
    ORDER BY created_at DESC
  )
  INTO v_coupons
  FROM coupons
  WHERE restaurant_id = p_restaurant_id;
  
  RAISE NOTICE '✅ SUCCESS - Returning % coupons', json_array_length(COALESCE(v_coupons, '[]'::json));
  
  RETURN COALESCE(v_coupons, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_coupons: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener cupones: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. CREATE COUPON
-- ============================================================================
CREATE OR REPLACE FUNCTION create_admin_coupon(
  p_restaurant_id UUID,
  p_code VARCHAR,
  p_type VARCHAR,
  p_description TEXT DEFAULT NULL,
  p_discount_percentage INTEGER DEFAULT NULL,
  p_discount_amount_cents INTEGER DEFAULT NULL,
  p_minimum_order_cents INTEGER DEFAULT 0,
  p_maximum_discount_cents INTEGER DEFAULT NULL,
  p_valid_from TIMESTAMPTZ DEFAULT NOW(),
  p_valid_until TIMESTAMPTZ DEFAULT NULL,
  p_max_uses INTEGER DEFAULT NULL,
  p_max_uses_per_customer INTEGER DEFAULT 1,
  p_is_active BOOLEAN DEFAULT TRUE,
  p_first_order_only BOOLEAN DEFAULT FALSE,
  p_specific_customer_ids UUID[] DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_coupon JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - create_admin_coupon called';
  RAISE NOTICE '📦 DATA - code: %, type: %', p_code, p_type;
  
  INSERT INTO coupons (
    restaurant_id,
    code,
    description,
    type,
    discount_percentage,
    discount_amount_cents,
    minimum_order_cents,
    maximum_discount_cents,
    valid_from,
    valid_until,
    max_uses,
    max_uses_per_customer,
    is_active,
    first_order_only,
    specific_customer_ids
  ) VALUES (
    p_restaurant_id,
    p_code,
    p_description,
    p_type,
    p_discount_percentage,
    p_discount_amount_cents,
    p_minimum_order_cents,
    p_maximum_discount_cents,
    p_valid_from,
    p_valid_until,
    p_max_uses,
    p_max_uses_per_customer,
    p_is_active,
    p_first_order_only,
    p_specific_customer_ids
  )
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'code', code,
    'description', description,
    'type', type,
    'discount_percentage', discount_percentage,
    'discount_amount_cents', discount_amount_cents,
    'minimum_order_cents', minimum_order_cents,
    'maximum_discount_cents', maximum_discount_cents,
    'valid_from', valid_from,
    'valid_until', valid_until,
    'max_uses', max_uses,
    'max_uses_per_customer', max_uses_per_customer,
    'current_uses', current_uses,
    'is_active', is_active,
    'first_order_only', first_order_only,
    'specific_customer_ids', specific_customer_ids,
    'created_at', created_at
  )
  INTO v_coupon;
  
  RAISE NOTICE '✅ SUCCESS - Coupon created with id: %', (v_coupon->>'id');
  
  RETURN v_coupon;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in create_admin_coupon: %', SQLERRM;
    RAISE EXCEPTION 'Error al crear cupón: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 3. UPDATE COUPON
-- ============================================================================
CREATE OR REPLACE FUNCTION update_admin_coupon(
  p_coupon_id UUID,
  p_code VARCHAR DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_type VARCHAR DEFAULT NULL,
  p_discount_percentage INTEGER DEFAULT NULL,
  p_discount_amount_cents INTEGER DEFAULT NULL,
  p_minimum_order_cents INTEGER DEFAULT NULL,
  p_maximum_discount_cents INTEGER DEFAULT NULL,
  p_valid_from TIMESTAMPTZ DEFAULT NULL,
  p_valid_until TIMESTAMPTZ DEFAULT NULL,
  p_max_uses INTEGER DEFAULT NULL,
  p_max_uses_per_customer INTEGER DEFAULT NULL,
  p_is_active BOOLEAN DEFAULT NULL,
  p_first_order_only BOOLEAN DEFAULT NULL,
  p_specific_customer_ids UUID[] DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_coupon JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_coupon called';
  RAISE NOTICE '📦 DATA - coupon_id: %', p_coupon_id;
  
  UPDATE coupons
  SET
    code = COALESCE(p_code, code),
    description = COALESCE(p_description, description),
    type = COALESCE(p_type, type),
    discount_percentage = COALESCE(p_discount_percentage, discount_percentage),
    discount_amount_cents = COALESCE(p_discount_amount_cents, discount_amount_cents),
    minimum_order_cents = COALESCE(p_minimum_order_cents, minimum_order_cents),
    maximum_discount_cents = COALESCE(p_maximum_discount_cents, maximum_discount_cents),
    valid_from = COALESCE(p_valid_from, valid_from),
    valid_until = COALESCE(p_valid_until, valid_until),
    max_uses = COALESCE(p_max_uses, max_uses),
    max_uses_per_customer = COALESCE(p_max_uses_per_customer, max_uses_per_customer),
    is_active = COALESCE(p_is_active, is_active),
    first_order_only = COALESCE(p_first_order_only, first_order_only),
    specific_customer_ids = COALESCE(p_specific_customer_ids, specific_customer_ids)
  WHERE id = p_coupon_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'code', code,
    'description', description,
    'type', type,
    'discount_percentage', discount_percentage,
    'discount_amount_cents', discount_amount_cents,
    'minimum_order_cents', minimum_order_cents,
    'maximum_discount_cents', maximum_discount_cents,
    'valid_from', valid_from,
    'valid_until', valid_until,
    'max_uses', max_uses,
    'max_uses_per_customer', max_uses_per_customer,
    'current_uses', current_uses,
    'is_active', is_active,
    'first_order_only', first_order_only,
    'specific_customer_ids', specific_customer_ids,
    'created_at', created_at
  )
  INTO v_coupon;
  
  IF v_coupon IS NULL THEN
    RAISE EXCEPTION 'Cupón no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Coupon updated';
  
  RETURN v_coupon;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_admin_coupon: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar cupón: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 4. DELETE COUPON
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_admin_coupon(
  p_coupon_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - delete_admin_coupon called';
  RAISE NOTICE '📦 DATA - coupon_id: %', p_coupon_id;
  
  DELETE FROM coupons
  WHERE id = p_coupon_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cupón no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Coupon deleted';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in delete_admin_coupon: %', SQLERRM;
    RAISE EXCEPTION 'Error al eliminar cupón: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 5. TOGGLE COUPON STATUS
-- ============================================================================
CREATE OR REPLACE FUNCTION toggle_coupon_status(
  p_coupon_id UUID,
  p_is_active BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - toggle_coupon_status called';
  RAISE NOTICE '📦 DATA - coupon_id: %, is_active: %', p_coupon_id, p_is_active;
  
  UPDATE coupons
  SET is_active = p_is_active
  WHERE id = p_coupon_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cupón no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Coupon status toggled';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in toggle_coupon_status: %', SQLERRM;
    RAISE EXCEPTION 'Error al cambiar estado del cupón: %', SQLERRM;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION get_admin_coupons IS 'Obtiene lista de cupones del restaurante';
COMMENT ON FUNCTION create_admin_coupon IS 'Crea un nuevo cupón';
COMMENT ON FUNCTION update_admin_coupon IS 'Actualiza un cupón existente';
COMMENT ON FUNCTION delete_admin_coupon IS 'Elimina un cupón';
COMMENT ON FUNCTION toggle_coupon_status IS 'Cambia el estado activo/inactivo de un cupón';
