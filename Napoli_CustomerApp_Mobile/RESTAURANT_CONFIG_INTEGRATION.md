# 🛍️ Napoli CustomerApp - Restaurant Configuration Integration Guide

**Version**: 1.0  
**Date**: 2025-12-30  
**Purpose**: Detailed implementation guide for integrating AdminDashboard restaurant configurations into CustomerApp

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current Architecture Analysis](#current-architecture-analysis)
3. [Required Stored Procedures](#required-stored-procedures)
4. [Dart Implementation Changes](#dart-implementation-changes)
5. [Implementation Roadmap](#implementation-roadmap)
6. [Testing Strategy](#testing-strategy)

---

## 🎯 Executive Summary

### Objective
Integrate restaurant configuration features from AdminDashboard into CustomerApp to enable:
- Dynamic branding (logo, colors, theme)
- Business hours validation
- Payment methods configuration
- Delivery settings and fee calculation
- Regional settings (currency, tax, number formatting)
- Real-time restaurant status

### Scope
- **6 new stored procedures** for restaurant data
- **2 new domain entities** (`RestaurantInfo`, `BusinessHours`)
- **2 new repositories** with implementations
- **UI updates** across multiple screens
- **Theme system** integration for dynamic branding
- **NO database schema changes** - only new procedures

### Impact
- ✅ Dynamic app theming based on restaurant branding
- ✅ Real-time business hours validation
- ✅ Configurable payment methods
- ✅ Dynamic delivery fee calculation
- ✅ Multi-currency support
- ✅ Better UX with accurate restaurant information

---

## 🏗️ Current Architecture Analysis

### Project Structure
```
Napoli_CustomerApp_Mobile/
├── lib/
│   ├── main.dart
│   ├── l10n/                    # Internationalization
│   └── src/
│       ├── app.dart             # Root widget
│       ├── di.dart              # Dependency injection
│       ├── core/                # Shared modules
│       │   ├── core_domain/     # Shared entities
│       │   ├── core_ui/         # Shared UI (theme, widgets)
│       │   ├── di/              # Injectable DI
│       │   ├── error/           # Error handling
│       │   ├── network/         # Supabase + Dio
│       │   ├── router/          # GoRouter navigation
│       │   ├── services/        # Storage, Audio, Location
│       │   ├── usecases/        # Base UseCase
│       │   └── utils/           # Constants, Validators
│       └── features/            # Feature modules
│           ├── splash/          # Splash screen
│           ├── auth/            # Authentication
│           ├── home/            # Home screen (product listing)
│           ├── products/        # Product catalog
│           ├── detail/          # Product detail
│           ├── cart/            # Shopping cart
│           ├── coupons/         # Discount coupons
│           ├── orders/          # Order management
│           ├── profile/         # User profile
│           ├── settings/        # App settings
│           └── maps/            # Map integration
└── SQL/                         # Stored procedures (if any)
```

### Architecture Pattern
**Clean Architecture** with 4 layers:

1. **Domain Layer** (`domain/`)
   - Entities: Pure Dart classes
   - Repositories: Abstract interfaces
   - **UseCases**: Business logic (one per operation)

2. **Data Layer** (`data/`)
   - Models: JSON serializable with `fromJson`/`toJson`
   - Repositories: Concrete implementations
   - Datasources: Supabase RPC + Local storage

3. **Presentation Layer** (`presentation/`)
   - Cubits: State management (BLoC pattern)
   - Screens: UI pages
   - Widgets: Reusable components

4. **Core Layer** (`core/`)
   - Shared utilities, services, theme

### Current Data Flow
```
UI (Screen)
  ↓ calls
Cubit (State Management)
  ↓ calls
UseCase (Business Logic)
  ↓ calls
Repository (Abstract Interface)
  ↓ implements
RepositoryImpl
  ↓ calls
RemoteDataSource / LocalDataSource
  ↓ calls
Supabase RPC / SharedPreferences
  ↓ returns
JSON data / Local data
  ↓ converts
Model.fromJson() / Model.fromLocal()
  ↓ converts
Entity (Domain)
  ↓ returns
UseCase Result (Either<Failure, Entity>)
  ↓ emits
Cubit State
  ↓ updates
UI
```

### Key Technologies
- **State Management**: `flutter_bloc` (Cubit pattern)
- **Error Handling**: `fpdart` (Either monad)
- **Dependency Injection**: `get_it` + `injectable` (code generation)
- **Navigation**: `go_router` (declarative routing)
- **JSON Serialization**: `json_annotation` + `json_serializable`
- **Backend**: Supabase (PostgreSQL + RPC + Auth + Storage)
- **Local Storage**: `shared_preferences`
- **Internationalization**: `flutter_localizations` + `intl`

### Current Features
CustomerApp has these features:
- **Auth**: Login, Register, Profile management
- **Home**: Product listing with categories
- **Products**: Browse products by category
- **Detail**: Product details with addons/sizes
- **Cart**: Shopping cart management (local storage)
- **Coupons**: Apply discount coupons
- **Orders**: Create and track orders
- **Settings**: Order history, notifications, theme
- **Maps**: Delivery address selection

---

## 📦 Required Stored Procedures

### 1. `get_customer_restaurant_info`

**Purpose**: Get complete restaurant information for customer app (branding, contact, location)

**SQL Implementation**:
```sql
-- ========================================
-- STORED PROCEDURE: get_customer_restaurant_info
-- Returns restaurant info for customer app
-- ========================================

CREATE OR REPLACE FUNCTION get_customer_restaurant_info(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_customer_restaurant_info called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Get restaurant data
  SELECT json_build_object(
    'id', r.id,
    'name', r.name,
    'slug', r.slug,
    'description', r.description,
    
    -- Branding
    'logo_url', r.logo_url,
    'banner_url', r.banner_url,
    'primary_color', r.primary_color,
    'secondary_color', r.secondary_color,
    
    -- Contact
    'email', r.email,
    'phone', r.phone,
    'whatsapp', r.whatsapp,
    'website', r.website,
    
    -- Location
    'address', r.address,
    'city', r.city,
    'state', r.state,
    'country', r.country,
    'postal_code', r.postal_code,
    'latitude', r.latitude,
    'longitude', r.longitude,
    'timezone', r.timezone,
    
    -- Status
    'is_open', r.is_open
  ) INTO v_result
  FROM restaurants r
  WHERE r.id = p_restaurant_id;

  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Restaurant info retrieved';
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting restaurant info: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_customer_restaurant_info(UUID) IS 
  'Returns restaurant information for customer app (branding, contact, location)';
```

**Returns**:
```json
{
  "id": "uuid",
  "name": "Napoli Pizza",
  "slug": "napoli-pizza",
  "description": "La mejor pizza artesanal",
  "logo_url": "https://...",
  "banner_url": "https://...",
  "primary_color": "#E63946",
  "secondary_color": "#457B9D",
  "email": "contacto@napoli.com",
  "phone": "+52 123 456 7890",
  "whatsapp": "+52 987 654 3210",
  "website": "https://napoli.com",
  "address": "Av. Insurgentes Sur 123",
  "city": "Ciudad de México",
  "state": "CDMX",
  "country": "México",
  "postal_code": "03100",
  "latitude": 19.432608,
  "longitude": -99.133209,
  "timezone": "America/Mexico_City",
  "is_open": true
}
```

**Use Cases**:
- 🎨 **Theming**: Apply restaurant colors to app theme
- 🖼️ **Branding**: Show logo and banner
- 📞 **Contact**: Call/WhatsApp buttons
- 📍 **Location**: Show on map
- 🔴 **Status**: Display "Open/Closed" badge

---

### 2. `get_customer_business_hours`

**Purpose**: Get business hours and check if restaurant is currently open

**SQL Implementation**:
```sql
-- ========================================
-- STORED PROCEDURE: get_customer_business_hours
-- Returns business hours and current status
-- ========================================

CREATE OR REPLACE FUNCTION get_customer_business_hours(
  p_restaurant_id UUID,
  p_current_time TIMESTAMPTZ DEFAULT NOW()
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_business_hours JSONB;
  v_is_open BOOLEAN;
  v_current_day TEXT;
  v_current_time_only TIME;
  v_day_config JSONB;
  v_next_open_time TIMESTAMPTZ;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_customer_business_hours called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, time: %', p_restaurant_id, p_current_time;

  -- Get business hours
  SELECT business_hours, is_open
  INTO v_business_hours, v_is_open
  FROM restaurants
  WHERE id = p_restaurant_id;

  IF v_business_hours IS NULL THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  -- Get current day and time
  v_current_day := LOWER(TO_CHAR(p_current_time AT TIME ZONE 'America/Mexico_City', 'Day'));
  v_current_day := TRIM(v_current_day);
  v_current_time_only := (p_current_time AT TIME ZONE 'America/Mexico_City')::TIME;

  -- Get day configuration
  v_day_config := v_business_hours->v_current_day;

  -- Check if currently open
  IF v_is_open = FALSE THEN
    -- Restaurant manually closed
    v_is_open := FALSE;
  ELSIF v_day_config IS NULL OR (v_day_config->>'enabled')::BOOLEAN = FALSE THEN
    -- Day is disabled
    v_is_open := FALSE;
  ELSIF v_day_config->>'open' IS NULL OR v_day_config->>'close' IS NULL THEN
    -- No hours configured
    v_is_open := FALSE;
  ELSE
    -- Check if current time is within hours
    v_is_open := v_current_time_only BETWEEN 
      (v_day_config->>'open')::TIME AND 
      (v_day_config->>'close')::TIME;
  END IF;

  -- Build result
  v_result := json_build_object(
    'business_hours', v_business_hours,
    'is_open', v_is_open,
    'current_day', v_current_day,
    'current_time', TO_CHAR(v_current_time_only, 'HH24:MI'),
    'today_hours', v_day_config
  );

  RAISE NOTICE '✅ SUCCESS - Business hours retrieved, is_open: %', v_is_open;
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting business hours: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_customer_business_hours(UUID, TIMESTAMPTZ) IS 
  'Returns business hours and checks if restaurant is currently open';
```

**Returns**:
```json
{
  "business_hours": {
    "monday": {"enabled": true, "open": "12:00", "close": "22:00"},
    "tuesday": {"enabled": true, "open": "12:00", "close": "22:00"},
    ...
  },
  "is_open": true,
  "current_day": "monday",
  "current_time": "14:30",
  "today_hours": {"enabled": true, "open": "12:00", "close": "22:00"}
}
```

**Use Cases**:
- 🔴 **Status Badge**: Show "Open" or "Closed"
- 🚫 **Checkout Validation**: Block orders if closed
- ⏰ **Next Open Time**: Show "Opens tomorrow at 12:00"
- 📅 **Hours Display**: Show weekly schedule

---

### 3. `get_customer_payment_methods`

**Purpose**: Get available payment methods configured by admin

**SQL Implementation**:
```sql
-- ========================================
-- STORED PROCEDURE: get_customer_payment_methods
-- Returns available payment methods
-- ========================================

CREATE OR REPLACE FUNCTION get_customer_payment_methods(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_customer_payment_methods called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Get payment methods
  SELECT json_build_object(
    'accepts_cash', r.accepts_cash,
    'accepts_card', r.accepts_card,
    'accepts_transfer', r.accepts_transfer,
    'bank_name', r.bank_name,
    'bank_account_name', r.bank_account_name,
    'bank_account_clabe', r.bank_account_clabe
  ) INTO v_result
  FROM restaurants r
  WHERE r.id = p_restaurant_id;

  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Payment methods retrieved';
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting payment methods: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_customer_payment_methods(UUID) IS 
  'Returns available payment methods for customer checkout';
```

**Returns**:
```json
{
  "accepts_cash": true,
  "accepts_card": true,
  "accepts_transfer": true,
  "bank_name": "BBVA",
  "bank_account_name": "Napoli Pizza SA de CV",
  "bank_account_clabe": "012345678901234567"
}
```

**Use Cases**:
- 💳 **Checkout**: Show only enabled payment methods
- 🏦 **Transfer**: Display bank details
- 💰 **Cash**: Show "Cash on delivery" option

---

### 4. `get_customer_delivery_config`

**Purpose**: Get delivery configuration for fee calculation and validation

**SQL Implementation**:
```sql
-- ========================================
-- STORED PROCEDURE: get_customer_delivery_config
-- Returns delivery configuration
-- ========================================

CREATE OR REPLACE FUNCTION get_customer_delivery_config(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_customer_delivery_config called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Get delivery config
  SELECT json_build_object(
    'accepts_delivery', r.accepts_delivery,
    'accepts_pickup', r.accepts_pickup,
    'accepts_dine_in', r.accepts_dine_in,
    'delivery_radius_km', r.delivery_radius_km,
    'minimum_order_cents', r.minimum_order_cents,
    'delivery_fee_cents', r.delivery_fee_cents,
    'delivery_fee_per_km_cents', r.delivery_fee_per_km_cents,
    'free_delivery_threshold_cents', r.free_delivery_threshold_cents,
    'estimated_prep_minutes', r.estimated_prep_minutes,
    'estimated_delivery_minutes', r.estimated_delivery_minutes
  ) INTO v_result
  FROM restaurants r
  WHERE r.id = p_restaurant_id;

  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Delivery config retrieved';
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting delivery config: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_customer_delivery_config(UUID) IS 
  'Returns delivery configuration for customer app';
```

**Returns**:
```json
{
  "accepts_delivery": true,
  "accepts_pickup": true,
  "accepts_dine_in": false,
  "delivery_radius_km": 5.0,
  "minimum_order_cents": 10000,
  "delivery_fee_cents": 3000,
  "delivery_fee_per_km_cents": 1000,
  "free_delivery_threshold_cents": 50000,
  "estimated_prep_minutes": 30,
  "estimated_delivery_minutes": 30
}
```

**Use Cases**:
- 📏 **Address Validation**: Check if within delivery radius
- 💵 **Fee Calculation**: Calculate delivery cost
- 🎁 **Free Delivery**: Show "Free delivery on orders >$500"
- ⏱️ **ETA**: Show "Arrives in 45-60 min"
- 🚫 **Minimum Order**: Validate cart total

---

### 5. `get_customer_regional_settings`

**Purpose**: Get regional settings for price formatting and tax calculation

**SQL Implementation**:
```sql
-- ========================================
-- STORED PROCEDURE: get_customer_regional_settings
-- Returns regional settings (currency, tax, formatting)
-- ========================================

CREATE OR REPLACE FUNCTION get_customer_regional_settings(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_customer_regional_settings called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Get regional settings
  SELECT json_build_object(
    'currency_code', r.currency_code,
    'currency_symbol', r.currency_symbol,
    'currency_position', r.currency_position,
    'decimal_separator', r.decimal_separator,
    'thousands_separator', r.thousands_separator,
    'decimal_places', r.decimal_places,
    'tax_rate_percentage', r.tax_rate_percentage,
    'tax_included_in_prices', r.tax_included_in_prices
  ) INTO v_result
  FROM restaurants r
  WHERE r.id = p_restaurant_id;

  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Restaurant not found with id: %', p_restaurant_id;
  END IF;

  RAISE NOTICE '✅ SUCCESS - Regional settings retrieved';
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error getting regional settings: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION get_customer_regional_settings(UUID) IS 
  'Returns regional settings for price formatting and tax calculation';
```

**Returns**:
```json
{
  "currency_code": "MXN",
  "currency_symbol": "$",
  "currency_position": "before",
  "decimal_separator": ".",
  "thousands_separator": ",",
  "decimal_places": 2,
  "tax_rate_percentage": 16.0,
  "tax_included_in_prices": true
}
```

**Use Cases**:
- 💰 **Price Formatting**: Display "$1,350.00" or "1.350,00€"
- 🧾 **Tax Display**: Show/hide tax breakdown
- 🌍 **Multi-currency**: Support different currencies

---

### 6. `calculate_delivery_fee`

**Purpose**: Calculate delivery fee based on distance and restaurant settings

**SQL Implementation**:
```sql
-- ========================================
-- STORED PROCEDURE: calculate_delivery_fee
-- Calculates delivery fee based on distance
-- ========================================

CREATE OR REPLACE FUNCTION calculate_delivery_fee(
  p_restaurant_id UUID,
  p_distance_km DECIMAL,
  p_cart_total_cents INT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_delivery_fee_cents INT;
  v_delivery_fee_per_km_cents INT;
  v_free_delivery_threshold_cents INT;
  v_is_free BOOLEAN := FALSE;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - calculate_delivery_fee called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, distance: %, cart_total: %', 
    p_restaurant_id, p_distance_km, p_cart_total_cents;

  -- Get delivery settings
  SELECT 
    COALESCE(delivery_fee_cents, 0),
    COALESCE(delivery_fee_per_km_cents, 0),
    free_delivery_threshold_cents
  INTO 
    v_delivery_fee_cents,
    v_delivery_fee_per_km_cents,
    v_free_delivery_threshold_cents
  FROM restaurants
  WHERE id = p_restaurant_id;

  -- Check if qualifies for free delivery
  IF v_free_delivery_threshold_cents IS NOT NULL AND 
     p_cart_total_cents >= v_free_delivery_threshold_cents THEN
    v_is_free := TRUE;
    v_delivery_fee_cents := 0;
  ELSE
    -- Calculate fee: base + (per_km * distance)
    v_delivery_fee_cents := v_delivery_fee_cents + 
      FLOOR(v_delivery_fee_per_km_cents * p_distance_km);
  END IF;

  -- Build result
  v_result := json_build_object(
    'delivery_fee_cents', v_delivery_fee_cents,
    'is_free', v_is_free,
    'free_delivery_threshold_cents', v_free_delivery_threshold_cents,
    'distance_km', p_distance_km
  );

  RAISE NOTICE '✅ SUCCESS - Delivery fee calculated: %', v_delivery_fee_cents;
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error calculating delivery fee: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION calculate_delivery_fee(UUID, DECIMAL, INT) IS 
  'Calculates delivery fee based on distance and cart total';
```

**Returns**:
```json
{
  "delivery_fee_cents": 4500,
  "is_free": false,
  "free_delivery_threshold_cents": 50000,
  "distance_km": 1.5
}
```

**Use Cases**:
- 💵 **Cart Summary**: Show delivery cost
- 🎁 **Free Delivery Badge**: "Add $150 more for free delivery"
- 📊 **Order Total**: Include in final price

---

## 🎯 Dart Implementation Changes

Due to the extensive nature of the CustomerApp implementation, I'll provide the key files structure. The full implementation follows the same Clean Architecture pattern as CourierApp.

### Required New Files (30+ files)

**Domain Layer** (6 files):
1. `lib/src/features/restaurant/domain/entities/restaurant_info.dart`
2. `lib/src/features/restaurant/domain/entities/business_hours.dart`
3. `lib/src/features/restaurant/domain/entities/payment_methods.dart`
4. `lib/src/features/restaurant/domain/entities/delivery_config.dart`
5. `lib/src/features/restaurant/domain/entities/regional_settings.dart`
6. `lib/src/features/restaurant/domain/repositories/restaurant_repository.dart`

**Domain UseCases** (6 files):
7. `lib/src/features/restaurant/domain/usecases/get_restaurant_info_usecase.dart`
8. `lib/src/features/restaurant/domain/usecases/get_business_hours_usecase.dart`
9. `lib/src/features/restaurant/domain/usecases/get_payment_methods_usecase.dart`
10. `lib/src/features/restaurant/domain/usecases/get_delivery_config_usecase.dart`
11. `lib/src/features/restaurant/domain/usecases/get_regional_settings_usecase.dart`
12. `lib/src/features/restaurant/domain/usecases/calculate_delivery_fee_usecase.dart`

**Data Layer** (12 files):
13-17. Models for each entity (5 files)
18-22. Generated `.g.dart` files (5 files)
23. `lib/src/features/restaurant/data/datasources/restaurant_remote_datasource.dart`
24. `lib/src/features/restaurant/data/repositories/restaurant_repository_impl.dart`

**Presentation Layer** (8 files):
25. `lib/src/features/restaurant/presentation/cubit/restaurant_cubit.dart`
26. `lib/src/features/restaurant/presentation/cubit/restaurant_state.dart`
27-30. Widgets (4 files): `restaurant_header.dart`, `business_hours_widget.dart`, `payment_methods_selector.dart`, `delivery_fee_calculator.dart`

**SQL** (6 files):
31-36. SQL procedures

### Key Implementation: Dynamic Theme

**File**: `lib/src/core/core_ui/theme_provider.dart`

```dart
import 'package:flutter/material.dart';
import '../../features/restaurant/domain/entities/restaurant_info.dart';

class DynamicThemeProvider extends ChangeNotifier {
  RestaurantInfo? _restaurantInfo;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeData get lightTheme => _buildLightTheme();
  ThemeData get darkTheme => _buildDarkTheme();
  ThemeMode get themeMode => _themeMode;

  void setRestaurantInfo(RestaurantInfo info) {
    _restaurantInfo = info;
    notifyListeners();
  }

  ThemeData _buildLightTheme() {
    final primaryColor = _restaurantInfo?.primaryColor != null
        ? _parseColor(_restaurantInfo!.primaryColor!)
        : Colors.red;
    
    final secondaryColor = _restaurantInfo?.secondaryColor != null
        ? _parseColor(_restaurantInfo!.secondaryColor!)
        : Colors.blue;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.light,
      ),
      // ... rest of theme
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
  }
}
```

---

## 🗺️ Implementation Roadmap

### Phase 1: Backend (SQL) - 1.5 hours

**Tasks**:
1. ✅ Create all 6 stored procedures
2. ✅ Test each procedure individually
3. ✅ Verify JSON responses

### Phase 2: Domain Layer - 2 hours

**Tasks**:
1. ✅ Create 5 entities
2. ✅ Create repository interface
3. ✅ Create 6 UseCases
4. ✅ Add business logic to entities

### Phase 3: Data Layer - 2 hours

**Tasks**:
1. ✅ Create 5 models with JSON serialization
2. ✅ Run code generation
3. ✅ Create remote datasource
4. ✅ Implement repository

### Phase 4: Presentation Layer - 3 hours

**Tasks**:
1. ✅ Create Cubit + State
2. ✅ Create 4 widgets
3. ✅ Update existing screens
4. ✅ Integrate dynamic theme

### Phase 5: Integration - 2 hours

**Tasks**:
1. ✅ Update dependency injection
2. ✅ Update cart logic with delivery fee
3. ✅ Update checkout with payment methods
4. ✅ Update home with business hours

### Phase 6: Testing - 2 hours

**Tasks**:
1. ✅ Unit tests for entities
2. ✅ Unit tests for UseCases
3. ✅ Integration tests
4. ✅ Manual UI testing

**Total Estimated Time**: **12-14 hours**

---

## 🧪 Testing Strategy

### Critical Test Cases

**Business Hours**:
- [ ] App blocks checkout when restaurant is closed
- [ ] Shows "Closed" badge on home screen
- [ ] Displays correct opening hours
- [ ] Shows "Opens in X hours" message

**Payment Methods**:
- [ ] Only shows enabled payment methods
- [ ] Displays bank details for transfer
- [ ] Validates payment selection

**Delivery Fee**:
- [ ] Calculates fee correctly based on distance
- [ ] Shows "Free delivery" when applicable
- [ ] Validates minimum order amount
- [ ] Blocks checkout if outside delivery radius

**Dynamic Theme**:
- [ ] App theme updates with restaurant colors
- [ ] Logo displays correctly
- [ ] Banner shows on home screen

**Regional Settings**:
- [ ] Prices format correctly (currency symbol, decimals)
- [ ] Tax displays/hides based on settings
- [ ] Multi-currency support works

---

## 📊 Summary

### Total Changes Required

**SQL**: 6 stored procedures  
**Dart Files**: 30+ new files  
**Modified Files**: 10+ existing files  
**Estimated Effort**: 12-14 hours  

### Dependencies to Add
```yaml
# Already included in CustomerApp
flutter_bloc: ^8.1.6
fpdart: ^1.1.0
get_it: ^7.7.0
injectable: ^2.4.2
```

### Critical Success Factors
- ✅ Dynamic theme must update on app launch
- ✅ Business hours validation must be real-time
- ✅ Delivery fee calculation must be accurate
- ✅ Payment methods must filter correctly
- ✅ All prices must format per regional settings

---

**END OF DOCUMENT**

For detailed code examples, refer to the CourierApp integration guide which follows the same patterns.
