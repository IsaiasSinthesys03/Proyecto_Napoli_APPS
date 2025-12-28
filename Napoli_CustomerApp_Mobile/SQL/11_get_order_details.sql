-- ============================================================================
-- STORED PROCEDURE: get_order_details
-- ============================================================================
-- Propósito: Obtener detalles completos de una orden específica
-- Parámetros:
--   - p_order_id: ID de la orden
--   - p_customer_id: ID del cliente (para seguridad)
-- Retorna: JSON con la orden y sus items
-- Autor: AI Assistant
-- Fecha: 2024-12-26
-- ============================================================================

CREATE OR REPLACE FUNCTION get_order_details(
  p_order_id UUID,
  p_customer_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Log inicio de función
  RAISE NOTICE '🔍 DEBUG - get_order_details called for order_id: %', p_order_id;
  
  -- Construir JSON con orden e items
  SELECT json_build_object(
    'id', o.id,
    'restaurant_id', o.restaurant_id,
    'customer_id', o.customer_id,
    'status', o.status,
    'subtotal_cents', o.subtotal_cents,
    'delivery_fee_cents', o.delivery_fee_cents,
    'discount_cents', o.discount_cents,
    'total_cents', o.total_cents,
    'payment_method', o.payment_method,
    'order_type', o.order_type,
    'address_snapshot', o.address_snapshot,
    'customer_snapshot', o.customer_snapshot,
    'created_at', o.created_at,
    'updated_at', o.updated_at,
    'order_items', COALESCE((
      SELECT json_agg(
        json_build_object(
          'id', oi.id,
          'order_id', oi.order_id,
          'product_id', oi.product_id,
          'product_name', oi.product_name,
          'quantity', oi.quantity,
          'unit_price_cents', oi.unit_price_cents,
          'subtotal_cents', oi.subtotal_cents,
          'addons_snapshot', oi.addons_snapshot
        )
      )
      FROM order_items oi
      WHERE oi.order_id = o.id
    ), '[]'::json)
  )
  INTO v_result
  FROM orders o
  WHERE o.id = p_order_id
    AND o.customer_id = p_customer_id;  -- Security: solo el cliente dueño puede ver la orden
  
  IF v_result IS NULL THEN
    RAISE NOTICE '❌ ERROR - Order not found or access denied: %', p_order_id;
    RETURN NULL;
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Order details retrieved successfully';
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_order_details: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener detalles de orden: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION get_order_details(UUID, UUID) IS 
'Obtiene los detalles completos de una orden específica con sus items';

-- Ejemplo de uso:
-- SELECT get_order_details('order-uuid', 'customer-uuid');
