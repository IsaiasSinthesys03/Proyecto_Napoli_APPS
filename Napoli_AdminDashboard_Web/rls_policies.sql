-- ##############################################################################
-- # NAPOLI SaaS - ROW LEVEL SECURITY POLICIES
-- # Complete RLS script for multi-tenant isolation
-- # Execute this AFTER running schema.sql
-- ##############################################################################

-- ============================================================================
-- HELPER FUNCTION: Get current user's restaurant_id
-- ============================================================================
CREATE OR REPLACE FUNCTION get_my_restaurant_id()
RETURNS UUID AS $$
  SELECT restaurant_id FROM restaurant_admins WHERE email = auth.email() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- ============================================================================
-- PLATFORM TABLES (SaaS Owner Only - No RLS for admins)
-- ============================================================================

-- platform_config: Public read, no write for restaurant admins
ALTER TABLE platform_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "platform_config_public_read" ON platform_config FOR SELECT
USING (is_public = true);

-- subscription_plans: Public read for all
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "subscription_plans_public_read" ON subscription_plans FOR SELECT
USING (is_active = true);

-- ============================================================================
-- RESTAURANTS TABLE
-- ============================================================================
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;

-- Admins can read their own restaurant
CREATE POLICY "restaurants_select" ON restaurants FOR SELECT
TO authenticated
USING (
  id = get_my_restaurant_id()
);

-- Admins can update their own restaurant
CREATE POLICY "restaurants_update" ON restaurants FOR UPDATE
TO authenticated
USING (id = get_my_restaurant_id())
WITH CHECK (id = get_my_restaurant_id());

-- Authenticated users can insert (for registration flow)
CREATE POLICY "restaurants_insert" ON restaurants FOR INSERT
TO authenticated
WITH CHECK (true);

-- ============================================================================
-- RESTAURANT_ADMINS TABLE
-- ============================================================================
ALTER TABLE restaurant_admins ENABLE ROW LEVEL SECURITY;

-- Admins can see themselves and other admins of their restaurant
CREATE POLICY "restaurant_admins_select" ON restaurant_admins FOR SELECT
TO authenticated
USING (
  email = auth.email() 
  OR restaurant_id = get_my_restaurant_id()
);

-- Authenticated users can insert (for registration flow)
CREATE POLICY "restaurant_admins_insert" ON restaurant_admins FOR INSERT
TO authenticated
WITH CHECK (true);

-- Admins can update their own profile
CREATE POLICY "restaurant_admins_update" ON restaurant_admins FOR UPDATE
TO authenticated
USING (email = auth.email())
WITH CHECK (email = auth.email());

-- ============================================================================
-- CATEGORIES TABLE
-- ============================================================================
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "categories_tenant_isolation" ON categories FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- PRODUCTS TABLE
-- ============================================================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "products_tenant_isolation" ON products FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- ADDONS TABLE
-- ============================================================================
ALTER TABLE addons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "addons_tenant_isolation" ON addons FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- CATEGORY_ADDONS (Junction Table)
-- ============================================================================
ALTER TABLE category_addons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "category_addons_tenant_isolation" ON category_addons FOR ALL
TO authenticated
USING (
  category_id IN (SELECT id FROM categories WHERE restaurant_id = get_my_restaurant_id())
)
WITH CHECK (
  category_id IN (SELECT id FROM categories WHERE restaurant_id = get_my_restaurant_id())
);

-- ============================================================================
-- PRODUCT_ADDONS (Junction Table)
-- ============================================================================
ALTER TABLE product_addons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "product_addons_tenant_isolation" ON product_addons FOR ALL
TO authenticated
USING (
  product_id IN (SELECT id FROM products WHERE restaurant_id = get_my_restaurant_id())
)
WITH CHECK (
  product_id IN (SELECT id FROM products WHERE restaurant_id = get_my_restaurant_id())
);

-- ============================================================================
-- PROMOTIONS TABLE
-- ============================================================================
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "promotions_tenant_isolation" ON promotions FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- COUPONS TABLE
-- ============================================================================
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "coupons_tenant_isolation" ON coupons FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- CUSTOMERS TABLE
-- ============================================================================
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "customers_tenant_isolation" ON customers FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- CUSTOMER_ADDRESSES TABLE
-- ============================================================================
ALTER TABLE customer_addresses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "customer_addresses_tenant_isolation" ON customer_addresses FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- CUSTOMER_PAYMENT_METHODS TABLE
-- ============================================================================
ALTER TABLE customer_payment_methods ENABLE ROW LEVEL SECURITY;

CREATE POLICY "customer_payment_methods_tenant_isolation" ON customer_payment_methods FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- CUSTOMER_RESTAURANT_ASSIGNMENTS TABLE (Future)
-- ============================================================================
ALTER TABLE customer_restaurant_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "customer_restaurant_assignments_tenant_isolation" ON customer_restaurant_assignments FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- CUSTOMER_NOTIFICATION_PREFERENCES TABLE
-- ============================================================================
ALTER TABLE customer_notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "customer_notification_preferences_tenant_isolation" ON customer_notification_preferences FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- DRIVERS TABLE
-- ============================================================================
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "drivers_tenant_isolation" ON drivers FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- DRIVER_EARNINGS TABLE
-- ============================================================================
ALTER TABLE driver_earnings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "driver_earnings_tenant_isolation" ON driver_earnings FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- DRIVER_RESTAURANT_ASSIGNMENTS TABLE (Future)
-- ============================================================================
ALTER TABLE driver_restaurant_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "driver_restaurant_assignments_tenant_isolation" ON driver_restaurant_assignments FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- ORDERS TABLE (Critical)
-- ============================================================================
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "orders_tenant_isolation" ON orders FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- ORDER_ITEMS TABLE
-- ============================================================================
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "order_items_tenant_isolation" ON order_items FOR ALL
TO authenticated
USING (
  order_id IN (SELECT id FROM orders WHERE restaurant_id = get_my_restaurant_id())
)
WITH CHECK (
  order_id IN (SELECT id FROM orders WHERE restaurant_id = get_my_restaurant_id())
);

-- ============================================================================
-- ORDER_STATUS_HISTORY TABLE
-- ============================================================================
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "order_status_history_tenant_isolation" ON order_status_history FOR ALL
TO authenticated
USING (
  order_id IN (SELECT id FROM orders WHERE restaurant_id = get_my_restaurant_id())
)
WITH CHECK (
  order_id IN (SELECT id FROM orders WHERE restaurant_id = get_my_restaurant_id())
);

-- ============================================================================
-- CUSTOMER_COUPONS TABLE
-- ============================================================================
ALTER TABLE customer_coupons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "customer_coupons_tenant_isolation" ON customer_coupons FOR ALL
TO authenticated
USING (
  coupon_id IN (SELECT id FROM coupons WHERE restaurant_id = get_my_restaurant_id())
)
WITH CHECK (
  coupon_id IN (SELECT id FROM coupons WHERE restaurant_id = get_my_restaurant_id())
);

-- ============================================================================
-- PROMOTION_PRODUCTS TABLE (Junction)
-- ============================================================================
ALTER TABLE promotion_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "promotion_products_tenant_isolation" ON promotion_products FOR ALL
TO authenticated
USING (
  promotion_id IN (SELECT id FROM promotions WHERE restaurant_id = get_my_restaurant_id())
)
WITH CHECK (
  promotion_id IN (SELECT id FROM promotions WHERE restaurant_id = get_my_restaurant_id())
);

-- ============================================================================
-- RESTAURANT REPORTS TABLES (Read-Only for Admins)
-- ============================================================================

ALTER TABLE restaurant_daily_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "restaurant_daily_reports_read" ON restaurant_daily_reports FOR SELECT
TO authenticated
USING (restaurant_id = get_my_restaurant_id());

ALTER TABLE restaurant_product_sales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "restaurant_product_sales_read" ON restaurant_product_sales FOR SELECT
TO authenticated
USING (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- NOTIFICATIONS TABLE
-- ============================================================================
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_tenant_isolation" ON notifications FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- ANALYTICS_EVENTS TABLE
-- ============================================================================
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "analytics_events_tenant_isolation" ON analytics_events FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- ============================================================================
-- GRANT USAGE ON FUNCTION
-- ============================================================================
GRANT EXECUTE ON FUNCTION get_my_restaurant_id() TO authenticated;

-- ============================================================================
-- DONE! All tables now have RLS policies for multi-tenant isolation
-- ============================================================================
