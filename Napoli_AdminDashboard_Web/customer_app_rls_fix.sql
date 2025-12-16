-- ##############################################################################
-- # NAPOLI - CUSTOMER APP RLS POLICIES FIX
-- # Execute this in Supabase SQL Editor to allow CustomerApp operations
-- # Run this AFTER rls_policies.sql
-- ##############################################################################

-- ============================================================================
-- PROBLEM: get_my_restaurant_id() only works for restaurant_admins
-- SOLUTION: Add customer-specific policies for CustomerApp
-- ============================================================================

-- Drop existing restrictive policy for customers table
DROP POLICY IF EXISTS "customers_tenant_isolation" ON customers;

-- ============================================================================
-- CUSTOMERS TABLE - Allow self-registration and self-management
-- ============================================================================

-- Allow authenticated users to INSERT their own customer record
-- (they can only insert a row where email matches their auth email)
CREATE POLICY "customers_insert_own" ON customers FOR INSERT
TO authenticated
WITH CHECK (email = auth.email());

-- Allow customers to read their own record
CREATE POLICY "customers_select_own" ON customers FOR SELECT
TO authenticated
USING (email = auth.email());

-- Allow customers to update their own record
CREATE POLICY "customers_update_own" ON customers FOR UPDATE
TO authenticated
USING (email = auth.email())
WITH CHECK (email = auth.email());

-- ============================================================================
-- CUSTOMER_ADDRESSES TABLE - Allow customers to manage their addresses
-- ============================================================================

DROP POLICY IF EXISTS "customer_addresses_tenant_isolation" ON customer_addresses;

-- Customers can insert addresses for themselves
CREATE POLICY "customer_addresses_insert_own" ON customer_addresses FOR INSERT
TO authenticated
WITH CHECK (
  customer_id IN (SELECT id FROM customers WHERE email = auth.email())
);

-- Customers can read their own addresses
CREATE POLICY "customer_addresses_select_own" ON customer_addresses FOR SELECT
TO authenticated
USING (
  customer_id IN (SELECT id FROM customers WHERE email = auth.email())
);

-- Customers can update their own addresses
CREATE POLICY "customer_addresses_update_own" ON customer_addresses FOR UPDATE
TO authenticated
USING (customer_id IN (SELECT id FROM customers WHERE email = auth.email()))
WITH CHECK (customer_id IN (SELECT id FROM customers WHERE email = auth.email()));

-- Customers can delete their own addresses
CREATE POLICY "customer_addresses_delete_own" ON customer_addresses FOR DELETE
TO authenticated
USING (customer_id IN (SELECT id FROM customers WHERE email = auth.email()));

-- ============================================================================
-- CUSTOMER_PAYMENT_METHODS TABLE - Allow customers to manage payment methods
-- ============================================================================

DROP POLICY IF EXISTS "customer_payment_methods_tenant_isolation" ON customer_payment_methods;

CREATE POLICY "customer_payment_methods_insert_own" ON customer_payment_methods FOR INSERT
TO authenticated
WITH CHECK (
  customer_id IN (SELECT id FROM customers WHERE email = auth.email())
);

CREATE POLICY "customer_payment_methods_select_own" ON customer_payment_methods FOR SELECT
TO authenticated
USING (
  customer_id IN (SELECT id FROM customers WHERE email = auth.email())
);

CREATE POLICY "customer_payment_methods_update_own" ON customer_payment_methods FOR UPDATE
TO authenticated
USING (customer_id IN (SELECT id FROM customers WHERE email = auth.email()))
WITH CHECK (customer_id IN (SELECT id FROM customers WHERE email = auth.email()));

CREATE POLICY "customer_payment_methods_delete_own" ON customer_payment_methods FOR DELETE
TO authenticated
USING (customer_id IN (SELECT id FROM customers WHERE email = auth.email()));

-- ============================================================================
-- ORDERS TABLE - Allow customers to create and view their orders
-- ============================================================================

DROP POLICY IF EXISTS "orders_tenant_isolation" ON orders;

-- Customers can insert orders for themselves
CREATE POLICY "orders_insert_own" ON orders FOR INSERT
TO authenticated
WITH CHECK (
  customer_id IN (SELECT id FROM customers WHERE email = auth.email())
);

-- Customers can read their own orders
CREATE POLICY "orders_select_own" ON orders FOR SELECT
TO authenticated
USING (
  customer_id IN (SELECT id FROM customers WHERE email = auth.email())
);

-- Customers can update their own orders (for rating, etc.)
CREATE POLICY "orders_update_own" ON orders FOR UPDATE
TO authenticated
USING (customer_id IN (SELECT id FROM customers WHERE email = auth.email()))
WITH CHECK (customer_id IN (SELECT id FROM customers WHERE email = auth.email()));

-- ============================================================================
-- ORDER_ITEMS TABLE - Allow customers to manage order items
-- ============================================================================

DROP POLICY IF EXISTS "order_items_tenant_isolation" ON order_items;

CREATE POLICY "order_items_insert_own" ON order_items FOR INSERT
TO authenticated
WITH CHECK (
  order_id IN (
    SELECT o.id FROM orders o
    JOIN customers c ON o.customer_id = c.id
    WHERE c.email = auth.email()
  )
);

CREATE POLICY "order_items_select_own" ON order_items FOR SELECT
TO authenticated
USING (
  order_id IN (
    SELECT o.id FROM orders o
    JOIN customers c ON o.customer_id = c.id
    WHERE c.email = auth.email()
  )
);

-- ============================================================================
-- READ-ONLY TABLES FOR CUSTOMERS (Products, Categories, Coupons, etc.)
-- ============================================================================

-- Categories: Public read for all authenticated users
DROP POLICY IF EXISTS "categories_tenant_isolation" ON categories;

CREATE POLICY "categories_public_read" ON categories FOR SELECT
TO authenticated
USING (is_active = true);

-- Re-add admin policy for categories (for AdminDashboard to work)
CREATE POLICY "categories_admin_all" ON categories FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- Products: Public read for all authenticated users
DROP POLICY IF EXISTS "products_tenant_isolation" ON products;

CREATE POLICY "products_public_read" ON products FOR SELECT
TO authenticated
USING (is_available = true);

CREATE POLICY "products_admin_all" ON products FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- Addons: Public read (uses is_available, not is_active)
DROP POLICY IF EXISTS "addons_tenant_isolation" ON addons;

CREATE POLICY "addons_public_read" ON addons FOR SELECT
TO authenticated
USING (is_available = true);

CREATE POLICY "addons_admin_all" ON addons FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- Product Addons: Public read
DROP POLICY IF EXISTS "product_addons_tenant_isolation" ON product_addons;

CREATE POLICY "product_addons_public_read" ON product_addons FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "product_addons_admin_all" ON product_addons FOR ALL
TO authenticated
USING (product_id IN (SELECT id FROM products WHERE restaurant_id = get_my_restaurant_id()))
WITH CHECK (product_id IN (SELECT id FROM products WHERE restaurant_id = get_my_restaurant_id()));

-- Coupons: Public read for customers (to validate codes)
DROP POLICY IF EXISTS "coupons_tenant_isolation" ON coupons;

CREATE POLICY "coupons_public_read" ON coupons FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "coupons_admin_all" ON coupons FOR ALL
TO authenticated
USING (restaurant_id = get_my_restaurant_id())
WITH CHECK (restaurant_id = get_my_restaurant_id());

-- Customer Coupons: Customers can use and view their used coupons
DROP POLICY IF EXISTS "customer_coupons_tenant_isolation" ON customer_coupons;

CREATE POLICY "customer_coupons_insert_own" ON customer_coupons FOR INSERT
TO authenticated
WITH CHECK (
  customer_id IN (SELECT id FROM customers WHERE email = auth.email())
);

CREATE POLICY "customer_coupons_select_own" ON customer_coupons FOR SELECT
TO authenticated
USING (
  customer_id IN (SELECT id FROM customers WHERE email = auth.email())
);

-- Restaurants: Public read (for config)
DROP POLICY IF EXISTS "restaurants_select" ON restaurants;
DROP POLICY IF EXISTS "restaurants_update" ON restaurants;
DROP POLICY IF EXISTS "restaurants_insert" ON restaurants;

CREATE POLICY "restaurants_public_read" ON restaurants FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "restaurants_admin_update" ON restaurants FOR UPDATE
TO authenticated
USING (id = get_my_restaurant_id())
WITH CHECK (id = get_my_restaurant_id());

-- ============================================================================
-- DONE! CustomerApp should now be able to register and operate
-- ============================================================================
