-- ============================================================================
-- STORED PROCEDURE: register_customer
-- ============================================================================
-- Propósito: Crear un nuevo cliente en el sistema
-- Parámetros:
--   - p_email: Email del cliente
--   - p_name: Nombre del cliente
--   - p_restaurant_id: ID del restaurante
-- Retorna: JSON con perfil del cliente creado
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION register_customer(
  p_email TEXT,
  p_name TEXT,
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_customer_id UUID;
  v_result JSON;
BEGIN
  -- Log inicio de función
  RAISE NOTICE '🔍 DEBUG - register_customer called for email: %, name: %', p_email, p_name;
  
  -- Verificar si el cliente ya existe
  SELECT id INTO v_customer_id
  FROM customers
  WHERE email = p_email
    AND restaurant_id = p_restaurant_id
  LIMIT 1;
  
  IF v_customer_id IS NOT NULL THEN
    RAISE NOTICE '❌ ERROR - Customer already exists with email: %', p_email;
    RAISE EXCEPTION 'El cliente ya existe con este email';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Email available, creating new customer';
  
  -- Insertar nuevo cliente
  INSERT INTO customers (
    restaurant_id,
    name,
    email,
    status,
    loyalty_points,
    total_orders_count,
    total_spent_cents,
    average_order_cents
  )
  VALUES (
    p_restaurant_id,
    p_name,
    p_email,
    'active',
    0,
    0,
    0,
    0
  )
  RETURNING id INTO v_customer_id;
  
  RAISE NOTICE '✅ SUCCESS - Customer created with ID: %', v_customer_id;
  
  -- Construir JSON con perfil del nuevo cliente
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
    'addresses', '[]'::json,
    'payment_methods', '[]'::json
  )
  INTO v_result
  FROM customers c
  WHERE c.id = v_customer_id;
  
  RAISE NOTICE '📦 DATA - Profile built successfully for new customer';
  
  RETURN v_result;
  
EXCEPTION
  WHEN unique_violation THEN
    RAISE NOTICE '❌ ERROR - Unique violation (customer already exists)';
    RAISE EXCEPTION 'El cliente ya existe con este email';
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in register_customer: %', SQLERRM;
    RAISE EXCEPTION 'Error al registrar cliente: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION register_customer(TEXT, TEXT, UUID) IS 
'Crea un nuevo cliente en el sistema y retorna su perfil completo';

-- Ejemplo de uso:
-- SELECT register_customer('nuevo@example.com', 'Juan Pérez', 'restaurant-uuid-here');
