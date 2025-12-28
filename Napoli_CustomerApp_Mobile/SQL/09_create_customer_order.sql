-- ============================================================================
-- STORED PROCEDURE: create_customer_order
-- ============================================================================
-- Propósito: Crear una orden con sus items en una transacción
-- Parámetros:
--   - p_customer_id: ID del cliente
--   - p_restaurant_id: ID del restaurante
--   - p_items: JSONB array con los items de la orden
--   - p_address_snapshot: JSONB con la dirección de entrega
--   - p_payment_method: Método de pago
--   - p_subtotal_cents: Subtotal en centavos
--   - p_delivery_fee_cents: Costo de envío en centavos
--   - p_discount_cents: Descuento en centavos
--   - p_total_cents: Total en centavos
-- Retorna: JSON con la orden creada
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION create_customer_order(
  p_customer_id UUID,
  p_restaurant_id UUID,
  p_items JSONB,
  p_address_snapshot JSONB,
  p_payment_method TEXT,
  p_subtotal_cents INT,
  p_total_cents INT,
  p_delivery_fee_cents INT DEFAULT 0,
  p_discount_cents INT DEFAULT 0
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id UUID;
  v_customer_snapshot JSONB;
  v_item JSONB;
  v_result JSON;
BEGIN
  -- Log inicio de función
  RAISE NOTICE '🔍 DEBUG - create_customer_order called for customer_id: %', p_customer_id;
  
  -- Obtener snapshot del cliente
  SELECT jsonb_build_object(
    'name', name,
    'email', email,
    'phone', phone
  )
  INTO v_customer_snapshot
  FROM customers
  WHERE id = p_customer_id
    AND restaurant_id = p_restaurant_id;
  
  IF v_customer_snapshot IS NULL THEN
    RAISE NOTICE '❌ ERROR - Customer not found: %', p_customer_id;
    RAISE EXCEPTION 'Cliente no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Customer snapshot created';
  
  -- Crear orden
  INSERT INTO orders (
    restaurant_id,
    customer_id,
    status,
    subtotal_cents,
    tax_cents,
    delivery_fee_cents,
    tip_cents,
    discount_cents,
    total_cents,
    payment_method,
    payment_status,
    order_type,
    address_snapshot,
    customer_snapshot,
    estimated_prep_minutes,
    estimated_delivery_minutes
  )
  VALUES (
    p_restaurant_id,
    p_customer_id,
    'pending',
    p_subtotal_cents,
    0,  -- tax_cents
    p_delivery_fee_cents,
    0,  -- tip_cents
    p_discount_cents,
    p_total_cents,
    p_payment_method,
    'pending',  -- payment_status
    'delivery',
    p_address_snapshot,
    v_customer_snapshot,
    30,  -- estimated_prep_minutes (default)
    20   -- estimated_delivery_minutes (default)
  )
  RETURNING id INTO v_order_id;
  
  RAISE NOTICE '✅ SUCCESS - Order created with ID: %', v_order_id;
  RAISE NOTICE '📦 DATA - Inserting % items', jsonb_array_length(p_items);
  
  -- Insertar items
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    DECLARE
      v_product_uuid UUID;
    BEGIN
      -- Try to cast to UUID, use NULL if fails
      BEGIN
        v_product_uuid := (v_item->>'product_id')::UUID;
      EXCEPTION WHEN OTHERS THEN
        v_product_uuid := NULL;
        RAISE NOTICE '⚠️ WARNING - Invalid product_id: %, using NULL', v_item->>'product_id';
      END;
      
      INSERT INTO order_items (
        order_id,
        product_id,
        product_name,
        quantity,
        unit_price_cents,
        total_price_cents,
        notes
      )
      VALUES (
        v_order_id,
        v_product_uuid,
        v_item->>'product_name',
        (v_item->>'quantity')::INT,
        (v_item->>'unit_price_cents')::INT,
        (v_item->>'total_price_cents')::INT,
        COALESCE(v_item->>'notes', '')
      );
    END;
  END LOOP;
  
  RAISE NOTICE '✅ SUCCESS - All items inserted';
  
  -- Retornar orden creada
  SELECT json_build_object(
    'id', v_order_id,
    'status', 'pending',
    'created_at', NOW()
  )
  INTO v_result;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in create_customer_order: %', SQLERRM;
    RAISE EXCEPTION 'Error al crear orden: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION create_customer_order(UUID, UUID, JSONB, JSONB, TEXT, INT, INT, INT, INT) IS 
'Crea una orden con sus items en una transacción';

-- Ejemplo de uso:
-- SELECT create_customer_order(
--   'customer-uuid',
--   'restaurant-uuid',
--   '[{"product_id":"prod-uuid","product_name":"Pizza","quantity":1,"unit_price_cents":1000,"subtotal_cents":1000,"addons":[]}]'::jsonb,
--   '{"street":"Calle 123","city":"Ciudad","lat":0.0,"lng":0.0}'::jsonb,
--   'cash',
--   1000,
--   0,
--   0,
--   1000
-- );
