-- ============================================================================
-- STORED PROCEDURES: Payment Method Management
-- ============================================================================
-- Propósito: Gestión de métodos de pago del cliente
-- Autor: AI Assistant
-- Fecha: 2024-12-27
-- ============================================================================

-- ============================================================================
-- 1. ADD PAYMENT METHOD
-- ============================================================================
CREATE OR REPLACE FUNCTION add_payment_method(
  p_customer_id UUID,
  p_restaurant_id UUID,
  p_type TEXT,
  p_label TEXT DEFAULT NULL,
  p_card_last_four TEXT DEFAULT NULL,
  p_card_brand TEXT DEFAULT NULL,
  p_card_holder_name TEXT DEFAULT NULL,
  p_expiry_month INT DEFAULT NULL,
  p_expiry_year INT DEFAULT NULL,
  p_payment_processor TEXT DEFAULT NULL,
  p_payment_token TEXT DEFAULT NULL,
  p_is_default BOOLEAN DEFAULT false
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_payment_id UUID;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - add_payment_method called';
  RAISE NOTICE '📦 DATA - customer_id: %, type: %', p_customer_id, p_type;
  
  -- Si es método por defecto, quitar default de los demás
  IF p_is_default THEN
    UPDATE customer_payment_methods
    SET is_default = false
    WHERE customer_id = p_customer_id
      AND restaurant_id = p_restaurant_id;
    
    RAISE NOTICE '✅ SUCCESS - Removed default from other payment methods';
  END IF;
  
  -- Insertar nuevo método de pago
  INSERT INTO customer_payment_methods (
    customer_id,
    restaurant_id,
    type,
    label,
    card_last_four,
    card_brand,
    card_holder_name,
    expiry_month,
    expiry_year,
    payment_processor,
    payment_token,
    is_default
  )
  VALUES (
    p_customer_id,
    p_restaurant_id,
    p_type::payment_method_type,
    p_label,
    p_card_last_four,
    p_card_brand,
    p_card_holder_name,
    p_expiry_month,
    p_expiry_year,
    p_payment_processor,
    p_payment_token,
    p_is_default
  )
  RETURNING id INTO v_payment_id;
  
  RAISE NOTICE '✅ SUCCESS - Payment method created with ID: %', v_payment_id;
  
  -- Retornar método de pago creado (sin payment_token por seguridad)
  SELECT json_build_object(
    'id', id,
    'type', type,
    'label', label,
    'card_last_four', card_last_four,
    'card_brand', card_brand,
    'card_holder_name', card_holder_name,
    'expiry_month', expiry_month,
    'expiry_year', expiry_year,
    'is_default', is_default,
    'created_at', created_at
  )
  INTO v_result
  FROM customer_payment_methods
  WHERE id = v_payment_id;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in add_payment_method: %', SQLERRM;
    RAISE EXCEPTION 'Error al agregar método de pago: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. DELETE PAYMENT METHOD
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_payment_method(
  p_payment_id UUID,
  p_customer_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - delete_payment_method called';
  RAISE NOTICE '📦 DATA - payment_id: %, customer_id: %', p_payment_id, p_customer_id;
  
  -- Eliminar método de pago (solo si pertenece al cliente)
  DELETE FROM customer_payment_methods
  WHERE id = p_payment_id AND customer_id = p_customer_id;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Payment method not found or not owned by customer';
    RAISE EXCEPTION 'Método de pago no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Payment method deleted';
  
  RETURN json_build_object('success', true, 'deleted_id', p_payment_id);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in delete_payment_method: %', SQLERRM;
    RAISE EXCEPTION 'Error al eliminar método de pago: %', SQLERRM;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION add_payment_method IS 'Agrega un nuevo método de pago para el cliente';
COMMENT ON FUNCTION delete_payment_method IS 'Elimina un método de pago del cliente';
