-- ============================================================================
-- STORED PROCEDURE: validate_coupon
-- ============================================================================
-- Propósito: Validar un cupón y retornar sus detalles si es válido
-- Parámetros:
--   - p_code: Código del cupón
--   - p_restaurant_id: ID del restaurante
--   - p_customer_id: ID del cliente (opcional, para validar uso por cliente)
-- Retorna: JSON con los detalles del cupón o NULL si no es válido
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION validate_coupon(
  p_code TEXT,
  p_restaurant_id UUID,
  p_customer_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_coupon RECORD;
  v_customer_usage_count INT;
  v_result JSON;
BEGIN
  -- Log inicio de función
  RAISE NOTICE '🔍 DEBUG - validate_coupon called for code: %', p_code;
  
  -- Normalizar código (uppercase, trim)
  p_code := UPPER(TRIM(p_code));
  
  -- Buscar cupón activo
  SELECT *
  INTO v_coupon
  FROM coupons
  WHERE restaurant_id = p_restaurant_id
    AND code = p_code
    AND is_active = true;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Coupon not found or inactive: %', p_code;
    RETURN NULL;
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Coupon found: %', v_coupon.id;
  
  -- Validar fechas de vigencia
  IF v_coupon.valid_from IS NOT NULL AND NOW() < v_coupon.valid_from THEN
    RAISE NOTICE '❌ ERROR - Coupon not yet valid. Valid from: %', v_coupon.valid_from;
    RETURN NULL;
  END IF;
  
  IF v_coupon.valid_until IS NOT NULL AND NOW() > v_coupon.valid_until THEN
    RAISE NOTICE '❌ ERROR - Coupon expired. Valid until: %', v_coupon.valid_until;
    RETURN NULL;
  END IF;
  
  -- Validar límite de usos totales
  IF v_coupon.max_uses IS NOT NULL AND v_coupon.current_uses >= v_coupon.max_uses THEN
    RAISE NOTICE '❌ ERROR - Coupon usage limit reached: %/%', v_coupon.current_uses, v_coupon.max_uses;
    RETURN NULL;
  END IF;
  
  -- Validar uso por cliente (si se proporciona customer_id)
  IF p_customer_id IS NOT NULL THEN
    -- Contar cuántas veces el cliente ha usado este cupón
    SELECT COUNT(*)
    INTO v_customer_usage_count
    FROM customer_coupons
    WHERE customer_id = p_customer_id
      AND coupon_id = v_coupon.id;
    
    IF v_coupon.max_uses_per_customer IS NOT NULL 
       AND v_customer_usage_count >= v_coupon.max_uses_per_customer THEN
      RAISE NOTICE '❌ ERROR - Customer usage limit reached: %/%', 
        v_customer_usage_count, v_coupon.max_uses_per_customer;
      RETURN NULL;
    END IF;
    
    -- Validar si es solo para primera orden
    IF v_coupon.first_order_only = true THEN
      DECLARE
        v_customer_order_count INT;
      BEGIN
        SELECT COUNT(*)
        INTO v_customer_order_count
        FROM orders
        WHERE customer_id = p_customer_id
          AND restaurant_id = p_restaurant_id;
        
        IF v_customer_order_count > 0 THEN
          RAISE NOTICE '❌ ERROR - Coupon is for first order only';
          RETURN NULL;
        END IF;
      END;
    END IF;
    
    -- Validar si es para clientes específicos
    IF v_coupon.specific_customer_ids IS NOT NULL 
       AND array_length(v_coupon.specific_customer_ids, 1) > 0 THEN
      IF NOT (p_customer_id = ANY(v_coupon.specific_customer_ids)) THEN
        RAISE NOTICE '❌ ERROR - Coupon not available for this customer';
        RETURN NULL;
      END IF;
    END IF;
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Coupon is valid';
  
  -- Construir respuesta JSON
  SELECT json_build_object(
    'id', v_coupon.id,
    'code', v_coupon.code,
    'description', v_coupon.description,
    'type', v_coupon.type,
    'discount_percentage', v_coupon.discount_percentage,
    'discount_amount_cents', v_coupon.discount_amount_cents,
    'minimum_order_cents', v_coupon.minimum_order_cents,
    'maximum_discount_cents', v_coupon.maximum_discount_cents,
    'valid_from', v_coupon.valid_from,
    'valid_until', v_coupon.valid_until,
    'current_uses', v_coupon.current_uses,
    'max_uses', v_coupon.max_uses
  )
  INTO v_result;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in validate_coupon: %', SQLERRM;
    RAISE EXCEPTION 'Error al validar cupón: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION validate_coupon(TEXT, UUID, UUID) IS 
'Valida un cupón y retorna sus detalles si es válido';

-- Ejemplo de uso:
-- SELECT validate_coupon('WELCOME10', 'restaurant-uuid', 'customer-uuid');
