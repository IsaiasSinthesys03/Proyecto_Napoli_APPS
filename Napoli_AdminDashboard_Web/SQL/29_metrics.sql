-- ========================================
-- METRICS MODULE - STORED PROCEDURES
-- Complete migration of metrics module to RPC
-- ========================================

-- ========================================
-- 1. GET DAY ORDERS AMOUNT
-- Returns today's order count vs yesterday
-- ========================================

CREATE OR REPLACE FUNCTION get_day_orders_amount(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_today_count INT;
  v_yesterday_count INT;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_day_orders_amount called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Count today's orders
  SELECT COUNT(*)
  INTO v_today_count
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND created_at >= CURRENT_DATE;

  -- Count yesterday's orders
  SELECT COUNT(*)
  INTO v_yesterday_count
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND created_at >= (CURRENT_DATE - INTERVAL '1 day')
    AND created_at < CURRENT_DATE;

  -- Build result
  v_result := json_build_object(
    'amount', COALESCE(v_today_count, 0),
    'diffFromYesterday', COALESCE(v_today_count, 0) - COALESCE(v_yesterday_count, 0)
  );

  RAISE NOTICE '✅ SUCCESS - Day orders: %, diff: %', v_today_count, v_today_count - v_yesterday_count;
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting day orders amount: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_day_orders_amount(UUID) IS 
  'Returns today''s order count compared to yesterday';

-- ========================================
-- 2. GET MONTH ORDERS AMOUNT
-- Returns this month's order count vs last month
-- ========================================

CREATE OR REPLACE FUNCTION get_month_orders_amount(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_this_month_count INT;
  v_last_month_count INT;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_month_orders_amount called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Count this month's orders
  SELECT COUNT(*)
  INTO v_this_month_count
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND created_at >= DATE_TRUNC('month', CURRENT_DATE);

  -- Count last month's orders
  SELECT COUNT(*)
  INTO v_last_month_count
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND created_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    AND created_at < DATE_TRUNC('month', CURRENT_DATE);

  -- Build result
  v_result := json_build_object(
    'amount', COALESCE(v_this_month_count, 0),
    'diffFromLastMonth', COALESCE(v_this_month_count, 0) - COALESCE(v_last_month_count, 0)
  );

  RAISE NOTICE '✅ SUCCESS - Month orders: %, diff: %', v_this_month_count, v_this_month_count - v_last_month_count;
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting month orders amount: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_month_orders_amount(UUID) IS 
  'Returns this month''s order count compared to last month';

-- ========================================
-- 3. GET MONTH CANCELED ORDERS AMOUNT
-- Returns this month's canceled orders vs last month
-- ========================================

CREATE OR REPLACE FUNCTION get_month_canceled_orders_amount(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_this_month_count INT;
  v_last_month_count INT;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_month_canceled_orders_amount called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Count this month's canceled orders
  SELECT COUNT(*)
  INTO v_this_month_count
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND status = 'cancelled'
    AND created_at >= DATE_TRUNC('month', CURRENT_DATE);

  -- Count last month's canceled orders
  SELECT COUNT(*)
  INTO v_last_month_count
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND status = 'cancelled'
    AND created_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    AND created_at < DATE_TRUNC('month', CURRENT_DATE);

  -- Build result
  v_result := json_build_object(
    'amount', COALESCE(v_this_month_count, 0),
    'diffFromLastMonth', COALESCE(v_this_month_count, 0) - COALESCE(v_last_month_count, 0)
  );

  RAISE NOTICE '✅ SUCCESS - Canceled orders: %, diff: %', v_this_month_count, v_this_month_count - v_last_month_count;
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting month canceled orders: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_month_canceled_orders_amount(UUID) IS 
  'Returns this month''s canceled order count compared to last month';

-- ========================================
-- 4. GET MONTH REVENUE
-- Returns this month's revenue vs last month
-- ========================================

CREATE OR REPLACE FUNCTION get_month_revenue(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_this_month_cents BIGINT;
  v_last_month_cents BIGINT;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_month_revenue called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Sum this month's revenue (delivered orders only)
  SELECT COALESCE(SUM(total_cents), 0)
  INTO v_this_month_cents
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND status = 'delivered'
    AND created_at >= DATE_TRUNC('month', CURRENT_DATE);

  -- Sum last month's revenue
  SELECT COALESCE(SUM(total_cents), 0)
  INTO v_last_month_cents
  FROM orders
  WHERE restaurant_id = p_restaurant_id
    AND status = 'delivered'
    AND created_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    AND created_at < DATE_TRUNC('month', CURRENT_DATE);

  -- Build result (convert cents to dollars)
  v_result := json_build_object(
    'receipt', v_this_month_cents / 100.0,
    'diffFromLastMonth', (v_this_month_cents - v_last_month_cents) / 100.0
  );

  RAISE NOTICE '✅ SUCCESS - Month revenue: $%, diff: $%', 
    v_this_month_cents / 100.0, 
    (v_this_month_cents - v_last_month_cents) / 100.0;
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting month revenue: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_month_revenue(UUID) IS 
  'Returns this month''s revenue compared to last month (delivered orders only)';

-- ========================================
-- 5. GET POPULAR PRODUCTS
-- Returns top 10 most ordered products
-- ========================================

CREATE OR REPLACE FUNCTION get_popular_products(
  p_restaurant_id UUID,
  p_from TIMESTAMPTZ DEFAULT NULL,
  p_to TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_popular_products called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, from: %, to: %', p_restaurant_id, p_from, p_to;

  -- Get popular products from order_items
  SELECT json_agg(
    json_build_object(
      'product', product_name,
      'amount', total_quantity
    )
  )
  INTO v_result
  FROM (
    SELECT 
      oi.product_name,
      SUM(oi.quantity) as total_quantity
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.id
    WHERE o.restaurant_id = p_restaurant_id
      AND o.status = 'delivered'
      AND (p_from IS NULL OR o.created_at >= p_from)
      AND (p_to IS NULL OR o.created_at <= p_to)
    GROUP BY oi.product_name
    ORDER BY total_quantity DESC
    LIMIT 10
  ) popular;

  -- Return empty array if no data
  IF v_result IS NULL THEN
    v_result := '[]'::JSON;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Popular products retrieved';
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting popular products: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_popular_products(UUID, TIMESTAMPTZ, TIMESTAMPTZ) IS 
  'Returns top 10 most ordered products (delivered orders only)';

-- ========================================
-- 6. GET DAILY REVENUE IN PERIOD
-- Returns daily revenue breakdown for a date range
-- ========================================

CREATE OR REPLACE FUNCTION get_daily_revenue_in_period(
  p_restaurant_id UUID,
  p_from TIMESTAMPTZ DEFAULT NULL,
  p_to TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_daily_revenue_in_period called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, from: %, to: %', p_restaurant_id, p_from, p_to;

  -- Get daily revenue grouped by date
  SELECT json_agg(
    json_build_object(
      'date', order_date,
      'receipt', daily_revenue
    ) ORDER BY order_date
  )
  INTO v_result
  FROM (
    SELECT 
      DATE(created_at) as order_date,
      SUM(total_cents) / 100.0 as daily_revenue
    FROM orders
    WHERE restaurant_id = p_restaurant_id
      AND status = 'delivered'
      AND (p_from IS NULL OR created_at >= p_from)
      AND (p_to IS NULL OR created_at <= p_to)
    GROUP BY DATE(created_at)
    ORDER BY DATE(created_at)
  ) daily;

  -- Return empty array if no data
  IF v_result IS NULL THEN
    v_result := '[]'::JSON;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Daily revenue retrieved';
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting daily revenue: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_daily_revenue_in_period(UUID, TIMESTAMPTZ, TIMESTAMPTZ) IS 
  'Returns daily revenue breakdown for a date range (delivered orders only)';

-- ========================================
-- 7. GET SALES TRANSACTIONS
-- Returns detailed sales transactions with items
-- ========================================

CREATE OR REPLACE FUNCTION get_sales_transactions(
  p_restaurant_id UUID,
  p_from TIMESTAMPTZ DEFAULT NULL,
  p_to TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_sales_transactions called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, from: %, to: %', p_restaurant_id, p_from, p_to;

  -- Get sales transactions with order items
  SELECT json_agg(
    json_build_object(
      'id', o.id,
      'date', o.created_at,
      'customerName', COALESCE(o.customer_snapshot->>'name', 'Cliente'),
      'total', o.total_cents / 100.0,
      'items', (
        SELECT json_agg(
          json_build_object(
            'product', oi.product_name,
            'quantity', oi.quantity,
            'price', oi.unit_price_cents / 100.0
          )
        )
        FROM order_items oi
        WHERE oi.order_id = o.id
      )
    ) ORDER BY o.created_at DESC
  )
  INTO v_result
  FROM orders o
  WHERE o.restaurant_id = p_restaurant_id
    AND o.status = 'delivered'
    AND (p_from IS NULL OR o.created_at >= p_from)
    AND (p_to IS NULL OR o.created_at <= p_to)
  LIMIT 50;

  -- Return empty array if no data
  IF v_result IS NULL THEN
    v_result := '[]'::JSON;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Sales transactions retrieved';
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting sales transactions: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_sales_transactions(UUID, TIMESTAMPTZ, TIMESTAMPTZ) IS 
  'Returns detailed sales transactions with items (delivered orders only, limit 50)';
