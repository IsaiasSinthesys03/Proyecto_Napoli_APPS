-- ============================================================================
-- STORED PROCEDURE: get_admin_orders
-- ============================================================================
-- Propósito: Obtener lista paginada de órdenes para el admin dashboard
-- Parámetros:
--   - p_restaurant_id: ID del restaurante
--   - p_page: Número de página (default 1)
--   - p_status_filter: Array de estados para filtrar (opcional)
--   - p_order_number_filter: Filtro por número de orden (opcional)
-- Retorna: JSON con results y meta (paginación)
-- Autor: AI Assistant
-- Fecha: 2024-12-28
-- ============================================================================

CREATE OR REPLACE FUNCTION get_admin_orders(
  p_restaurant_id UUID,
  p_page INT DEFAULT 1,
  p_status_filter TEXT[] DEFAULT NULL,
  p_order_number_filter TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_per_page INT := 10;
  v_offset INT;
  v_total_count INT;
  v_orders JSON;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_orders called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, page: %', p_restaurant_id, p_page;
  
  v_offset := (p_page - 1) * v_per_page;
  
  -- Get total count
  SELECT COUNT(*)
  INTO v_total_count
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND (p_status_filter IS NULL OR status = ANY(p_status_filter::order_status[]))
    AND (p_order_number_filter IS NULL OR order_number ILIKE '%' || p_order_number_filter || '%');
  
  RAISE NOTICE '📦 DATA - Total count: %', v_total_count;
  
  -- Get orders with joins
  SELECT json_agg(row_to_json(order_row))
  INTO v_orders
  FROM (
    SELECT
      o.id,
      o.order_number,
      o.status,
      o.order_type,
      o.subtotal_cents,
      o.tax_cents,
      o.delivery_fee_cents,
      o.tip_cents,
      o.discount_cents,
      o.total_cents,
      o.payment_method,
      o.payment_status,
      o.customer_notes,
      o.created_at,
      o.accepted_at,
      o.delivered_at,
      json_build_object(
        'id', c.id,
        'name', c.name,
        'email', c.email,
        'phone', c.phone
      ) as customer,
      CASE 
        WHEN d.id IS NOT NULL THEN json_build_object(
          'id', d.id,
          'name', d.name
        )
        ELSE NULL
      END as driver,
      (
        SELECT json_agg(
          json_build_object(
            'id', oi.id,
            'product_name', oi.product_name,
            'variant_name', oi.variant_name,
            'quantity', oi.quantity,
            'unit_price_cents', oi.unit_price_cents,
            'total_price_cents', oi.total_price_cents,
            'notes', oi.notes
          )
        )
        FROM order_items oi
        WHERE oi.order_id = o.id
      ) as order_items
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.id
    LEFT JOIN drivers d ON o.driver_id = d.id
    WHERE o.restaurant_id = p_restaurant_id
      AND (p_status_filter IS NULL OR o.status = ANY(p_status_filter::order_status[]))
      AND (p_order_number_filter IS NULL OR o.order_number ILIKE '%' || p_order_number_filter || '%')
    ORDER BY o.created_at DESC
    LIMIT v_per_page
    OFFSET v_offset
  ) order_row;
  
  -- Build response
  SELECT json_build_object(
    'results', COALESCE(v_orders, '[]'::json),
    'meta', json_build_object(
      'page_index', p_page - 1,
      'per_page', v_per_page,
      'total_count', v_total_count
    )
  )
  INTO v_result;
  
  RAISE NOTICE '✅ SUCCESS - Returning % orders', json_array_length(COALESCE(v_orders, '[]'::json));
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_admin_orders: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener órdenes: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_admin_orders(UUID, INT, TEXT[], TEXT) IS 
'Obtiene lista paginada de órdenes con filtros para el admin dashboard';
