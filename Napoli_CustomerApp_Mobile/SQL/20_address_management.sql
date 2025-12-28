-- ============================================================================
-- STORED PROCEDURES: Address Management
-- ============================================================================
-- Propósito: Gestión completa de direcciones del cliente
-- Autor: AI Assistant
-- Fecha: 2024-12-27
-- ============================================================================

-- ============================================================================
-- 1. ADD ADDRESS
-- ============================================================================
CREATE OR REPLACE FUNCTION add_customer_address(
  p_customer_id UUID,
  p_restaurant_id UUID,
  p_label TEXT,
  p_street_address TEXT,
  p_address_details TEXT DEFAULT NULL,
  p_city TEXT DEFAULT NULL,
  p_state TEXT DEFAULT NULL,
  p_postal_code TEXT DEFAULT NULL,
  p_country TEXT DEFAULT NULL,
  p_latitude NUMERIC DEFAULT NULL,
  p_longitude NUMERIC DEFAULT NULL,
  p_delivery_instructions TEXT DEFAULT NULL,
  p_is_default BOOLEAN DEFAULT false
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_address_id UUID;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - add_customer_address called';
  RAISE NOTICE '📦 DATA - customer_id: %, label: %', p_customer_id, p_label;
  
  -- Si es dirección por defecto, quitar default de las demás
  IF p_is_default THEN
    UPDATE customer_addresses
    SET is_default = false
    WHERE customer_id = p_customer_id
      AND restaurant_id = p_restaurant_id;
    
    RAISE NOTICE '✅ SUCCESS - Removed default from other addresses';
  END IF;
  
  -- Insertar nueva dirección
  INSERT INTO customer_addresses (
    customer_id,
    restaurant_id,
    label,
    street_address,
    address_details,
    city,
    state,
    postal_code,
    country,
    latitude,
    longitude,
    delivery_instructions,
    is_default
  )
  VALUES (
    p_customer_id,
    p_restaurant_id,
    p_label,
    p_street_address,
    p_address_details,
    p_city,
    p_state,
    p_postal_code,
    p_country,
    p_latitude,
    p_longitude,
    p_delivery_instructions,
    p_is_default
  )
  RETURNING id INTO v_address_id;
  
  RAISE NOTICE '✅ SUCCESS - Address created with ID: %', v_address_id;
  
  -- Retornar dirección creada
  SELECT json_build_object(
    'id', id,
    'label', label,
    'street_address', street_address,
    'address_details', address_details,
    'city', city,
    'state', state,
    'postal_code', postal_code,
    'country', country,
    'latitude', latitude,
    'longitude', longitude,
    'delivery_instructions', delivery_instructions,
    'is_default', is_default,
    'created_at', created_at
  )
  INTO v_result
  FROM customer_addresses
  WHERE id = v_address_id;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in add_customer_address: %', SQLERRM;
    RAISE EXCEPTION 'Error al agregar dirección: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. UPDATE ADDRESS
-- ============================================================================
CREATE OR REPLACE FUNCTION update_customer_address(
  p_address_id UUID,
  p_customer_id UUID,
  p_label TEXT DEFAULT NULL,
  p_street_address TEXT DEFAULT NULL,
  p_address_details TEXT DEFAULT NULL,
  p_city TEXT DEFAULT NULL,
  p_state TEXT DEFAULT NULL,
  p_postal_code TEXT DEFAULT NULL,
  p_country TEXT DEFAULT NULL,
  p_latitude NUMERIC DEFAULT NULL,
  p_longitude NUMERIC DEFAULT NULL,
  p_delivery_instructions TEXT DEFAULT NULL,
  p_is_default BOOLEAN DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_restaurant_id UUID;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_customer_address called';
  RAISE NOTICE '📦 DATA - address_id: %, customer_id: %', p_address_id, p_customer_id;
  
  -- Verificar que la dirección pertenece al cliente
  SELECT restaurant_id INTO v_restaurant_id
  FROM customer_addresses
  WHERE id = p_address_id AND customer_id = p_customer_id;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Address not found or not owned by customer';
    RAISE EXCEPTION 'Dirección no encontrada';
  END IF;
  
  -- Si se marca como default, quitar default de las demás
  IF p_is_default = true THEN
    UPDATE customer_addresses
    SET is_default = false
    WHERE customer_id = p_customer_id
      AND restaurant_id = v_restaurant_id
      AND id != p_address_id;
    
    RAISE NOTICE '✅ SUCCESS - Removed default from other addresses';
  END IF;
  
  -- Actualizar dirección
  UPDATE customer_addresses
  SET
    label = COALESCE(p_label, label),
    street_address = COALESCE(p_street_address, street_address),
    address_details = COALESCE(p_address_details, address_details),
    city = COALESCE(p_city, city),
    state = COALESCE(p_state, state),
    postal_code = COALESCE(p_postal_code, postal_code),
    country = COALESCE(p_country, country),
    latitude = COALESCE(p_latitude, latitude),
    longitude = COALESCE(p_longitude, longitude),
    delivery_instructions = COALESCE(p_delivery_instructions, delivery_instructions),
    is_default = COALESCE(p_is_default, is_default)
  WHERE id = p_address_id AND customer_id = p_customer_id;
  
  RAISE NOTICE '✅ SUCCESS - Address updated';
  
  -- Retornar dirección actualizada
  SELECT json_build_object(
    'id', id,
    'label', label,
    'street_address', street_address,
    'address_details', address_details,
    'city', city,
    'state', state,
    'postal_code', postal_code,
    'country', country,
    'latitude', latitude,
    'longitude', longitude,
    'delivery_instructions', delivery_instructions,
    'is_default', is_default
  )
  INTO v_result
  FROM customer_addresses
  WHERE id = p_address_id;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_customer_address: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar dirección: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 3. DELETE ADDRESS
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_customer_address(
  p_address_id UUID,
  p_customer_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - delete_customer_address called';
  RAISE NOTICE '📦 DATA - address_id: %, customer_id: %', p_address_id, p_customer_id;
  
  -- Eliminar dirección (solo si pertenece al cliente)
  DELETE FROM customer_addresses
  WHERE id = p_address_id AND customer_id = p_customer_id;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Address not found or not owned by customer';
    RAISE EXCEPTION 'Dirección no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Address deleted';
  
  RETURN json_build_object('success', true, 'deleted_id', p_address_id);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in delete_customer_address: %', SQLERRM;
    RAISE EXCEPTION 'Error al eliminar dirección: %', SQLERRM;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION add_customer_address IS 'Agrega una nueva dirección para el cliente';
COMMENT ON FUNCTION update_customer_address IS 'Actualiza una dirección existente del cliente';
COMMENT ON FUNCTION delete_customer_address IS 'Elimina una dirección del cliente';
