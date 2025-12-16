-- ##############################################################################
-- # NAPOLI SAAS - SUPABASE SCHEMA v4.3 (FINAL)
-- # Multi-Tenant SaaS for Pizzerias with Complete Customization
-- # NO HARDCODED VALUES - Everything configurable per restaurant
-- # Includes: Storage Buckets, RLS Policies, Realtime, Analytics
-- # NUEVO: Section 7B - Restaurant Reports (para dueños de pizzerías)
-- ##############################################################################
-- # ARCHITECTURE:
-- # - Each pizzeria (restaurant) is an isolated TENANT
-- # - Each pizzeria has their OWN customers (not shared)
-- # - Each pizzeria has their OWN drivers (sharing optional in future)
-- # - SaaS owner collects ALL metadata for analytics platform
-- ##############################################################################

-- ============================================================================
-- EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUMS
-- ============================================================================

-- Unified Order Status
CREATE TYPE order_status AS ENUM (
    'pending',      -- Customer placed order
    'accepted',     -- Admin accepted
    'processing',   -- Being prepared
    'ready',        -- Ready for pickup
    'delivering',   -- Driver on the way
    'delivered',    -- Completed
    'cancelled'     -- Cancelled
);

-- Driver status
CREATE TYPE driver_status AS ENUM (
    'pending',      -- Awaiting approval
    'approved',     -- Approved, can work
    'active',       -- Currently available
    'inactive',     -- Deactivated
    'suspended'     -- Temporarily suspended
);

-- Customer status
CREATE TYPE customer_status AS ENUM (
    'active',
    'inactive',
    'blocked'
);

-- Vehicle types
CREATE TYPE vehicle_type AS ENUM ('moto', 'bici', 'auto', 'camioneta', 'otro');

-- Payment types
CREATE TYPE payment_type AS ENUM ('card', 'cash', 'transfer', 'other');

-- Subscription status
CREATE TYPE subscription_status AS ENUM (
    'trial',
    'active', 
    'past_due',
    'cancelled',
    'expired',
    'suspended'
);

-- Event categories for analytics
CREATE TYPE event_category AS ENUM (
    'auth',         -- Login, logout, register
    'order',        -- Order lifecycle
    'driver',       -- Driver actions
    'customer',     -- Customer actions
    'product',      -- Menu changes
    'payment',      -- Payment events
    'system',       -- System events
    'admin'         -- Admin actions
);

-- ============================================================================
-- SECTION 1: PLATFORM CORE (SaaS Owner - Editable Parameters)
-- ============================================================================

-- Platform configuration (easily editable by SaaS owner)
CREATE TABLE platform_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    value_type VARCHAR(50) NOT NULL, -- 'string', 'number', 'boolean', 'json'
    category VARCHAR(50) NOT NULL DEFAULT 'general',
    label VARCHAR(255) NOT NULL, -- Human readable label
    description TEXT,
    is_public BOOLEAN DEFAULT false, -- Can restaurants see this?
    is_editable BOOLEAN DEFAULT true, -- Can be changed in UI
    validation_rules JSONB, -- e.g., {"min": 0, "max": 100}
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

-- Subscription plans (FULLY EDITABLE - all parameters stored in JSONB)
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(50) UNIQUE NOT NULL, -- 'starter', 'growth', 'enterprise'
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Pricing (in cents, currency-agnostic)
    price_monthly_cents INT NOT NULL,
    price_yearly_cents INT,
    
    -- Limits (NULL = unlimited)
    limits JSONB NOT NULL DEFAULT '{
        "max_products": 100,
        "max_categories": 20,
        "max_addons": 50,
        "max_drivers": 5,
        "max_orders_per_month": 1000,
        "max_customers": null,
        "max_admins": 3
    }',
    
    -- Features (toggle on/off)
    features JSONB NOT NULL DEFAULT '{
        "analytics_basic": true,
        "analytics_advanced": false,
        "promotions": true,
        "coupons": true,
        "realtime_tracking": true,
        "custom_branding": false,
        "api_access": false,
        "priority_support": false,
        "custom_domain": false,
        "white_label": false,
        "export_data": true,
        "multi_location": false
    }',
    
    -- Display
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    is_recommended BOOLEAN DEFAULT false,
    badge_text VARCHAR(50), -- "Más Popular", "Mejor Valor"
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SECTION 2: RESTAURANTS (Tenants)
-- ============================================================================

CREATE TABLE restaurants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Identity
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    
    -- Branding
    logo_url VARCHAR(2048),
    banner_url VARCHAR(2048),
    primary_color VARCHAR(7), -- #RRGGBB
    secondary_color VARCHAR(7),
    
    -- Contact
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    whatsapp VARCHAR(50),
    website VARCHAR(500),
    
    -- Location
    address VARCHAR(500),
    address_details VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    
    -- Business Hours (fully customizable per day)
    business_hours JSONB NOT NULL DEFAULT '{
        "monday": {"enabled": true, "open": "12:00", "close": "22:00"},
        "tuesday": {"enabled": false, "open": null, "close": null},
        "wednesday": {"enabled": true, "open": "12:00", "close": "22:00"},
        "thursday": {"enabled": true, "open": "12:00", "close": "22:00"},
        "friday": {"enabled": true, "open": "12:00", "close": "23:00"},
        "saturday": {"enabled": true, "open": "12:00", "close": "23:00"},
        "sunday": {"enabled": true, "open": "13:00", "close": "21:00"}
    }',
    special_hours JSONB DEFAULT '[]', -- Holidays, special events
    
    -- Regional Settings (NO HARDCODED VALUES)
    currency_code VARCHAR(3) NOT NULL DEFAULT 'MXN',
    currency_symbol VARCHAR(5) NOT NULL DEFAULT '$',
    currency_position VARCHAR(10) DEFAULT 'before', -- 'before' or 'after'
    decimal_separator VARCHAR(1) DEFAULT '.',
    thousands_separator VARCHAR(1) DEFAULT ',',
    decimal_places INT DEFAULT 2,
    tax_rate_percentage DECIMAL(5,2) DEFAULT 0.00,
    tax_included_in_prices BOOLEAN DEFAULT true,
    
    -- Delivery Settings
    is_open BOOLEAN DEFAULT true,
    accepts_delivery BOOLEAN DEFAULT true,
    accepts_pickup BOOLEAN DEFAULT true,
    accepts_dine_in BOOLEAN DEFAULT false,
    delivery_radius_km DECIMAL(5,2),
    minimum_order_cents INT DEFAULT 0,
    delivery_fee_cents INT DEFAULT 0,
    delivery_fee_per_km_cents INT DEFAULT 0, -- Variable rate per km
    free_delivery_threshold_cents INT, -- Free delivery above this amount
    estimated_prep_minutes INT DEFAULT 30,
    estimated_delivery_minutes INT DEFAULT 30,
    
    -- Payment/Billing Settings (from AdminDashboard)
    accepts_card BOOLEAN DEFAULT true,
    accepts_cash BOOLEAN DEFAULT true,
    accepts_transfer BOOLEAN DEFAULT true,
    bank_account_clabe VARCHAR(20), -- For transfers
    bank_account_name VARCHAR(255),
    bank_name VARCHAR(100),
    payment_processor VARCHAR(50), -- 'stripe', 'mercadopago', 'openpay'
    payment_processor_account_id VARCHAR(255),

    
    -- Driver Commission (customizable per restaurant)
    driver_commission_type VARCHAR(20) DEFAULT 'percentage', -- 'percentage', 'fixed', 'per_km'
    driver_commission_value DECIMAL(10,2) DEFAULT 15.00, -- 15% or fixed amount
    
    -- Customer Settings
    allow_guest_orders BOOLEAN DEFAULT false,
    require_phone_verification BOOLEAN DEFAULT false,
    loyalty_points_enabled BOOLEAN DEFAULT false,
    loyalty_points_per_currency_unit DECIMAL(5,2) DEFAULT 1.00,
    
    -- Subscription
    subscription_plan_id UUID REFERENCES subscription_plans(id),
    subscription_status subscription_status DEFAULT 'trial',
    subscription_started_at TIMESTAMPTZ,
    subscription_ends_at TIMESTAMPTZ,
    trial_ends_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '14 days'),
    
    -- Stats (aggregated for performance)
    total_orders_count INT DEFAULT 0,
    total_revenue_cents BIGINT DEFAULT 0,
    total_customers_count INT DEFAULT 0,
    total_drivers_count INT DEFAULT 0,
    average_rating DECIMAL(2,1) DEFAULT 0.0,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_order_at TIMESTAMPTZ,
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    
    -- Soft delete
    deleted_at TIMESTAMPTZ
);

-- Restaurant admins
CREATE TABLE restaurant_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    role VARCHAR(50) NOT NULL DEFAULT 'owner' CHECK (role IN ('owner', 'manager', 'staff', 'kitchen')),
    avatar_url VARCHAR(2048),
    permissions JSONB DEFAULT '{}', -- Fine-grained permissions
    is_primary BOOLEAN DEFAULT false,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (restaurant_id, email)
);

-- ============================================================================
-- SECTION 3: CUSTOMERS (Per Restaurant - NOT Shared)
-- ============================================================================

-- Each customer belongs to ONE restaurant
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    
    -- Profile
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    photo_url VARCHAR(2048),
    
    -- Status
    status customer_status DEFAULT 'active',
    
    -- Preferences (stored per-restaurant, no hardcoding)
    preferred_language VARCHAR(10) DEFAULT 'es',
    notifications_enabled BOOLEAN DEFAULT true,
    marketing_opt_in BOOLEAN DEFAULT false,
    
    -- Loyalty (if enabled by restaurant)
    loyalty_points INT DEFAULT 0,
    loyalty_tier VARCHAR(50),
    
    -- Stats
    total_orders_count INT DEFAULT 0,
    total_spent_cents BIGINT DEFAULT 0,
    average_order_cents INT DEFAULT 0,
    last_order_at TIMESTAMPTZ,
    
    -- Device info for analytics
    last_device_type VARCHAR(50),
    last_app_version VARCHAR(20),
    last_os VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE (restaurant_id, email),
    UNIQUE (restaurant_id, phone)
);

-- Customer addresses (per restaurant)
CREATE TABLE customer_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    label VARCHAR(100) NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    address_details VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    delivery_instructions TEXT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Customer payment methods (per restaurant)
CREATE TABLE customer_payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    type payment_type NOT NULL,
    label VARCHAR(100), -- "Mi Visa", "Efectivo"
    card_last_four VARCHAR(4),
    card_brand VARCHAR(50),
    card_holder_name VARCHAR(255),
    expiry_month INT,
    expiry_year INT,
    payment_processor VARCHAR(50), -- 'stripe', 'mercadopago', etc.
    payment_token TEXT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SECTION 4: CUSTOMER SHARING & PREFERENCES (Future Capability)
-- ============================================================================

-- Future: Customer-Restaurant assignments (for sharing customers between pizzerias)
-- By default, customers belong to ONE restaurant via customers.restaurant_id
-- This table enables optional future customer sharing between pizzerias
CREATE TABLE customer_restaurant_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT false, -- Primary/original restaurant
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked')),
    
    -- Per-restaurant customer data (when sharing)
    loyalty_points INT DEFAULT 0,
    loyalty_tier VARCHAR(50),
    total_orders_count INT DEFAULT 0,
    total_spent_cents BIGINT DEFAULT 0,
    last_order_at TIMESTAMPTZ,
    
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (customer_id, restaurant_id)
);

-- Customer notification preferences (granular per type, per restaurant)
CREATE TABLE customer_notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    
    -- Notification types (matches CustomerApp settings)
    all_notifications BOOLEAN DEFAULT true,
    order_updates BOOLEAN DEFAULT true,
    promotions BOOLEAN DEFAULT true,
    new_products BOOLEAN DEFAULT true,
    delivery_reminders BOOLEAN DEFAULT true,
    chat_messages BOOLEAN DEFAULT true,
    weekly_offers BOOLEAN DEFAULT true,
    app_updates BOOLEAN DEFAULT true,
    
    -- Sound & Vibration
    sound_enabled BOOLEAN DEFAULT true,
    vibration_enabled BOOLEAN DEFAULT true,
    sound_type VARCHAR(50) DEFAULT 'default',
    
    -- Quiet Hours (Do Not Disturb)
    quiet_hours_enabled BOOLEAN DEFAULT false,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (customer_id, restaurant_id)
);

-- ============================================================================
-- SECTION 5: DRIVERS (Per Restaurant - Sharing Optional Future)
-- ============================================================================

-- Each driver belongs to ONE restaurant (by default)
-- Future: can add driver_restaurant_assignments table for sharing

CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    
    -- Profile
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    photo_url VARCHAR(2048),
    
    -- Vehicle (fully customizable)
    vehicle_type vehicle_type DEFAULT 'moto',
    vehicle_brand VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_color VARCHAR(50),
    vehicle_year INT,
    license_plate VARCHAR(20),
    
    -- Documents (for verification)
    id_document_url VARCHAR(2048),
    license_url VARCHAR(2048),
    vehicle_registration_url VARCHAR(2048),
    insurance_url VARCHAR(2048),
    
    -- Status
    status driver_status DEFAULT 'pending',
    is_online BOOLEAN DEFAULT false,
    is_on_delivery BOOLEAN DEFAULT false,
    
    -- Location
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    last_location_update TIMESTAMPTZ,
    
    -- Settings (CourierApp Profile)
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications_enabled BOOLEAN DEFAULT true, -- CourierApp: emailNotificationsEnabled
    preferred_language VARCHAR(10) DEFAULT 'es', -- CourierApp: language preference
    fcm_token TEXT, -- Firebase Cloud Messaging token for Supabase push notifications
    max_concurrent_orders INT DEFAULT 2,
    
    -- Stats
    total_deliveries INT DEFAULT 0,
    total_earnings_cents BIGINT DEFAULT 0,
    rating_sum INT DEFAULT 0, -- Sum of all ratings
    rating_count INT DEFAULT 0, -- Number of ratings
    average_rating DECIMAL(2,1) GENERATED ALWAYS AS (
        CASE WHEN rating_count > 0 THEN rating_sum::DECIMAL / rating_count ELSE 0 END
    ) STORED,
    average_delivery_minutes INT,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    last_delivery_at TIMESTAMPTZ,
    
    UNIQUE (restaurant_id, email),
    UNIQUE (restaurant_id, phone)
);

-- Driver earnings (detailed history)
CREATE TABLE driver_earnings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    order_id UUID,
    amount_cents INT NOT NULL,
    type VARCHAR(50) DEFAULT 'delivery', -- 'delivery', 'tip', 'bonus', 'adjustment'
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Future: Driver-Restaurant assignments (for sharing drivers)
CREATE TABLE driver_restaurant_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT false, -- Primary restaurant
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    UNIQUE (driver_id, restaurant_id)
);

-- ============================================================================
-- SECTION 5: PRODUCTS & MENU
-- ============================================================================

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(2048),
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    
    -- Scheduling (category available only at certain times)
    availability_schedule JSONB, -- {"monday": {"start": "12:00", "end": "15:00"}}
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(255),
    
    -- Pricing
    price_cents INT NOT NULL,
    compare_at_price_cents INT, -- Original price for discount display
    cost_cents INT, -- Cost for profit calculations
    
    -- Media
    image_url VARCHAR(2048),
    images JSONB DEFAULT '[]', -- Multiple images
    
    -- Inventory
    is_available BOOLEAN DEFAULT true,
    track_inventory BOOLEAN DEFAULT false,
    inventory_count INT,
    low_stock_threshold INT DEFAULT 5,
    
    -- Attributes
    is_featured BOOLEAN DEFAULT false,
    is_new BOOLEAN DEFAULT false,
    is_bestseller BOOLEAN DEFAULT false,
    
    -- Dietary/Info
    calories INT,
    preparation_time_minutes INT,
    tags JSONB DEFAULT '[]', -- ["vegetariano", "picante", "sin gluten"]
    allergens JSONB DEFAULT '[]', -- ["gluten", "lactosa"]
    
    -- Display
    display_order INT DEFAULT 0,
    
    -- Stats
    total_sold INT DEFAULT 0,
    total_revenue_cents BIGINT DEFAULT 0,
    rating_sum INT DEFAULT 0,
    rating_count INT DEFAULT 0,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE addons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_cents INT DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    max_quantity INT DEFAULT 10,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE category_addons (
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    addon_id UUID NOT NULL REFERENCES addons(id) ON DELETE CASCADE,
    PRIMARY KEY (category_id, addon_id)
);

CREATE TABLE product_addons (
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    addon_id UUID NOT NULL REFERENCES addons(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, addon_id)
);

-- Product variants (sizes, etc.)
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- "Grande", "Familiar"
    price_cents INT NOT NULL,
    is_default BOOLEAN DEFAULT false,
    display_order INT DEFAULT 0
);

-- ============================================================================
-- SECTION 6: PROMOTIONS & COUPONS
-- ============================================================================

CREATE TABLE promotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL, -- 'percentage', 'fixed', 'bogo', 'bundle'
    
    -- Discount
    discount_percentage INT CHECK (discount_percentage BETWEEN 0 AND 100),
    discount_amount_cents INT,
    
    -- Conditions
    minimum_order_cents INT DEFAULT 0,
    maximum_discount_cents INT,
    
    -- Validity
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    
    -- Usage limits
    max_uses INT,
    max_uses_per_customer INT DEFAULT 1,
    current_uses INT DEFAULT 0,
    
    -- Media
    image_url VARCHAR(2048),
    banner_url VARCHAR(2048),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE promotion_products (
    promotion_id UUID NOT NULL REFERENCES promotions(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    PRIMARY KEY (promotion_id, product_id)
);

CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    
    type VARCHAR(50) NOT NULL, -- 'percentage', 'fixed'
    discount_percentage INT,
    discount_amount_cents INT,
    
    minimum_order_cents INT DEFAULT 0,
    maximum_discount_cents INT,
    
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    
    max_uses INT,
    max_uses_per_customer INT DEFAULT 1,
    current_uses INT DEFAULT 0,
    
    is_active BOOLEAN DEFAULT true,
    
    -- Targeting
    first_order_only BOOLEAN DEFAULT false,
    specific_customer_ids UUID[],
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE (restaurant_id, code)
);

CREATE TABLE customer_coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    used_at TIMESTAMPTZ,
    order_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (customer_id, coupon_id)
);

-- ============================================================================
-- SECTION 7: ORDERS
-- ============================================================================

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    order_number VARCHAR(20) NOT NULL,
    
    -- Pricing (all in cents, currency in restaurant settings)
    subtotal_cents INT NOT NULL,
    tax_cents INT DEFAULT 0,
    delivery_fee_cents INT DEFAULT 0,
    tip_cents INT DEFAULT 0,
    discount_cents INT DEFAULT 0,
    total_cents INT NOT NULL,
    
    -- Driver
    driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
    driver_earnings_cents INT DEFAULT 0,
    
    -- Customer
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    delivery_address_id UUID REFERENCES customer_addresses(id) ON DELETE SET NULL,
    
    -- Coupon
    coupon_id UUID REFERENCES coupons(id) ON DELETE SET NULL,
    
    -- Snapshots (preserved even if related data deleted)
    customer_snapshot JSONB, -- {name, email, phone}
    address_snapshot JSONB, -- Full address at time of order
    
    -- Delivery
    order_type VARCHAR(20) DEFAULT 'delivery', -- 'delivery', 'pickup', 'dine_in'
    distance_km DECIMAL(5, 2),
    estimated_prep_minutes INT,
    estimated_delivery_minutes INT,
    
    -- Status
    status order_status DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'pending',
    payment_reference VARCHAR(255),
    
    -- Notes
    customer_notes TEXT,
    kitchen_notes TEXT,
    driver_notes TEXT,
    cancellation_reason TEXT,
    cancelled_by VARCHAR(50), -- 'customer', 'restaurant', 'driver', 'system'
    
    -- Ratings
    customer_rating INT CHECK (customer_rating BETWEEN 1 AND 5),
    customer_review TEXT,
    driver_rating INT CHECK (driver_rating BETWEEN 1 AND 5),
    food_rating INT CHECK (food_rating BETWEEN 1 AND 5),
    
    -- Timestamps (ALL tracked for analytics)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    processing_at TIMESTAMPTZ,
    ready_at TIMESTAMPTZ,
    picked_up_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE (restaurant_id, order_number)
);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    variant_id UUID REFERENCES product_variants(id) ON DELETE SET NULL,
    
    -- Snapshot
    product_name VARCHAR(255) NOT NULL,
    variant_name VARCHAR(100),
    product_image_url VARCHAR(2048),
    
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price_cents INT NOT NULL,
    total_price_cents INT NOT NULL,
    
    notes TEXT
);

CREATE TABLE order_item_addons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    addon_id UUID REFERENCES addons(id) ON DELETE SET NULL,
    addon_name VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price_cents INT NOT NULL,
    total_price_cents INT NOT NULL
);

-- Order status history (every change tracked)
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    previous_status order_status,
    new_status order_status NOT NULL,
    changed_by_type VARCHAR(50), -- 'system', 'admin', 'driver', 'customer'
    changed_by_id UUID,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SECTION 7B: RESTAURANT REPORTS (For Pizzeria Owners - AdminDashboard)
-- ============================================================================
-- IMPORTANT: These tables are for the PIZZERIA OWNER to see their own reports.
-- They are DIFFERENT from Section 8 (SaaS Analytics) which is for the 
-- platform owner/developer to track metadata across ALL restaurants.
--
-- Data Source: AdminDashboard Reports pages
-- - getDailyRevenueInPeriod: Revenue chart by date range
-- - getSalesTransactions: Order list with items for a period
-- - getPopularProducts: Best-selling products ranking
-- ============================================================================

-- Daily reports aggregated for each restaurant (pre-computed for fast queries)
-- Used by: AdminDashboard > Reports > Sales Report
CREATE TABLE restaurant_daily_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- Order counts (what the pizzeria owner sees)
    orders_total INT DEFAULT 0,
    orders_completed INT DEFAULT 0,
    orders_cancelled INT DEFAULT 0,
    orders_delivery INT DEFAULT 0,
    orders_pickup INT DEFAULT 0,
    
    -- Revenue (in cents, using restaurant's currency)
    revenue_total_cents BIGINT DEFAULT 0,
    revenue_after_discounts_cents BIGINT DEFAULT 0,
    discounts_total_cents BIGINT DEFAULT 0,
    tips_total_cents BIGINT DEFAULT 0,
    delivery_fees_collected_cents BIGINT DEFAULT 0,
    
    -- Customer metrics
    new_customers INT DEFAULT 0,
    returning_customers INT DEFAULT 0,
    
    -- Timing (for operations analysis)
    avg_preparation_minutes DECIMAL(5,2),
    avg_delivery_minutes DECIMAL(5,2),
    
    -- Top products of the day (pre-aggregated for fast chart loading)
    -- Format: [{"product_id": "uuid", "product_name": "Pizza Margherita", "quantity": 25, "revenue_cents": 50000}]
    top_products_json JSONB DEFAULT '[]',
    
    -- Hourly breakdown (for peak hours chart)
    -- Format: {"09": {"orders": 5, "revenue": 10000}, "10": {"orders": 8, "revenue": 16000}, ...}
    hourly_breakdown_json JSONB DEFAULT '{}',
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE (restaurant_id, date)
);

-- Product sales ranking (for "Productos Más Vendidos" report)
-- Used by: AdminDashboard > Reports > Popular Products
CREATE TABLE restaurant_product_sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    
    -- Period (for flexible reporting: daily, weekly, monthly)
    period_type VARCHAR(20) NOT NULL CHECK (period_type IN ('daily', 'weekly', 'monthly')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Sales data
    quantity_sold INT DEFAULT 0,
    revenue_cents BIGINT DEFAULT 0,
    
    -- Ranking position (1 = best seller)
    rank_position INT,
    
    -- Comparison with previous period
    quantity_diff_from_previous INT DEFAULT 0,
    revenue_diff_from_previous BIGINT DEFAULT 0,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE (restaurant_id, product_id, period_type, period_start)
);

-- Dashboard summary (for main AdminDashboard metrics cards)
-- Used by: AdminDashboard > Dashboard > Day/Month metrics cards
CREATE TABLE restaurant_dashboard_summary (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    
    -- Today's metrics (refreshed periodically)
    today_orders INT DEFAULT 0,
    today_revenue_cents BIGINT DEFAULT 0,
    today_diff_from_yesterday DECIMAL(5,2), -- Percentage
    
    -- This month's metrics
    month_orders INT DEFAULT 0,
    month_revenue_cents BIGINT DEFAULT 0,
    month_cancelled_orders INT DEFAULT 0,
    month_diff_from_last_month DECIMAL(5,2), -- Percentage
    
    -- Active drivers right now
    active_drivers INT DEFAULT 0,
    online_drivers INT DEFAULT 0,
    
    -- Pending actions
    pending_orders INT DEFAULT 0,
    orders_in_preparation INT DEFAULT 0,
    orders_ready_for_pickup INT DEFAULT 0,
    orders_in_delivery INT DEFAULT 0,
    
    -- Last updated
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE (restaurant_id)
);

-- Trigger to update restaurant_dashboard_summary when orders change
CREATE OR REPLACE FUNCTION update_restaurant_dashboard()
RETURNS TRIGGER AS $$
BEGIN
    -- Update today's and month's counts
    INSERT INTO restaurant_dashboard_summary (restaurant_id, today_orders, pending_orders, updated_at)
    VALUES (NEW.restaurant_id, 1, 1, NOW())
    ON CONFLICT (restaurant_id) DO UPDATE SET
        pending_orders = (
            SELECT COUNT(*) FROM orders 
            WHERE restaurant_id = NEW.restaurant_id 
            AND status = 'pending'
        ),
        orders_in_preparation = (
            SELECT COUNT(*) FROM orders 
            WHERE restaurant_id = NEW.restaurant_id 
            AND status = 'processing'
        ),
        orders_ready_for_pickup = (
            SELECT COUNT(*) FROM orders 
            WHERE restaurant_id = NEW.restaurant_id 
            AND status = 'ready'
        ),
        orders_in_delivery = (
            SELECT COUNT(*) FROM orders 
            WHERE restaurant_id = NEW.restaurant_id 
            AND status = 'delivering'
        ),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_update_dashboard_on_order
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_restaurant_dashboard();

-- Index for fast report queries
CREATE INDEX idx_restaurant_daily_reports ON restaurant_daily_reports(restaurant_id, date DESC);
CREATE INDEX idx_restaurant_product_sales ON restaurant_product_sales(restaurant_id, period_start DESC);

-- ============================================================================
-- SECTION 8: COMPREHENSIVE ANALYTICS & METADATA (For SaaS Owner/Developer)
-- ============================================================================
-- IMPORTANT: This section is for the PLATFORM OWNER (you as the developer/company)
-- to collect metadata across ALL restaurants for your analytics platform.
-- The pizzeria owners do NOT see these tables - they see Section 7B above.
-- ============================================================================

-- Event log (EVERY action captured for complete metadata)
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Context
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE SET NULL,
    session_id VARCHAR(100), -- Track user session
    
    -- Event
    category event_category NOT NULL,
    action VARCHAR(100) NOT NULL, -- 'login', 'view_product', 'add_to_cart', etc.
    label VARCHAR(255), -- Additional context
    value DECIMAL(15,4), -- Numeric value if applicable
    
    -- Actor
    actor_type VARCHAR(50), -- 'customer', 'driver', 'admin', 'system', 'anonymous'
    actor_id UUID, -- User ID if authenticated
    
    -- Device & Location
    device_type VARCHAR(50), -- 'mobile', 'tablet', 'desktop'
    device_os VARCHAR(50), -- 'iOS', 'Android', 'Windows'
    device_brand VARCHAR(50),
    device_model VARCHAR(100),
    app_version VARCHAR(20),
    browser VARCHAR(50),
    browser_version VARCHAR(20),
    
    -- Network
    ip_address INET,
    country VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    
    -- Screen/Page
    screen_name VARCHAR(100),
    referrer VARCHAR(500),
    
    -- Additional data (flexible)
    properties JSONB DEFAULT '{}',
    
    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Daily metrics per restaurant
CREATE TABLE analytics_daily_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- Orders
    orders_total INT DEFAULT 0,
    orders_completed INT DEFAULT 0,
    orders_cancelled INT DEFAULT 0,
    orders_delivery INT DEFAULT 0,
    orders_pickup INT DEFAULT 0,
    
    -- Revenue
    revenue_gross_cents BIGINT DEFAULT 0,
    revenue_net_cents BIGINT DEFAULT 0, -- After discounts
    revenue_delivery_fees_cents BIGINT DEFAULT 0,
    revenue_tips_cents BIGINT DEFAULT 0,
    average_order_cents INT DEFAULT 0,
    
    -- Customers
    customers_new INT DEFAULT 0,
    customers_returning INT DEFAULT 0,
    customers_total INT DEFAULT 0,
    
    -- Products
    products_sold INT DEFAULT 0,
    top_products JSONB DEFAULT '[]', -- [{product_id, name, quantity, revenue}]
    
    -- Timing
    avg_prep_time_minutes INT,
    avg_delivery_time_minutes INT,
    avg_total_time_minutes INT,
    
    -- Ratings
    ratings_count INT DEFAULT 0,
    ratings_average DECIMAL(2,1),
    
    -- Drivers
    drivers_active INT DEFAULT 0,
    deliveries_per_driver DECIMAL(5,2),
    
    -- App usage
    app_opens INT DEFAULT 0,
    cart_abandonment_rate DECIMAL(5,2),
    
    UNIQUE (restaurant_id, date)
);

-- Hourly traffic (for peak hours analysis)
CREATE TABLE analytics_hourly_traffic (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    hour INT NOT NULL CHECK (hour BETWEEN 0 AND 23),
    
    orders_count INT DEFAULT 0,
    revenue_cents BIGINT DEFAULT 0,
    unique_customers INT DEFAULT 0,
    page_views INT DEFAULT 0,
    
    UNIQUE (restaurant_id, date, hour)
);

-- Product performance
CREATE TABLE analytics_product_performance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    views INT DEFAULT 0,
    add_to_carts INT DEFAULT 0,
    purchases INT DEFAULT 0,
    quantity_sold INT DEFAULT 0,
    revenue_cents BIGINT DEFAULT 0,
    
    conversion_rate DECIMAL(5,2), -- purchases / views * 100
    
    UNIQUE (restaurant_id, product_id, period_start, period_end)
);

-- Customer cohorts
CREATE TABLE analytics_customer_cohorts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    cohort_month DATE NOT NULL, -- First day of month customer joined
    months_since_first_order INT NOT NULL,
    
    customers_count INT DEFAULT 0,
    orders_count INT DEFAULT 0,
    revenue_cents BIGINT DEFAULT 0,
    retention_rate DECIMAL(5,2),
    
    UNIQUE (restaurant_id, cohort_month, months_since_first_order)
);

-- Platform-wide stats (SaaS owner analytics)
CREATE TABLE analytics_platform_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE UNIQUE NOT NULL,
    
    -- Restaurants
    restaurants_total INT DEFAULT 0,
    restaurants_active INT DEFAULT 0,
    restaurants_new INT DEFAULT 0,
    restaurants_churned INT DEFAULT 0,
    
    -- Orders (all restaurants)
    orders_total INT DEFAULT 0,
    orders_completed INT DEFAULT 0,
    gmv_cents BIGINT DEFAULT 0, -- Gross Merchandise Value
    
    -- Users
    customers_total INT DEFAULT 0,
    customers_new INT DEFAULT 0,
    drivers_total INT DEFAULT 0,
    drivers_active INT DEFAULT 0,
    
    -- Revenue (SaaS)
    mrr_cents BIGINT DEFAULT 0, -- Monthly Recurring Revenue
    arr_cents BIGINT DEFAULT 0, -- Annual Recurring Revenue
    subscription_revenue_cents BIGINT DEFAULT 0,
    
    -- Subscriptions
    trial_restaurants INT DEFAULT 0,
    paying_restaurants INT DEFAULT 0,
    trial_conversions INT DEFAULT 0,
    cancellations INT DEFAULT 0,
    
    -- By plan
    subscriptions_by_plan JSONB DEFAULT '{}', -- {"starter": 10, "growth": 5}
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SECTION 9: NOTIFICATIONS
-- ============================================================================

CREATE TABLE notification_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    user_type VARCHAR(50) NOT NULL, -- 'customer', 'driver', 'admin'
    user_id UUID NOT NULL,
    token TEXT NOT NULL,
    device_type VARCHAR(50),
    device_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_type, user_id, token)
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    recipient_type VARCHAR(50) NOT NULL,
    recipient_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SECTION 10: FUNCTIONS AND TRIGGERS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
DECLARE
    next_num INT;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(order_number FROM 2) AS INT)), 0) + 1
    INTO next_num
    FROM orders WHERE restaurant_id = NEW.restaurant_id;
    
    NEW.order_number = '#' || LPAD(next_num::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO order_status_history (order_id, previous_status, new_status)
        VALUES (NEW.id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_stats_on_order()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'delivered' AND (OLD.status IS NULL OR OLD.status != 'delivered') THEN
        -- Update restaurant
        UPDATE restaurants SET
            total_orders_count = total_orders_count + 1,
            total_revenue_cents = total_revenue_cents + NEW.total_cents,
            last_order_at = NOW()
        WHERE id = NEW.restaurant_id;
        
        -- Update customer
        IF NEW.customer_id IS NOT NULL THEN
            UPDATE customers SET
                total_orders_count = total_orders_count + 1,
                total_spent_cents = total_spent_cents + NEW.total_cents,
                last_order_at = NOW()
            WHERE id = NEW.customer_id;
        END IF;
        
        -- Update driver
        IF NEW.driver_id IS NOT NULL THEN
            UPDATE drivers SET
                total_deliveries = total_deliveries + 1,
                total_earnings_cents = total_earnings_cents + NEW.driver_earnings_cents,
                last_delivery_at = NOW()
            WHERE id = NEW.driver_id;
            
            INSERT INTO driver_earnings (driver_id, restaurant_id, order_id, amount_cents, type)
            VALUES (NEW.driver_id, NEW.restaurant_id, NEW.id, NEW.driver_earnings_cents, 'delivery');
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER tr_restaurants_updated_at BEFORE UPDATE ON restaurants FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_restaurant_admins_updated_at BEFORE UPDATE ON restaurant_admins FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_drivers_updated_at BEFORE UPDATE ON drivers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_addons_updated_at BEFORE UPDATE ON addons FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_promotions_updated_at BEFORE UPDATE ON promotions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_subscription_plans_updated_at BEFORE UPDATE ON subscription_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_order_number BEFORE INSERT ON orders FOR EACH ROW WHEN (NEW.order_number IS NULL) EXECUTE FUNCTION generate_order_number();
CREATE TRIGGER tr_order_status_history AFTER UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION log_order_status_change();
CREATE TRIGGER tr_order_stats AFTER UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_stats_on_order();

-- ============================================================================
-- SECTION 11: ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Admins see only their restaurant
CREATE POLICY "admin_restaurant_access" ON restaurants FOR ALL 
    USING (id IN (SELECT restaurant_id FROM restaurant_admins WHERE id = auth.uid()));

-- Customers see only their restaurant's data
CREATE POLICY "customer_own_data" ON customers FOR ALL 
    USING (id = auth.uid());

CREATE POLICY "customer_addresses_own" ON customer_addresses FOR ALL 
    USING (customer_id = auth.uid());

CREATE POLICY "customer_payments_own" ON customer_payment_methods FOR ALL 
    USING (customer_id = auth.uid());

CREATE POLICY "customer_orders_own" ON orders FOR SELECT 
    USING (customer_id = auth.uid());

-- Drivers see only their restaurant's orders
CREATE POLICY "driver_own_data" ON drivers FOR ALL 
    USING (id = auth.uid());

CREATE POLICY "driver_orders" ON orders FOR SELECT 
    USING (restaurant_id IN (SELECT restaurant_id FROM drivers WHERE id = auth.uid()));

CREATE POLICY "driver_earnings_own" ON driver_earnings FOR SELECT 
    USING (driver_id = auth.uid());

-- Public read for menu (filtered by restaurant in app)
CREATE POLICY "public_categories" ON categories FOR SELECT USING (is_active = true);
CREATE POLICY "public_products" ON products FOR SELECT USING (is_available = true);
CREATE POLICY "public_addons" ON addons FOR SELECT USING (is_available = true);

-- ============================================================================
-- SECTION 12: REALTIME & INDEXES
-- ============================================================================

ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE drivers;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- Performance indexes
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_driver ON orders(driver_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
CREATE INDEX idx_orders_restaurant_status ON orders(restaurant_id, status);

CREATE INDEX idx_customers_restaurant ON customers(restaurant_id);
CREATE INDEX idx_drivers_restaurant ON drivers(restaurant_id);
CREATE INDEX idx_drivers_online ON drivers(restaurant_id, is_online);

CREATE INDEX idx_products_restaurant ON products(restaurant_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_categories_restaurant ON categories(restaurant_id);

CREATE INDEX idx_events_restaurant ON analytics_events(restaurant_id);
CREATE INDEX idx_events_created ON analytics_events(created_at DESC);
CREATE INDEX idx_events_category ON analytics_events(category, action);

CREATE INDEX idx_daily_metrics ON analytics_daily_metrics(restaurant_id, date DESC);

-- ============================================================================
-- SECTION 13: INITIAL DATA (Editable Subscription Plans)
-- ============================================================================

INSERT INTO subscription_plans (slug, name, description, price_monthly_cents, price_yearly_cents, limits, features, display_order, is_recommended, badge_text) VALUES
(
    'starter',
    'Starter',
    'Perfecto para empezar tu pizzería digital',
    49900, -- $499 MXN/month
    479900, -- $4,799 MXN/year (2 months free)
    '{"max_products": 50, "max_categories": 10, "max_addons": 25, "max_drivers": 3, "max_orders_per_month": 500, "max_customers": 500, "max_admins": 2}',
    '{"analytics_basic": true, "analytics_advanced": false, "promotions": true, "coupons": false, "realtime_tracking": true, "custom_branding": false, "api_access": false, "priority_support": false, "export_data": false}',
    1, false, NULL
),
(
    'growth',
    'Growth',
    'Para pizzerías en crecimiento',
    99900, -- $999 MXN/month
    959900, -- $9,599 MXN/year
    '{"max_products": 200, "max_categories": 30, "max_addons": 100, "max_drivers": 10, "max_orders_per_month": 2000, "max_customers": 2000, "max_admins": 5}',
    '{"analytics_basic": true, "analytics_advanced": true, "promotions": true, "coupons": true, "realtime_tracking": true, "custom_branding": true, "api_access": false, "priority_support": true, "export_data": true}',
    2, true, 'Más Popular'
),
(
    'enterprise',
    'Enterprise',
    'Para cadenas y franquicias',
    249900, -- $2,499 MXN/month
    2399900, -- $23,999 MXN/year
    '{"max_products": null, "max_categories": null, "max_addons": null, "max_drivers": null, "max_orders_per_month": null, "max_customers": null, "max_admins": null}',
    '{"analytics_basic": true, "analytics_advanced": true, "promotions": true, "coupons": true, "realtime_tracking": true, "custom_branding": true, "api_access": true, "priority_support": true, "export_data": true, "white_label": true, "multi_location": true}',
    3, false, 'Todo Incluido'
);

INSERT INTO platform_config (key, value, value_type, category, label, description, is_public) VALUES
('platform_name', '"Napoli SaaS"', 'string', 'general', 'Nombre de la Plataforma', 'Nombre del SaaS', true),
('platform_version', '"4.0.0"', 'string', 'general', 'Versión', 'Versión actual del sistema', true),
('default_trial_days', '14', 'number', 'subscription', 'Días de Prueba', 'Días de trial para nuevos restaurantes', false),
('min_driver_commission_pct', '10', 'number', 'drivers', 'Comisión Mínima Driver (%)', 'Comisión mínima permitida', false),
('max_driver_commission_pct', '30', 'number', 'drivers', 'Comisión Máxima Driver (%)', 'Comisión máxima permitida', false),
('supported_currencies', '["MXN", "USD", "EUR", "COP", "ARS", "CLP", "PEN"]', 'json', 'regional', 'Monedas Soportadas', 'Lista de monedas disponibles', true),
('supported_timezones', '["America/Mexico_City", "America/New_York", "America/Los_Angeles", "America/Bogota", "America/Lima", "America/Santiago", "America/Argentina/Buenos_Aires", "Europe/Madrid"]', 'json', 'regional', 'Zonas Horarias', 'Zonas horarias disponibles', true),
('supported_languages', '["es", "en", "pt"]', 'json', 'regional', 'Idiomas Soportados', 'Idiomas disponibles en la plataforma', true),
('support_email', '"soporte@napoli-saas.com"', 'string', 'support', 'Email de Soporte', 'Email para soporte técnico', true),
('support_whatsapp', '"+521234567890"', 'string', 'support', 'WhatsApp Soporte', 'Número de WhatsApp para soporte', true);

-- ============================================================================
-- SECTION 14: STORAGE BUCKETS (Supabase Storage)
-- ============================================================================
-- NOTE: Execute these commands in Supabase Dashboard > SQL Editor
-- Or use Supabase CLI: supabase storage create <bucket-name>

-- Create buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('restaurant-assets', 'restaurant-assets', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']),
('product-images', 'product-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
('category-images', 'category-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
('driver-photos', 'driver-photos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
('driver-documents', 'driver-documents', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
('customer-photos', 'customer-photos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
('payment-receipts', 'payment-receipts', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STORAGE POLICIES
-- ============================================================================

-- Restaurant assets: Admins can upload, public can view
CREATE POLICY "restaurant_assets_public_read" ON storage.objects FOR SELECT
    USING (bucket_id = 'restaurant-assets');

CREATE POLICY "restaurant_assets_admin_insert" ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'restaurant-assets' AND 
        auth.uid() IN (SELECT id FROM restaurant_admins));

CREATE POLICY "restaurant_assets_admin_update" ON storage.objects FOR UPDATE
    USING (bucket_id = 'restaurant-assets' AND 
        auth.uid() IN (SELECT id FROM restaurant_admins));

CREATE POLICY "restaurant_assets_admin_delete" ON storage.objects FOR DELETE
    USING (bucket_id = 'restaurant-assets' AND 
        auth.uid() IN (SELECT id FROM restaurant_admins));

-- Product images: Admins can upload, public can view
CREATE POLICY "product_images_public_read" ON storage.objects FOR SELECT
    USING (bucket_id = 'product-images');

CREATE POLICY "product_images_admin_write" ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'product-images' AND 
        auth.uid() IN (SELECT id FROM restaurant_admins));

-- Category images: Admins can upload, public can view
CREATE POLICY "category_images_public_read" ON storage.objects FOR SELECT
    USING (bucket_id = 'category-images');

CREATE POLICY "category_images_admin_write" ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'category-images' AND 
        auth.uid() IN (SELECT id FROM restaurant_admins));

-- Driver photos: Public read, drivers can upload their own
CREATE POLICY "driver_photos_public_read" ON storage.objects FOR SELECT
    USING (bucket_id = 'driver-photos');

CREATE POLICY "driver_photos_driver_write" ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'driver-photos' AND 
        auth.uid()::text = (storage.foldername(name))[1]);

-- Driver documents: Drivers upload, admins can view their restaurant's drivers
CREATE POLICY "driver_documents_driver_write" ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'driver-documents' AND 
        auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "driver_documents_admin_read" ON storage.objects FOR SELECT
    USING (bucket_id = 'driver-documents' AND 
        auth.uid() IN (SELECT id FROM restaurant_admins));

-- Customer photos: Customers upload their own, public read
CREATE POLICY "customer_photos_public_read" ON storage.objects FOR SELECT
    USING (bucket_id = 'customer-photos');

CREATE POLICY "customer_photos_customer_write" ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'customer-photos' AND 
        auth.uid()::text = (storage.foldername(name))[1]);

-- Payment receipts: Customers upload, admins view their restaurant's receipts
CREATE POLICY "payment_receipts_customer_write" ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'payment-receipts');

CREATE POLICY "payment_receipts_admin_read" ON storage.objects FOR SELECT
    USING (bucket_id = 'payment-receipts' AND 
        auth.uid() IN (SELECT id FROM restaurant_admins));
