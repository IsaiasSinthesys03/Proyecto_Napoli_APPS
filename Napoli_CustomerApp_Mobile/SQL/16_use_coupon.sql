-- ============================================================================
-- STORED PROCEDURE: use_coupon
-- ============================================================================
-- Propósito: Registrar el uso de un cupón por un cliente
-- Parámetros:
--   - p_customer_id: ID del cliente
--   - p_coupon_id: ID del cupón
--   - p_restaurant_id: ID del restaurante
--   - p_order_id: ID de la orden (opcional)
-- Retorna: JSON con confirmación
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION use_coupon(
  p_customer_id UUID,
  p_coupon_id UUID,
  p_restaurant_id UUID,
  p_order_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Log inicio de función
  RAISE NOTICE '🔍 DEBUG - use_coupon called';
  RAISE NOTICE '📦 DATA - customer_id: %, coupon_id: %', p_customer_id, p_coupon_id;
  
  -- Insertar registro de uso en customer_coupons
  INSERT INTO customer_coupons (
    customer_id,
    coupon_id,
    restaurant_id,
    used_at,
    order_id
  )
  VALUES (
    p_customer_id,
    p_coupon_id,
    p_restaurant_id,
    NOW(),
    p_order_id
  );
  
  RAISE NOTICE '✅ SUCCESS - Coupon usage recorded in customer_coupons';
  
  -- Incrementar contador de usos del cupón
  UPDATE coupons
  SET current_uses = current_uses + 1
  WHERE id = p_coupon_id;
  
  RAISE NOTICE '✅ SUCCESS - Coupon usage count incremented';
  
  -- Construir respuesta
  SELECT json_build_object(
    'success', true,
    'customer_id', p_customer_id,
    'coupon_id', p_coupon_id,
    'used_at', NOW()
  )
  INTO v_result;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in use_coupon: %', SQLERRM;
    RAISE EXCEPTION 'Error al usar cupón: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION use_coupon(UUID, UUID, UUID, UUID) IS 
'Registra el uso de un cupón por un cliente e incrementa el contador';

-- Ejemplo de uso:
-- SELECT use_coupon('customer-uuid', 'coupon-uuid', 'restaurant-uuid', 'order-uuid');
