-- ============================================================================
-- STORED PROCEDURE: login_customer
-- ============================================================================
-- Propósito: Obtener perfil completo del cliente después del login
-- Parámetros:
--   - p_email: Email del cliente
--   - p_restaurant_id: ID del restaurante
-- Retorna: JSON con perfil del cliente, direcciones y métodos de pago
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION login_customer(
  p_email TEXT,
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
  v_customer_id UUID;
BEGIN
  -- Log inicio de función
  RAISE NOTICE '🔍 DEBUG - login_customer called for email: %', p_email;
  
  -- Buscar cliente por email y restaurant_id
  SELECT id INTO v_customer_id
  FROM customers
  WHERE email = p_email
    AND restaurant_id = p_restaurant_id
  LIMIT 1;
  
  -- Si no existe el cliente, retornar NULL
  IF v_customer_id IS NULL THEN
    RAISE NOTICE '❌ ERROR - Customer not found for email: %', p_email;
    RETURN NULL;
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Customer found with ID: %', v_customer_id;
  
  -- Construir JSON con perfil completo
  SELECT json_build_object(
    'id', c.id,
    'name', c.name,
    'email', c.email,
    'phone', c.phone,
    'photo_url', c.photo_url,
    'loyalty_points', COALESCE(c.loyalty_points, 0),
    'loyalty_tier', c.loyalty_tier,
    'status', c.status,
    'created_at', c.created_at,
    'addresses', COALESCE((
      SELECT json_agg(
        json_build_object(
          'id', ca.id,
          'label', ca.label,
          'street_address', ca.street_address,
          'city', ca.city,
          'address_details', ca.address_details,
          'is_default', ca.is_default,
          'latitude', ca.latitude,
          'longitude', ca.longitude
        )
        ORDER BY ca.is_default DESC, ca.created_at DESC
      )
      FROM customer_addresses ca
      WHERE ca.customer_id = c.id
    ), '[]'::json),
    'payment_methods', COALESCE((
      SELECT json_agg(
        json_build_object(
          'id', pm.id,
          'type', pm.type,
          'card_holder_name', pm.card_holder_name,
          'card_brand', pm.card_brand,
          'card_last_four', pm.card_last_four,
          'is_default', pm.is_default
        )
        ORDER BY pm.is_default DESC, pm.created_at DESC
      )
      FROM customer_payment_methods pm
      WHERE pm.customer_id = c.id
    ), '[]'::json)
  )
  INTO v_result
  FROM customers c
  WHERE c.id = v_customer_id;
  
  RAISE NOTICE '📦 DATA - Profile built successfully';
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in login_customer: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener perfil del cliente: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION login_customer(TEXT, UUID) IS 
'Obtiene el perfil completo del cliente con direcciones y métodos de pago para el login';

-- Ejemplo de uso:
-- SELECT login_customer('cliente@example.com', 'restaurant-uuid-here');
