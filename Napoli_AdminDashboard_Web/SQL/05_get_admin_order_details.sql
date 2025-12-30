-- ============================================================================
-- STORED PROCEDURE: get_admin_order_details
-- ============================================================================
-- Propósito: Obtener detalles completos de una orden específica
-- Parámetros:
--   - p_order_id: ID de la orden
-- Retorna: JSON con todos los detalles de la orden
-- Autor: AI Assistant
-- Fecha: 2024-12-28
-- ============================================================================

CREATE OR REPLACE FUNCTION get_admin_order_details(
  p_order_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_order_details called for order: %', p_order_id;
  
  -- Get order with all details
  SELECT json_build_object(
    'id', o.id,
    'restaurant_id', o.restaurant_id,
    'order_number', o.order_number,
    'status', o.status,
    'order_type', o.order_type,
    'subtotal_cents', o.subtotal_cents,
    'tax_cents', o.tax_cents,
    'delivery_fee_cents', o.delivery_fee_cents,
    'tip_cents', o.tip_cents,
    'discount_cents', o.discount_cents,
    'total_cents', o.total_cents,
    'driver_earnings_cents', o.driver_earnings_cents,
    'distance_km', o.distance_km,
    'estimated_prep_minutes', o.estimated_prep_minutes,
    'estimated_delivery_minutes', o.estimated_delivery_minutes,
    'payment_method', o.payment_method,
    'payment_status', o.payment_status,
    'payment_reference', o.payment_reference,
    'customer_notes', o.customer_notes,
    'kitchen_notes', o.kitchen_notes,
    'driver_notes', o.driver_notes,
    'cancellation_reason', o.cancellation_reason,
    'cancelled_by', o.cancelled_by,
    'customer_rating', o.customer_rating,
    'customer_review', o.customer_review,
    'driver_rating', o.driver_rating,
    'food_rating', o.food_rating,
    'customer_snapshot', o.customer_snapshot,
    'address_snapshot', o.address_snapshot,
    'created_at', o.created_at,
    'confirmed_at', o.confirmed_at,
    'accepted_at', o.accepted_at,
    'processing_at', o.processing_at,
    'ready_at', o.ready_at,
    'picked_up_at', o.picked_up_at,
    'delivered_at', o.delivered_at,
    'cancelled_at', o.cancelled_at,
    'updated_at', o.updated_at,
    'customer', CASE 
      WHEN c.id IS NOT NULL THEN json_build_object(
        'id', c.id,
        'name', c.name,
        'email', c.email,
        'phone', c.phone
      )
      ELSE NULL
    END,
    'driver', CASE 
      WHEN d.id IS NOT NULL THEN json_build_object(
        'id', d.id,
        'name', d.name,
        'phone', d.phone,
        'vehicle_type', d.vehicle_type
      )
      ELSE NULL
    END,
    'order_items', (
      SELECT json_agg(
        json_build_object(
          'id', oi.id,
          'product_id', oi.product_id,
          'variant_id', oi.variant_id,
          'product_name', oi.product_name,
          'variant_name', oi.variant_name,
          'product_image_url', oi.product_image_url,
          'quantity', oi.quantity,
          'unit_price_cents', oi.unit_price_cents,
          'total_price_cents', oi.total_price_cents,
          'notes', oi.notes
        )
      )
      FROM order_items oi
      WHERE oi.order_id = o.id
    )
  )
  INTO v_result
  FROM orders o
  LEFT JOIN customers c ON o.customer_id = c.id
  LEFT JOIN drivers d ON o.driver_id = d.id
  WHERE o.id = p_order_id;
  
  IF v_result IS NULL THEN
    RAISE NOTICE '❌ ERROR - Order not found: %', p_order_id;
    RAISE EXCEPTION 'Orden no encontrada';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Order details retrieved';
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_order_details: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener detalles de orden: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_admin_order_details(UUID) IS 
'Obtiene detalles completos de una orden específica';
