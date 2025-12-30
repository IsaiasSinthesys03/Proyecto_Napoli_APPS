-- ============================================================================
-- NAPOLI ADMIN DASHBOARD - RESTAURANT MANAGEMENT STORED PROCEDURES
-- ============================================================================
-- File: 28_restaurant_management.sql
-- Purpose: Complete restaurant CRUD operations with RPC calls
-- Created: 2025-12-30
-- 
-- This file contains 6 stored procedures for comprehensive restaurant management:
-- 1. get_admin_restaurant - Get complete restaurant information
-- 2. update_admin_restaurant_profile - Update basic profile (name, description, contact)
-- 3. update_admin_restaurant_branding - Update branding (logo, banner, colors)
-- 4. update_admin_restaurant_location - Update location (address, coordinates, timezone)
-- 5. update_admin_restaurant_regional_settings - Update regional config (currency, tax, format)
-- 6. update_admin_restaurant_settings - Update operational settings (delivery, payments, hours)
-- ============================================================================

-- ============================================================================
-- 1. GET ADMIN RESTAURANT
-- ============================================================================
-- Returns complete restaurant information for the admin dashboard
-- All fields from restaurants table in camelCase format
-- ============================================================================

CREATE OR REPLACE FUNCTION get_admin_restaurant(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_admin_restaurant called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Get complete restaurant data using row_to_json
  SELECT row_to_json(r.*) INTO v_result
  FROM restaurants r
  WHERE r.id = p_restaurant_id;

  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Restaurant data retrieved';
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting restaurant: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_admin_restaurant IS 'Get complete restaurant information for admin dashboard';

-- ============================================================================
-- 2. UPDATE ADMIN RESTAURANT PROFILE
-- ============================================================================
-- Updates basic restaurant profile information
-- Fields: name, description, email, phone, whatsapp, website
-- ============================================================================

CREATE OR REPLACE FUNCTION update_admin_restaurant_profile(
  p_restaurant_id UUID,
  p_name VARCHAR(255) DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_email VARCHAR(255) DEFAULT NULL,
  p_phone VARCHAR(50) DEFAULT NULL,
  p_whatsapp VARCHAR(50) DEFAULT NULL,
  p_website VARCHAR(500) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_restaurant_profile called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, name: %', p_restaurant_id, p_name;

  -- Update only provided fields
  UPDATE restaurants
  SET
    name = COALESCE(p_name, name),
    description = COALESCE(p_description, description),
    email = COALESCE(p_email, email),
    phone = COALESCE(p_phone, phone),
    whatsapp = COALESCE(p_whatsapp, whatsapp),
    website = COALESCE(p_website, website),
    updated_at = NOW()
  WHERE id = p_restaurant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Restaurant profile updated';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error updating restaurant profile: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION update_admin_restaurant_profile IS 'Update restaurant basic profile information';

-- ============================================================================
-- 3. UPDATE ADMIN RESTAURANT BRANDING
-- ============================================================================
-- Updates restaurant branding elements
-- Fields: logo_url, banner_url, primary_color, secondary_color
-- ============================================================================

CREATE OR REPLACE FUNCTION update_admin_restaurant_branding(
  p_restaurant_id UUID,
  p_logo_url VARCHAR(2048) DEFAULT NULL,
  p_banner_url VARCHAR(2048) DEFAULT NULL,
  p_primary_color VARCHAR(7) DEFAULT NULL,
  p_secondary_color VARCHAR(7) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_restaurant_branding called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Update only provided fields
  UPDATE restaurants
  SET
    logo_url = COALESCE(p_logo_url, logo_url),
    banner_url = COALESCE(p_banner_url, banner_url),
    primary_color = COALESCE(p_primary_color, primary_color),
    secondary_color = COALESCE(p_secondary_color, secondary_color),
    updated_at = NOW()
  WHERE id = p_restaurant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Restaurant branding updated';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error updating restaurant branding: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION update_admin_restaurant_branding IS 'Update restaurant branding (logo, banner, colors)';

-- ============================================================================
-- 4. UPDATE ADMIN RESTAURANT LOCATION
-- ============================================================================
-- Updates restaurant location information
-- Fields: address, city, state, country, postal_code, latitude, longitude, timezone
-- ============================================================================

CREATE OR REPLACE FUNCTION update_admin_restaurant_location(
  p_restaurant_id UUID,
  p_address VARCHAR(500) DEFAULT NULL,
  p_city VARCHAR(100) DEFAULT NULL,
  p_state VARCHAR(100) DEFAULT NULL,
  p_country VARCHAR(100) DEFAULT NULL,
  p_postal_code VARCHAR(20) DEFAULT NULL,
  p_latitude DECIMAL(10, 8) DEFAULT NULL,
  p_longitude DECIMAL(11, 8) DEFAULT NULL,
  p_timezone VARCHAR(50) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_restaurant_location called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, address: %', p_restaurant_id, p_address;

  -- Update only provided fields
  UPDATE restaurants
  SET
    address = COALESCE(p_address, address),
    city = COALESCE(p_city, city),
    state = COALESCE(p_state, state),
    country = COALESCE(p_country, country),
    postal_code = COALESCE(p_postal_code, postal_code),
    latitude = COALESCE(p_latitude, latitude),
    longitude = COALESCE(p_longitude, longitude),
    timezone = COALESCE(p_timezone, timezone),
    updated_at = NOW()
  WHERE id = p_restaurant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Restaurant location updated';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error updating restaurant location: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION update_admin_restaurant_location IS 'Update restaurant location and address information';

-- ============================================================================
-- 5. UPDATE ADMIN RESTAURANT REGIONAL SETTINGS
-- ============================================================================
-- Updates regional configuration
-- Fields: currency, tax, number formatting
-- ============================================================================

CREATE OR REPLACE FUNCTION update_admin_restaurant_regional_settings(
  p_restaurant_id UUID,
  p_currency_code VARCHAR(3) DEFAULT NULL,
  p_currency_symbol VARCHAR(5) DEFAULT NULL,
  p_currency_position VARCHAR(10) DEFAULT NULL,
  p_decimal_separator VARCHAR(1) DEFAULT NULL,
  p_thousands_separator VARCHAR(1) DEFAULT NULL,
  p_decimal_places INT DEFAULT NULL,
  p_tax_rate_percentage DECIMAL(5,2) DEFAULT NULL,
  p_tax_included_in_prices BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_restaurant_regional_settings called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, currency: %', p_restaurant_id, p_currency_code;

  -- Update only provided fields
  UPDATE restaurants
  SET
    currency_code = COALESCE(p_currency_code, currency_code),
    currency_symbol = COALESCE(p_currency_symbol, currency_symbol),
    currency_position = COALESCE(p_currency_position, currency_position),
    decimal_separator = COALESCE(p_decimal_separator, decimal_separator),
    thousands_separator = COALESCE(p_thousands_separator, thousands_separator),
    decimal_places = COALESCE(p_decimal_places, decimal_places),
    tax_rate_percentage = COALESCE(p_tax_rate_percentage, tax_rate_percentage),
    tax_included_in_prices = COALESCE(p_tax_included_in_prices, tax_included_in_prices),
    updated_at = NOW()
  WHERE id = p_restaurant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Restaurant regional settings updated';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error updating restaurant regional settings: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION update_admin_restaurant_regional_settings IS 'Update restaurant regional settings (currency, tax, formatting)';

-- ============================================================================
-- 6. UPDATE ADMIN RESTAURANT SETTINGS
-- ============================================================================
-- Updates operational settings
-- Fields: delivery config, payment methods, business hours, driver commission
-- ============================================================================

CREATE OR REPLACE FUNCTION update_admin_restaurant_settings(
  p_restaurant_id UUID,
  p_is_open BOOLEAN DEFAULT NULL,
  p_accepts_delivery BOOLEAN DEFAULT NULL,
  p_accepts_pickup BOOLEAN DEFAULT NULL,
  p_accepts_dine_in BOOLEAN DEFAULT NULL,
  p_delivery_radius_km DECIMAL(5,2) DEFAULT NULL,
  p_minimum_order_cents INT DEFAULT NULL,
  p_delivery_fee_cents INT DEFAULT NULL,
  p_delivery_fee_per_km_cents INT DEFAULT NULL,
  p_free_delivery_threshold_cents INT DEFAULT NULL,
  p_estimated_prep_minutes INT DEFAULT NULL,
  p_estimated_delivery_minutes INT DEFAULT NULL,
  p_accepts_card BOOLEAN DEFAULT NULL,
  p_accepts_cash BOOLEAN DEFAULT NULL,
  p_accepts_transfer BOOLEAN DEFAULT NULL,
  p_bank_account_clabe VARCHAR(20) DEFAULT NULL,
  p_bank_account_name VARCHAR(255) DEFAULT NULL,
  p_bank_name VARCHAR(100) DEFAULT NULL,
  p_business_hours JSONB DEFAULT NULL,
  p_driver_commission_type VARCHAR(20) DEFAULT NULL,
  p_driver_commission_value DECIMAL(10,2) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_restaurant_settings called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Update only provided fields
  UPDATE restaurants
  SET
    is_open = COALESCE(p_is_open, is_open),
    accepts_delivery = COALESCE(p_accepts_delivery, accepts_delivery),
    accepts_pickup = COALESCE(p_accepts_pickup, accepts_pickup),
    accepts_dine_in = COALESCE(p_accepts_dine_in, accepts_dine_in),
    delivery_radius_km = COALESCE(p_delivery_radius_km, delivery_radius_km),
    minimum_order_cents = COALESCE(p_minimum_order_cents, minimum_order_cents),
    delivery_fee_cents = COALESCE(p_delivery_fee_cents, delivery_fee_cents),
    delivery_fee_per_km_cents = COALESCE(p_delivery_fee_per_km_cents, delivery_fee_per_km_cents),
    free_delivery_threshold_cents = COALESCE(p_free_delivery_threshold_cents, free_delivery_threshold_cents),
    estimated_prep_minutes = COALESCE(p_estimated_prep_minutes, estimated_prep_minutes),
    estimated_delivery_minutes = COALESCE(p_estimated_delivery_minutes, estimated_delivery_minutes),
    accepts_card = COALESCE(p_accepts_card, accepts_card),
    accepts_cash = COALESCE(p_accepts_cash, accepts_cash),
    accepts_transfer = COALESCE(p_accepts_transfer, accepts_transfer),
    bank_account_clabe = COALESCE(p_bank_account_clabe, bank_account_clabe),
    bank_account_name = COALESCE(p_bank_account_name, bank_account_name),
    bank_name = COALESCE(p_bank_name, bank_name),
    business_hours = COALESCE(p_business_hours, business_hours),
    driver_commission_type = COALESCE(p_driver_commission_type, driver_commission_type),
    driver_commission_value = COALESCE(p_driver_commission_value, driver_commission_value),
    updated_at = NOW()
  WHERE id = p_restaurant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Restaurant settings updated';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error updating restaurant settings: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION update_admin_restaurant_settings IS 'Update restaurant operational settings (delivery, payments, hours)';

-- ============================================================================
-- END OF FILE
-- ============================================================================
