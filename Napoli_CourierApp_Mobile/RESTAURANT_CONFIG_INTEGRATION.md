# 🚗 Napoli CourierApp - Restaurant Configuration Integration Guide

**Version**: 1.0  
**Date**: 2025-12-30  
**Purpose**: Detailed implementation guide for integrating AdminDashboard restaurant configurations into CourierApp

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
Integrate restaurant configuration features from AdminDashboard into CourierApp to enable dynamic commission calculations, restaurant contact information, and delivery settings.

### Scope
- **2 new stored procedures** for restaurant data
- **1 new domain entity** (`RestaurantInfo`)
- **1 new repository** with implementation
- **UI updates** in Dashboard and Order Detail screens
- **NO database schema changes** - only new procedures

### Impact
- ✅ Dynamic commission calculations based on AdminDashboard settings
- ✅ Restaurant contact info (phone, address) for navigation
- ✅ Delivery radius validation
- ✅ Better UX with accurate restaurant information

---

## 🏗️ Current Architecture Analysis

### Project Structure
```
Napoli_CourierApp_Mobile/
├── lib/
│   ├── features/
│   │   ├── auth/           # Driver authentication
│   │   ├── dashboard/      # Main dashboard (online/offline toggle)
│   │   ├── history/        # Delivery history
│   │   ├── orders/         # Order management (accept, pickup, deliver)
│   │   └── profile/        # Driver profile settings
│   ├── core/
│   │   ├── config/         # App configuration
│   │   ├── di/             # Dependency injection
│   │   ├── navigation/     # Routing
│   │   ├── network/        # Supabase client
│   │   ├── services/       # Shared services
│   │   ├── theme/          # App theming
│   │   └── widgets/        # Shared widgets
│   └── main.dart
└── SQL/                    # Stored procedures
```

### Architecture Pattern
**Clean Architecture** with 3 layers:

1. **Domain Layer** (`domain/`)
   - Entities: Pure Dart classes (e.g., `Driver`, `Order`)
   - Repositories: Abstract interfaces
   - Use Cases: Business logic (not currently used, logic in Cubits)

2. **Data Layer** (`data/`)
   - Models: JSON serializable classes with `fromJson`/`toJson`
   - Repositories: Concrete implementations using datasources
   - Datasources: Direct Supabase RPC calls

3. **Presentation Layer** (`presentation/`)
   - Cubits: State management (BLoC pattern)
   - Pages: UI screens
   - Widgets: Reusable UI components

### Current Data Flow
```
UI (Page) 
  ↓ calls
Cubit (State Management)
  ↓ calls
Repository (Abstract Interface)
  ↓ implements
RepositoryImpl
  ↓ calls
RemoteDataSource
  ↓ calls
Supabase RPC (Stored Procedure)
  ↓ returns
JSON data
  ↓ converts
Model.fromJson()
  ↓ converts
Entity (Domain)
  ↓ emits
Cubit State
  ↓ updates
UI
```

### Key Technologies
- **State Management**: `flutter_bloc` (Cubit pattern)
- **Error Handling**: `fpdart` (Either monad)
- **JSON Serialization**: `json_annotation` + `json_serializable`
- **Backend**: Supabase (PostgreSQL + RPC)
- **Dependency Injection**: `get_it`

### Existing Stored Procedures
Current CourierApp uses these procedures:
- `get_driver_profile(p_driver_id)` - Driver info
- `update_driver_profile(...)` - Update driver
- `get_available_orders(p_restaurant_id)` - Orders ready for pickup
- `get_driver_orders(p_driver_id, p_status)` - Driver's orders
- `accept_order(p_order_id, p_driver_id)` - Accept order
- `pickup_order(p_order_id, p_driver_id)` - Confirm pickup
- `complete_order(p_order_id, p_driver_id)` - Mark delivered
- `toggle_driver_online(p_driver_id, p_is_online)` - Online status

---

## 📦 Required Stored Procedures

### 1. `get_courier_restaurant_info`

**Purpose**: Get restaurant information for courier navigation and commission calculation

**SQL Implementation**:
```sql
-- ========================================
-- STORED PROCEDURE: get_courier_restaurant_info
-- Returns restaurant info needed by courier app
-- ========================================

CREATE OR REPLACE FUNCTION get_courier_restaurant_info(
  p_restaurant_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_courier_restaurant_info called';
  RAISE NOTICE '📦 DATA - restaurant_id: %', p_restaurant_id;

  -- Get restaurant data
  SELECT json_build_object(
    'id', r.id,
    'name', r.name,
    'phone', r.phone,
    'whatsapp', r.whatsapp,
    'address', r.address,
    'city', r.city,
    'state', r.state,
    'latitude', r.latitude,
    'longitude', r.longitude,
    'driver_commission_type', r.driver_commission_type,
    'driver_commission_value', r.driver_commission_value,
    'delivery_radius_km', r.delivery_radius_km,
    'estimated_delivery_minutes', r.estimated_delivery_minutes
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

COMMENT ON FUNCTION get_courier_restaurant_info(UUID) IS 
  'Returns restaurant information for courier app (contact, location, commission)';
```

**Returns**:
```json
{
  "id": "uuid",
  "name": "Napoli Pizza",
  "phone": "+52 123 456 7890",
  "whatsapp": "+52 987 654 3210",
  "address": "Av. Insurgentes Sur 123",
  "city": "Ciudad de México",
  "state": "CDMX",
  "latitude": 19.432608,
  "longitude": -99.133209,
  "driver_commission_type": "percentage",
  "driver_commission_value": 15.0,
  "delivery_radius_km": 5.0,
  "estimated_delivery_minutes": 30
}
```

**Use Cases**:
- 📍 **Navigation**: Show restaurant location on map
- 📞 **Contact**: Call/WhatsApp restaurant
- 💰 **Commission**: Calculate driver earnings
- 📏 **Validation**: Check delivery radius

---

### 2. `calculate_driver_commission`

**Purpose**: Calculate driver commission for an order based on restaurant settings

**SQL Implementation**:
```sql
-- ========================================
-- STORED PROCEDURE: calculate_driver_commission
-- Calculates driver commission based on restaurant settings
-- ========================================

CREATE OR REPLACE FUNCTION calculate_driver_commission(
  p_restaurant_id UUID,
  p_order_total_cents INT,
  p_distance_km DECIMAL DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_commission_type VARCHAR(20);
  v_commission_value DECIMAL;
  v_commission_cents INT;
  v_result JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - calculate_driver_commission called';
  RAISE NOTICE '📦 DATA - restaurant_id: %, total: %, distance: %', 
    p_restaurant_id, p_order_total_cents, p_distance_km;

  -- Get commission settings
  SELECT 
    COALESCE(driver_commission_type, 'percentage'),
    COALESCE(driver_commission_value, 15.0)
  INTO v_commission_type, v_commission_value
  FROM restaurants
  WHERE id = p_restaurant_id;

  -- Calculate commission based on type
  CASE v_commission_type
    WHEN 'percentage' THEN
      -- Percentage of order total
      v_commission_cents := FLOOR(p_order_total_cents * v_commission_value / 100);
      
    WHEN 'fixed' THEN
      -- Fixed amount per delivery
      v_commission_cents := FLOOR(v_commission_value * 100);
      
    WHEN 'per_km' THEN
      -- Amount per kilometer
      IF p_distance_km IS NULL THEN
        RAISE EXCEPTION 'Distance required for per_km commission type';
      END IF;
      v_commission_cents := FLOOR(v_commission_value * p_distance_km * 100);
      
    ELSE
      -- Default to 15% if unknown type
      v_commission_cents := FLOOR(p_order_total_cents * 0.15);
  END CASE;

  -- Build result
  v_result := json_build_object(
    'commission_type', v_commission_type,
    'commission_value', v_commission_value,
    'commission_cents', v_commission_cents,
    'commission_formatted', TO_CHAR(v_commission_cents / 100.0, 'FM$999,999.00')
  );

  RAISE NOTICE '✅ SUCCESS - Commission calculated: %', v_commission_cents;
  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception: %', SQLERRM;
    RAISE EXCEPTION 'Error calculating commission: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION calculate_driver_commission(UUID, INT, DECIMAL) IS 
  'Calculates driver commission based on restaurant settings (percentage/fixed/per_km)';
```

**Returns**:
```json
{
  "commission_type": "percentage",
  "commission_value": 15.0,
  "commission_cents": 20250,
  "commission_formatted": "$202.50"
}
```

**Use Cases**:
- 💰 **Earnings Display**: Show driver how much they'll earn
- 📊 **Statistics**: Calculate total earnings
- 🧾 **Order Details**: Display commission on order card

---

## 🎯 Dart Implementation Changes

### Step 1: Create Domain Entity

**File**: `lib/features/restaurant/domain/entities/restaurant_info.dart`

```dart
/// Restaurant information entity for courier app
class RestaurantInfo {
  final String id;
  final String name;
  final String? phone;
  final String? whatsapp;
  final String? address;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final String? driverCommissionType; // 'percentage' | 'fixed' | 'per_km'
  final double? driverCommissionValue;
  final double? deliveryRadiusKm;
  final int? estimatedDeliveryMinutes;

  const RestaurantInfo({
    required this.id,
    required this.name,
    this.phone,
    this.whatsapp,
    this.address,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.driverCommissionType,
    this.driverCommissionValue,
    this.deliveryRadiusKm,
    this.estimatedDeliveryMinutes,
  });

  /// Calculate commission for an order
  int calculateCommissionCents(int orderTotalCents, {double? distanceKm}) {
    if (driverCommissionType == null || driverCommissionValue == null) {
      // Default: 15% of order total
      return (orderTotalCents * 0.15).floor();
    }

    switch (driverCommissionType) {
      case 'percentage':
        return (orderTotalCents * driverCommissionValue! / 100).floor();
      
      case 'fixed':
        return (driverCommissionValue! * 100).floor();
      
      case 'per_km':
        if (distanceKm == null) {
          throw ArgumentError('Distance required for per_km commission');
        }
        return (driverCommissionValue! * distanceKm * 100).floor();
      
      default:
        return (orderTotalCents * 0.15).floor();
    }
  }

  /// Format commission as currency
  String formatCommission(int commissionCents) {
    return '\$${(commissionCents / 100).toStringAsFixed(2)}';
  }

  /// Check if delivery address is within radius
  bool isWithinDeliveryRadius(double lat, double lng) {
    if (latitude == null || longitude == null || deliveryRadiusKm == null) {
      return true; // No restriction if not configured
    }

    final distance = _calculateDistance(latitude!, longitude!, lat, lng);
    return distance <= deliveryRadiusKm!;
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}
```

---

### Step 2: Create Data Model

**File**: `lib/features/restaurant/data/models/restaurant_info_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/restaurant_info.dart';

part 'restaurant_info_model.g.dart';

@JsonSerializable()
class RestaurantInfoModel {
  final String id;
  final String name;
  final String? phone;
  final String? whatsapp;
  final String? address;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'driver_commission_type')
  final String? driverCommissionType;
  @JsonKey(name: 'driver_commission_value')
  final double? driverCommissionValue;
  @JsonKey(name: 'delivery_radius_km')
  final double? deliveryRadiusKm;
  @JsonKey(name: 'estimated_delivery_minutes')
  final int? estimatedDeliveryMinutes;

  const RestaurantInfoModel({
    required this.id,
    required this.name,
    this.phone,
    this.whatsapp,
    this.address,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.driverCommissionType,
    this.driverCommissionValue,
    this.deliveryRadiusKm,
    this.estimatedDeliveryMinutes,
  });

  /// Convert model to domain entity
  RestaurantInfo toEntity() {
    return RestaurantInfo(
      id: id,
      name: name,
      phone: phone,
      whatsapp: whatsapp,
      address: address,
      city: city,
      state: state,
      latitude: latitude,
      longitude: longitude,
      driverCommissionType: driverCommissionType,
      driverCommissionValue: driverCommissionValue,
      deliveryRadiusKm: deliveryRadiusKm,
      estimatedDeliveryMinutes: estimatedDeliveryMinutes,
    );
  }

  factory RestaurantInfoModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantInfoModelToJson(this);
}
```

**Generate code**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Step 3: Create Repository Interface

**File**: `lib/features/restaurant/domain/repositories/restaurant_repository.dart`

```dart
import 'package:fpdart/fpdart.dart';
import '../entities/restaurant_info.dart';

/// Restaurant repository interface
abstract class RestaurantRepository {
  /// Get restaurant information
  Future<Either<String, RestaurantInfo>> getRestaurantInfo(String restaurantId);
  
  /// Calculate driver commission for an order
  Future<Either<String, int>> calculateCommission({
    required String restaurantId,
    required int orderTotalCents,
    double? distanceKm,
  });
}
```

---

### Step 4: Create DataSource

**File**: `lib/features/restaurant/data/datasources/restaurant_remote_datasource.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_info_model.dart';

/// Remote datasource for restaurant data
class RestaurantRemoteDataSource {
  final SupabaseClient supabase;

  const RestaurantRemoteDataSource(this.supabase);

  /// Get restaurant information via RPC
  Future<RestaurantInfoModel> getRestaurantInfo(String restaurantId) async {
    try {
      final response = await supabase.rpc(
        'get_courier_restaurant_info',
        params: {'p_restaurant_id': restaurantId},
      );

      if (response == null) {
        throw Exception('No data returned from get_courier_restaurant_info');
      }

      return RestaurantInfoModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get restaurant info: $e');
    }
  }

  /// Calculate commission via RPC
  Future<int> calculateCommission({
    required String restaurantId,
    required int orderTotalCents,
    double? distanceKm,
  }) async {
    try {
      final response = await supabase.rpc(
        'calculate_driver_commission',
        params: {
          'p_restaurant_id': restaurantId,
          'p_order_total_cents': orderTotalCents,
          if (distanceKm != null) 'p_distance_km': distanceKm,
        },
      );

      if (response == null) {
        throw Exception('No data returned from calculate_driver_commission');
      }

      final data = response as Map<String, dynamic>;
      return data['commission_cents'] as int;
    } catch (e) {
      throw Exception('Failed to calculate commission: $e');
    }
  }
}
```

---

### Step 5: Implement Repository

**File**: `lib/features/restaurant/data/repositories/restaurant_repository_impl.dart`

```dart
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/restaurant_info.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_datasource.dart';

/// Implementation of restaurant repository
class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource dataSource;

  const RestaurantRepositoryImpl(this.dataSource);

  @override
  Future<Either<String, RestaurantInfo>> getRestaurantInfo(
    String restaurantId,
  ) async {
    try {
      final model = await dataSource.getRestaurantInfo(restaurantId);
      return right(model.toEntity());
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, int>> calculateCommission({
    required String restaurantId,
    required int orderTotalCents,
    double? distanceKm,
  }) async {
    try {
      final commission = await dataSource.calculateCommission(
        restaurantId: restaurantId,
        orderTotalCents: orderTotalCents,
        distanceKm: distanceKm,
      );
      return right(commission);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
```

---

### Step 6: Update Dependency Injection

**File**: `lib/core/di/injection.dart`

```dart
// Add to existing injection setup

// Restaurant
final restaurantDataSource = RestaurantRemoteDataSource(supabase);
final restaurantRepository = RestaurantRepositoryImpl(restaurantDataSource);

// Register in GetIt
getIt.registerLazySingleton<RestaurantRepository>(
  () => restaurantRepository,
);
```

---

### Step 7: Update Order Entity

**File**: `lib/features/orders/domain/entities/order.dart`

Add commission fields:

```dart
class Order {
  // ... existing fields ...
  
  final int? driverCommissionCents; // NEW
  final String? driverCommissionFormatted; // NEW
  
  // ... rest of class ...
}
```

---

### Step 8: Update Order Detail UI

**File**: `lib/features/orders/presentation/pages/order_detail_screen.dart`

Add commission display:

```dart
// Add in order details section
if (order.driverCommissionCents != null)
  _DetailRow(
    label: 'Tu Ganancia',
    value: order.driverCommissionFormatted ?? 
           '\$${(order.driverCommissionCents! / 100).toStringAsFixed(2)}',
    valueColor: Colors.green,
    valueWeight: FontWeight.bold,
  ),
```

---

### Step 9: Add Restaurant Info to Dashboard

**File**: `lib/features/dashboard/presentation/widgets/restaurant_info_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../restaurant/domain/entities/restaurant_info.dart';

class RestaurantInfoCard extends StatelessWidget {
  final RestaurantInfo restaurant;

  const RestaurantInfoCard({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (restaurant.address != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${restaurant.address}, ${restaurant.city}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                if (restaurant.phone != null)
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () => _launchPhone(restaurant.phone!),
                    tooltip: 'Llamar',
                  ),
                if (restaurant.whatsapp != null)
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () => _launchWhatsApp(restaurant.whatsapp!),
                    tooltip: 'WhatsApp',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
```

---

## 🗺️ Implementation Roadmap

### Phase 1: Backend (SQL) - 1 hour

**Tasks**:
1. ✅ Create `get_courier_restaurant_info` stored procedure
2. ✅ Create `calculate_driver_commission` stored procedure
3. ✅ Test procedures in Supabase SQL Editor
4. ✅ Verify JSON responses

**Testing**:
```sql
-- Test get_courier_restaurant_info
SELECT get_courier_restaurant_info('YOUR_RESTAURANT_ID');

-- Test calculate_driver_commission
SELECT calculate_driver_commission(
  'YOUR_RESTAURANT_ID'::UUID,
  135000, -- $1,350.00
  1.5     -- 1.5 km
);
```

---

### Phase 2: Domain Layer - 30 minutes

**Tasks**:
1. ✅ Create `RestaurantInfo` entity
2. ✅ Create `RestaurantRepository` interface
3. ✅ Add commission calculation logic to entity

**Files Created**:
- `lib/features/restaurant/domain/entities/restaurant_info.dart`
- `lib/features/restaurant/domain/repositories/restaurant_repository.dart`

---

### Phase 3: Data Layer - 1 hour

**Tasks**:
1. ✅ Create `RestaurantInfoModel` with JSON serialization
2. ✅ Run code generation (`build_runner`)
3. ✅ Create `RestaurantRemoteDataSource`
4. ✅ Implement `RestaurantRepositoryImpl`

**Files Created**:
- `lib/features/restaurant/data/models/restaurant_info_model.dart`
- `lib/features/restaurant/data/models/restaurant_info_model.g.dart` (generated)
- `lib/features/restaurant/data/datasources/restaurant_remote_datasource.dart`
- `lib/features/restaurant/data/repositories/restaurant_repository_impl.dart`

**Commands**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Phase 4: Integration - 1 hour

**Tasks**:
1. ✅ Update dependency injection
2. ✅ Update `Order` entity with commission fields
3. ✅ Update `OrderModel` to parse commission
4. ✅ Test repository integration

**Files Modified**:
- `lib/core/di/injection.dart`
- `lib/features/orders/domain/entities/order.dart`
- `lib/features/orders/data/models/order_model.dart`

---

### Phase 5: UI Updates - 1.5 hours

**Tasks**:
1. ✅ Create `RestaurantInfoCard` widget
2. ✅ Add to Dashboard screen
3. ✅ Update Order Detail screen with commission
4. ✅ Add call/WhatsApp buttons

**Files Created**:
- `lib/features/dashboard/presentation/widgets/restaurant_info_card.dart`

**Files Modified**:
- `lib/features/dashboard/presentation/pages/dashboard_screen.dart`
- `lib/features/orders/presentation/pages/order_detail_screen.dart`

---

### Phase 6: Testing - 1 hour

**Tasks**:
1. ✅ Unit tests for `RestaurantInfo` entity
2. ✅ Integration tests for repository
3. ✅ Manual UI testing
4. ✅ End-to-end flow testing

**Test Cases**:
- ✅ Get restaurant info successfully
- ✅ Calculate commission (percentage)
- ✅ Calculate commission (fixed)
- ✅ Calculate commission (per_km)
- ✅ Handle missing restaurant
- ✅ Display commission in order details
- ✅ Call/WhatsApp buttons work

---

## 🧪 Testing Strategy

### Unit Tests

**File**: `test/features/restaurant/domain/entities/restaurant_info_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:napoli_courier_app/features/restaurant/domain/entities/restaurant_info.dart';

void main() {
  group('RestaurantInfo', () {
    test('calculateCommissionCents - percentage type', () {
      final restaurant = RestaurantInfo(
        id: '1',
        name: 'Test',
        driverCommissionType: 'percentage',
        driverCommissionValue: 15.0,
      );

      final commission = restaurant.calculateCommissionCents(100000);
      expect(commission, 15000); // 15% of 100000
    });

    test('calculateCommissionCents - fixed type', () {
      final restaurant = RestaurantInfo(
        id: '1',
        name: 'Test',
        driverCommissionType: 'fixed',
        driverCommissionValue: 50.0,
      );

      final commission = restaurant.calculateCommissionCents(100000);
      expect(commission, 5000); // $50.00 fixed
    });

    test('calculateCommissionCents - per_km type', () {
      final restaurant = RestaurantInfo(
        id: '1',
        name: 'Test',
        driverCommissionType: 'per_km',
        driverCommissionValue: 10.0,
      );

      final commission = restaurant.calculateCommissionCents(
        100000,
        distanceKm: 2.5,
      );
      expect(commission, 2500); // $10 * 2.5 km
    });

    test('isWithinDeliveryRadius - within radius', () {
      final restaurant = RestaurantInfo(
        id: '1',
        name: 'Test',
        latitude: 19.432608,
        longitude: -99.133209,
        deliveryRadiusKm: 5.0,
      );

      // Point ~1km away
      final isWithin = restaurant.isWithinDeliveryRadius(
        19.442608,
        -99.133209,
      );
      expect(isWithin, true);
    });
  });
}
```

### Integration Tests

**File**: `test/features/restaurant/data/repositories/restaurant_repository_impl_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ... imports ...

void main() {
  late RestaurantRemoteDataSource mockDataSource;
  late RestaurantRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockRestaurantRemoteDataSource();
    repository = RestaurantRepositoryImpl(mockDataSource);
  });

  group('getRestaurantInfo', () {
    test('should return RestaurantInfo on success', () async {
      // Arrange
      final model = RestaurantInfoModel(
        id: '1',
        name: 'Test Restaurant',
        phone: '+123456789',
      );
      when(() => mockDataSource.getRestaurantInfo(any()))
          .thenAnswer((_) async => model);

      // Act
      final result = await repository.getRestaurantInfo('1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Should not return error'),
        (info) {
          expect(info.id, '1');
          expect(info.name, 'Test Restaurant');
        },
      );
    });

    test('should return error on failure', () async {
      // Arrange
      when(() => mockDataSource.getRestaurantInfo(any()))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getRestaurantInfo('1');

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

### Manual Testing Checklist

- [ ] **Dashboard**: Restaurant info card displays correctly
- [ ] **Dashboard**: Call button opens phone dialer
- [ ] **Dashboard**: WhatsApp button opens WhatsApp
- [ ] **Orders**: Commission shows on order cards
- [ ] **Orders**: Commission calculated correctly (percentage)
- [ ] **Orders**: Commission calculated correctly (fixed)
- [ ] **Orders**: Commission calculated correctly (per_km)
- [ ] **Profile**: No changes needed (verify no regressions)

---

## 📊 Summary

### Files to Create (11 new files)

**Domain Layer** (2 files):
1. `lib/features/restaurant/domain/entities/restaurant_info.dart`
2. `lib/features/restaurant/domain/repositories/restaurant_repository.dart`

**Data Layer** (4 files):
3. `lib/features/restaurant/data/models/restaurant_info_model.dart`
4. `lib/features/restaurant/data/models/restaurant_info_model.g.dart` (generated)
5. `lib/features/restaurant/data/datasources/restaurant_remote_datasource.dart`
6. `lib/features/restaurant/data/repositories/restaurant_repository_impl.dart`

**Presentation Layer** (1 file):
7. `lib/features/dashboard/presentation/widgets/restaurant_info_card.dart`

**SQL** (2 files):
8. `SQL/get_courier_restaurant_info.sql`
9. `SQL/calculate_driver_commission.sql`

**Tests** (2 files):
10. `test/features/restaurant/domain/entities/restaurant_info_test.dart`
11. `test/features/restaurant/data/repositories/restaurant_repository_impl_test.dart`

### Files to Modify (5 files)

1. `lib/core/di/injection.dart` - Add restaurant repository
2. `lib/features/orders/domain/entities/order.dart` - Add commission fields
3. `lib/features/orders/data/models/order_model.dart` - Parse commission
4. `lib/features/dashboard/presentation/pages/dashboard_screen.dart` - Add restaurant card
5. `lib/features/orders/presentation/pages/order_detail_screen.dart` - Show commission

### Total Effort Estimate

- **SQL Development**: 1 hour
- **Domain Layer**: 30 minutes
- **Data Layer**: 1 hour
- **Integration**: 1 hour
- **UI Updates**: 1.5 hours
- **Testing**: 1 hour
- **TOTAL**: **~6 hours**

### Dependencies to Add

Add to `pubspec.yaml`:
```yaml
dependencies:
  url_launcher: ^6.2.0  # For call/WhatsApp buttons
```

Run:
```bash
flutter pub get
```

---

## ✅ Acceptance Criteria

### Functional Requirements
- ✅ Driver can see restaurant name, address, phone
- ✅ Driver can call restaurant with one tap
- ✅ Driver can WhatsApp restaurant with one tap
- ✅ Driver sees their commission on each order
- ✅ Commission calculated based on AdminDashboard settings
- ✅ Commission supports 3 types: percentage, fixed, per_km

### Non-Functional Requirements
- ✅ No database schema changes
- ✅ Follows Clean Architecture pattern
- ✅ Uses existing Supabase RPC pattern
- ✅ Maintains error handling with Either monad
- ✅ All new code has unit tests
- ✅ UI follows existing design system

### Performance
- ✅ Restaurant info cached (loaded once per session)
- ✅ Commission calculated instantly (no API call needed if using entity method)
- ✅ No impact on existing order loading performance

---

## 🚀 Deployment

### Step 1: Execute SQL
1. Open Supabase Dashboard → SQL Editor
2. Execute `SQL/get_courier_restaurant_info.sql`
3. Execute `SQL/calculate_driver_commission.sql`
4. Verify: "Success. No rows returned"

### Step 2: Test SQL
```sql
-- Test with your restaurant ID
SELECT get_courier_restaurant_info('YOUR_RESTAURANT_ID');
SELECT calculate_driver_commission('YOUR_RESTAURANT_ID'::UUID, 100000, 1.5);
```

### Step 3: Deploy Flutter Code
```bash
# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build and deploy
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Step 4: Verify in Production
1. Login as driver
2. Check dashboard shows restaurant info
3. Accept an order
4. Verify commission displays correctly
5. Test call/WhatsApp buttons

---

## 📞 Support

For questions or issues during implementation:
- Check existing CourierApp patterns in `lib/features/orders`
- Review Supabase RPC examples in `SQL/` directory
- Follow Clean Architecture principles
- Use Either monad for error handling

---

**END OF DOCUMENT**
