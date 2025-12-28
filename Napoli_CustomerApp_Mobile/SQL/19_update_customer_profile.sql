-- ============================================================================
-- STORED PROCEDURE: update_customer_profile
-- ============================================================================
-- Propósito: Actualizar información del perfil del cliente
-- Parámetros:
--   - p_customer_id: ID del cliente
--   - p_name: Nombre del cliente
--   - p_phone: Teléfono del cliente
-- Retorna: JSON con el perfil actualizado
-- Autor: AI Assistant
-- Fecha: 2024-12-27
-- ============================================================================

CREATE OR REPLACE FUNCTION update_customer_profile(
  p_customer_id UUID,
  p_name TEXT,
  p_phone TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_customer_profile called for customer: %', p_customer_id;
  
  -- Actualizar perfil
  UPDATE customers
  SET 
    name = p_name,
    phone = COALESCE(p_phone, phone),
    updated_at = NOW()
  WHERE id = p_customer_id;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ ERROR - Customer not found: %', p_customer_id;
    RAISE EXCEPTION 'Cliente no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Profile updated';
  
  -- Retornar perfil actualizado
  SELECT json_build_object(
    'id', id,
    'name', name,
    'email', email,
    'phone', phone,
    'updated_at', updated_at
  )
  INTO v_result
  FROM customers
  WHERE id = p_customer_id;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_customer_profile: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar perfil: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION update_customer_profile(UUID, TEXT, TEXT) IS 
'Actualiza el perfil del cliente';
