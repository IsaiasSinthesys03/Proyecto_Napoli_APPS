import 'package:injectable/injectable.dart';
import 'package:napoli_app_v1/src/core/network/supabase_config.dart';
import 'package:napoli_app_v1/src/core/network/supabase_logger.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/features/auth/data/models/user_model.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/payment_method.dart';

/// Remote data source for authentication using Supabase
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<UserModel> updateProfile(UserModel user);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

/// Supabase implementation of AuthRemoteDataSource
@LazySingleton(as: AuthRemoteDataSource)
class SupabaseAuthDataSource implements AuthRemoteDataSource {
  final RestaurantConfigService _configService;

  SupabaseAuthDataSource(this._configService);

  @override
  Future<UserModel> login(String email, String password) async {
    print('🔍 DEBUG - Starting login for email: $email');

    final client = SupabaseConfig.client;

    try {
      // Step 1: Authenticate with Supabase Auth
      print('🔍 DEBUG - Calling Supabase Auth signInWithPassword');
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        print('❌ ERROR - Auth returned null user');
        throw Exception('Error de autenticación');
      }

      print('✅ SUCCESS - Auth successful for user: ${authResponse.user!.id}');

      // Step 2: Call stored procedure to get customer profile
      print('🔍 DEBUG - Calling login_customer stored procedure');
      print('📦 DATA - restaurant_id: ${_configService.restaurantId}');

      final response = await client.rpc(
        'login_customer',
        params: {
          'p_email': email,
          'p_restaurant_id': _configService.restaurantId,
        },
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response type: ${response.runtimeType}');

      if (response == null) {
        print(
          '❌ ERROR - Customer not found in database, creating new customer',
        );
        // Create customer if doesn't exist
        return _createCustomerFromAuth(
          authResponse.user!.id,
          email,
          email.split('@')[0],
        );
      }

      print('📦 DATA - Parsing customer profile from response');

      // Parse the JSON response
      final customerData = response as Map<String, dynamic>;

      // Parse addresses
      final addressesJson = customerData['addresses'] as List? ?? [];
      final addresses = addressesJson
          .map(
            (addr) => AddressModel(
              id: addr['id'],
              label: addr['label'] ?? '',
              address: addr['street_address'] ?? '',
              city: addr['city'] ?? '',
              details: addr['address_details'],
              isDefault: addr['is_default'] ?? false,
              latitude: addr['latitude']?.toDouble(),
              longitude: addr['longitude']?.toDouble(),
            ),
          )
          .toList();

      print('📦 DATA - Parsed ${addresses.length} addresses');

      // Parse payment methods
      final paymentMethodsJson = customerData['payment_methods'] as List? ?? [];
      final paymentMethods = paymentMethodsJson
          .map(
            (pm) => PaymentMethodModel(
              id: pm['id'],
              type: _parsePaymentType(pm['type']),
              cardNumber: pm['card_last_four'] != null
                  ? '**** **** **** ${pm['card_last_four']}'
                  : null,
              cardHolder: pm['card_holder_name'],
              cardBrand: pm['card_brand'],
              isDefault: pm['is_default'] ?? false,
            ),
          )
          .toList();

      print('📦 DATA - Parsed ${paymentMethods.length} payment methods');

      final user = UserModel(
        id: customerData['id'],
        name: customerData['name'] ?? '',
        email: customerData['email'] ?? '',
        phone: customerData['phone'],
        photoUrl: customerData['photo_url'],
        savedAddresses: addresses,
        savedCards: paymentMethods,
        loyaltyPoints: customerData['loyalty_points'] ?? 0,
        loyaltyTier: customerData['loyalty_tier'],
      );

      print('✅ SUCCESS - User profile parsed successfully');
      print('📦 DATA - User: ${user.name} (${user.email})');

      return user;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in login: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      SupabaseLogger.logError('login_customer', 'RPC', e);
      rethrow;
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    print('🔍 DEBUG - Starting registration for email: $email, name: $name');

    final client = SupabaseConfig.client;

    try {
      // Step 1: Register with Supabase Auth
      print('🔍 DEBUG - Calling Supabase Auth signUp');
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        print('❌ ERROR - Auth signUp returned null user');
        throw Exception('Error al registrar usuario - auth returned null');
      }

      print(
        '✅ SUCCESS - Auth registration successful for user: ${authResponse.user!.id}',
      );

      // Step 2: Call stored procedure to create customer profile
      print('🔍 DEBUG - Calling register_customer stored procedure');
      print('📦 DATA - restaurant_id: ${_configService.restaurantId}');

      final response = await client.rpc(
        'register_customer',
        params: {
          'p_email': email,
          'p_name': name,
          'p_restaurant_id': _configService.restaurantId,
        },
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response type: ${response.runtimeType}');

      if (response == null) {
        print('❌ ERROR - Stored procedure returned null');
        throw Exception('Error al crear perfil de cliente');
      }

      print('📦 DATA - Parsing customer profile from response');

      // Parse the JSON response
      final customerData = response as Map<String, dynamic>;

      final user = UserModel(
        id: customerData['id'],
        name: customerData['name'] ?? '',
        email: customerData['email'] ?? '',
        phone: customerData['phone'],
        photoUrl: customerData['photo_url'],
        savedAddresses: const [],
        savedCards: const [],
        loyaltyPoints: customerData['loyalty_points'] ?? 0,
        loyaltyTier: customerData['loyalty_tier'],
      );

      print('✅ SUCCESS - User profile created successfully');
      print('📦 DATA - User: ${user.name} (${user.email})');

      return user;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in register: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      SupabaseLogger.logError('register_customer', 'RPC', e);
      rethrow;
    }
  }

  Future<UserModel> _createCustomerFromAuth(
    String authId,
    String email,
    String name,
  ) async {
    final client = SupabaseConfig.client;

    final insertData = {
      'restaurant_id': _configService.restaurantId,
      'name': name,
      'email': email,
      'status': 'active',
    };

    try {
      final customerData = await client
          .from('customers')
          .insert(insertData)
          .select()
          .single();

      return UserModel(
        id: customerData['id'],
        name: customerData['name'],
        email: customerData['email'],
        savedAddresses: const [],
        savedCards: const [],
        loyaltyPoints: 0,
      );
    } catch (e) {
      SupabaseLogger.logError('customers', 'INSERT', e);
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    print('🔍 DEBUG - Starting updateProfile for user: ${user.id}');

    final client = SupabaseConfig.client;

    try {
      // Call stored procedure to update profile
      print('🔍 DEBUG - Calling update_customer_profile stored procedure');
      print('📦 DATA - name: ${user.name}, phone: ${user.phone}');

      final response = await client.rpc(
        'update_customer_profile',
        params: {
          'p_customer_id': user.id,
          'p_name': user.name,
          'p_phone': user.phone,
        },
      );

      print('✅ SUCCESS - Profile updated via stored procedure');
      print('📦 DATA - Response: $response');

      // Sync Addresses (using stored procedures)
      await _syncAddresses(user.id, user.savedAddresses);

      // Sync Payment Methods (using stored procedures)
      await _syncPaymentMethods(user.id, user.savedCards);

      print('✅ SUCCESS - Profile update complete');
      return user;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in updateProfile: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final client = SupabaseConfig.client;
    final authUser = client.auth.currentUser;

    if (authUser == null) return null;

    final customerData = await client
        .from('customers')
        .select()
        .eq('email', authUser.email!)
        .eq('restaurant_id', _configService.restaurantId)
        .limit(1)
        .maybeSingle();

    if (customerData == null) return null;

    final addresses = await _fetchAddresses(customerData['id']);
    final paymentMethods = await _fetchPaymentMethods(customerData['id']);

    return UserModel(
      id: customerData['id'],
      name: customerData['name'] ?? '',
      email: customerData['email'] ?? '',
      phone: customerData['phone'],
      photoUrl: customerData['photo_url'],
      savedAddresses: addresses,
      savedCards: paymentMethods,
      loyaltyPoints: customerData['loyalty_points'] ?? 0,
      loyaltyTier: customerData['loyalty_tier'],
    );
  }

  @override
  Future<void> logout() async {
    await SupabaseConfig.client.auth.signOut();
  }

  Future<List<AddressModel>> _fetchAddresses(String customerId) async {
    final client = SupabaseConfig.client;

    final data = await client
        .from('customer_addresses')
        .select()
        .eq('customer_id', customerId)
        .order('is_default', ascending: false);

    return (data as List)
        .map(
          (addr) => AddressModel(
            id: addr['id'],
            label: addr['label'] ?? '',
            address: addr['street_address'] ?? '',
            city: addr['city'] ?? '',
            details: addr['address_details'],
            isDefault: addr['is_default'] ?? false,
          ),
        )
        .toList();
  }

  Future<List<PaymentMethodModel>> _fetchPaymentMethods(
    String customerId,
  ) async {
    final client = SupabaseConfig.client;

    final data = await client
        .from('customer_payment_methods')
        .select()
        .eq('customer_id', customerId)
        .order('is_default', ascending: false);

    return (data as List)
        .map(
          (pm) => PaymentMethodModel(
            id: pm['id'],
            type: _parsePaymentType(pm['type']),
            cardNumber: pm['card_last_four'] != null
                ? '**** **** **** ${pm['card_last_four']}'
                : null,
            cardHolder: pm['card_holder_name'],
            cardBrand: pm['card_brand'],
            isDefault: pm['is_default'] ?? false,
          ),
        )
        .toList();
  }

  Future<void> _syncAddresses(
    String customerId,
    List<AddressModel> addresses,
  ) async {
    final client = SupabaseConfig.client;

    // 1. Get existing IDs to identify deletions
    final existingData = await client
        .from('customer_addresses')
        .select('id')
        .eq('customer_id', customerId);

    final existingIds = (existingData as List)
        .map((e) => e['id'] as String)
        .toSet();

    final currentIds = addresses.map((e) => e.id).toSet();

    // 2. Delete removed addresses
    final idsToDelete = existingIds.difference(currentIds).toList();
    if (idsToDelete.isNotEmpty) {
      await client
          .from('customer_addresses')
          .delete()
          .eq('customer_id', customerId)
          .filter('id', 'in', idsToDelete);
    }

    // 3. Upsert current addresses
    for (final addr in addresses) {
      // If ID starts with 'temp-' or similar local ID, let DB generate one?
      // Or strict UUID? Assuming generated UUIDs or relying on DB default for new inserts if we omit ID?
      // Usually mobile app generates UUID for offline capability.
      // If ID is empty or local-prefix, we might need to handle it.
      // But let's assume valid UUIDs or we just upsert.

      // If it's a new address created locally with a temporary ID (e.g. DateTime),
      // Supabase won't accept it if column is UUID.
      // Better: if it doesn't look like a UUID, we insert without ID to let DB generate,
      // OR we just assume the app assigns UUIDs.
      // Let's rely on upsert with map.

      final data = {
        'customer_id': customerId,
        'restaurant_id':
            _configService.restaurantId, // ✅ FIXED: Added restaurant_id
        'label': addr.label,
        'street_address': addr.address,
        'city': addr.city,
        'address_details': addr.details,
        'is_default': addr.isDefault,
      };

      if (addr.id.isNotEmpty && !addr.id.startsWith('manual-')) {
        // Is UUID or valid ID
        await client.from('customer_addresses').upsert({
          'id': addr.id,
          ...data,
        });
      } else {
        // New insert
        await client.from('customer_addresses').insert(data);
      }
    }
  }

  Future<void> _syncPaymentMethods(
    String customerId,
    List<PaymentMethodModel> methods,
  ) async {
    final client = SupabaseConfig.client;

    // 1. Get existing IDs
    final existingData = await client
        .from('customer_payment_methods')
        .select('id')
        .eq('customer_id', customerId);

    final existingIds = (existingData as List)
        .map((e) => e['id'] as String)
        .toSet();

    final currentIds = methods.map((e) => e.id).toSet();

    // 2. Delete removed
    final idsToDelete = existingIds.difference(currentIds).toList();
    if (idsToDelete.isNotEmpty) {
      await client
          .from('customer_payment_methods')
          .delete()
          .eq('customer_id', customerId)
          .filter('id', 'in', idsToDelete);
    }

    // 3. Upsert
    for (final method in methods) {
      final data = {
        'customer_id': customerId,
        'restaurant_id':
            _configService.restaurantId, // ✅ FIXED: Added restaurant_id
        'type': method.type.name,
        'card_holder_name': method.cardHolder,
        'card_brand': method.cardBrand,
        'card_last_four': method.cardNumber?.split(' ').last,
        'is_default': method.isDefault,
      };

      if (method.id.isNotEmpty) {
        await client.from('customer_payment_methods').upsert({
          'id': method.id,
          ...data,
        });
      } else {
        await client.from('customer_payment_methods').insert(data);
      }
    }
  }

  PaymentType _parsePaymentType(String? type) {
    // ... existing implementation
    switch (type) {
      case 'card':
        return PaymentType.card;
      case 'cash':
        return PaymentType.cash;
      case 'transfer':
        return PaymentType.transfer;
      default:
        return PaymentType.other;
    }
  }
}
