# 📱 **ANÁLISIS COMPLETO: Napoli_CustomerApp_Mobile**

## 🏗️ **ARQUITECTURA GENERAL**

### **Stack Tecnológico**
- **Framework**: Flutter 3.9.2+ (Dart)
- **State Management**: BLoC (flutter_bloc 8.1.6) + Cubit pattern
- **Dependency Injection**: GetIt 7.7.0 + Injectable 2.4.2 (code generation)
- **Navigation**: GoRouter 14.2.0 (declarative routing)
- **Backend**: Supabase Flutter 2.9.0 (PostgreSQL + Auth + Storage + Realtime)
- **HTTP Client**: Dio 5.9.0
- **Data Persistence**: SharedPreferences 2.2.2
- **Functional Programming**: fpdart 1.1.0 (Either type for error handling)
- **Equality**: Equatable 2.0.5 (value comparison)
- **Animations**: Lottie 3.1.0
- **Audio**: audioplayers 6.5.1
- **UUID Generation**: uuid 4.5.2
- **Internationalization**: intl 0.20.2 + flutter_localizations
- **Code Generation**: build_runner, json_serializable, injectable_generator

---

## 📁 **ESTRUCTURA DE CARPETAS (Feature-First Architecture)**

```
lib/
├── main.dart                    # Entry point con error handling global
├── l10n/                        # Localization (es/en)
│   └── arb/
│       ├── app_es.arb          # Spanish translations
│       └── app_en.arb          # English translations
│
└── src/
    ├── app.dart                 # Root widget con providers y theme
    ├── di.dart                  # DI initialization
    │
    ├── core/                    # Shared modules
    │   ├── core_domain/         # Shared domain layer
    │   │   ├── entities/        # Product, Customer, etc.
    │   │   └── repositories/    # Repository interfaces
    │   ├── core_ui/             # Shared UI components
    │   │   ├── theme.dart       # Light/Dark themes
    │   │   ├── theme_controller.dart
    │   │   ├── theme_provider.dart
    │   │   ├── screens/         # Global screens (error)
    │   │   └── widgets/         # Shared widgets
    │   ├── di/                  # Dependency injection config
    │   │   ├── injection.dart   # Injectable generated code
    │   │   └── injection.config.dart
    │   ├── error/               # Error handling
    │   │   ├── failures.dart    # Failure types
    │   │   └── exceptions.dart  # Exception types
    │   ├── network/             # Network layer
    │   │   ├── supabase_config.dart  # Supabase initialization
    │   │   ├── api_client.dart       # Dio HTTP client
    │   │   └── network_info.dart     # Connectivity check
    │   ├── router/              # Navigation
    │   │   └── app_router.dart  # GoRouter configuration
    │   ├── services/            # Core services
    │   │   ├── storage_service.dart  # SharedPreferences wrapper
    │   │   ├── audio_service.dart    # Sound effects
    │   │   └── location_service.dart # Geolocation
    │   ├── usecases/            # Base usecase
    │   │   └── usecase.dart     # UseCase interface
    │   └── utils/               # Utilities
    │       ├── constants.dart
    │       ├── validators.dart
    │       └── formatters.dart
    │
    └── features/                # Feature modules (Clean Architecture)
        ├── splash/              # Splash screen
        │   └── presentation/
        │       └── screens/
        │           └── splash_screen.dart
        │
        ├── auth/                # Authentication
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── auth_remote_datasource.dart
        │   │   ├── models/
        │   │   │   └── user_model.dart
        │   │   └── repositories/
        │   │       └── auth_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── user.dart
        │   │   ├── repositories/
        │   │   │   └── auth_repository.dart
        │   │   └── usecases/
        │   │       ├── login_usecase.dart
        │   │       ├── register_usecase.dart
        │   │       ├── logout_usecase.dart
        │   │       ├── get_current_user_usecase.dart
        │   │       └── update_profile_usecase.dart
        │   └── presentation/
        │       ├── cubit/
        │       │   ├── auth_cubit.dart
        │       │   └── auth_state.dart
        │       ├── screens/
        │       │   └── login_screen.dart
        │       └── widgets/
        │           ├── login_form.dart
        │           └── social_login_buttons.dart
        │
        ├── home/                # Home screen (product listing)
        │   ├── domain/
        │   │   └── usecases/
        │   │       └── get_business_status_usecase.dart
        │   └── presentation/
        │       ├── cubit/
        │       │   ├── business_status_cubit.dart
        │       │   └── business_status_state.dart
        │       ├── screens/
        │       │   └── home_screen.dart
        │       └── widgets/
        │           ├── product_grid.dart
        │           ├── product_list_item.dart
        │           └── category_tabs.dart
        │
        ├── products/            # Product management
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── products_remote_datasource.dart
        │   │   ├── models/
        │   │   │   ├── product_model.dart
        │   │   │   └── category_model.dart
        │   │   └── repositories/
        │   │       └── products_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   ├── product.dart
        │   │   │   └── category.dart
        │   │   ├── repositories/
        │   │   │   └── products_repository.dart
        │   │   └── usecases/
        │   │       ├── get_products_usecase.dart
        │   │       └── get_categories_usecase.dart
        │   └── presentation/
        │       └── widgets/
        │           └── product_card.dart
        │
        ├── detail/              # Product detail
        │   └── presentation/
        │       ├── screens/
        │       │   └── detail_screen.dart
        │       └── widgets/
        │           ├── size_selector.dart
        │           ├── quantity_selector.dart
        │           └── addons_selector.dart
        │
        ├── cart/                # Shopping cart
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── cart_local_datasource.dart
        │   │   ├── models/
        │   │   │   └── cart_item_model.dart
        │   │   └── repositories/
        │   │       └── cart_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── cart_item.dart
        │   │   ├── repositories/
        │   │   │   └── cart_repository.dart
        │   │   └── usecases/
        │   │       ├── get_cart_usecase.dart
        │   │       ├── save_cart_usecase.dart
        │   │       └── clear_cart_usecase.dart
        │   └── presentation/
        │       ├── cubit/
        │       │   ├── cart_cubit.dart
        │       │   └── cart_state.dart
        │       ├── screens/
        │       │   └── cart_screen.dart
        │       └── widgets/
        │           ├── cart_item_card.dart
        │           └── cart_summary.dart
        │
        ├── coupons/             # Discount coupons
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── coupons_remote_datasource.dart
        │   │   ├── models/
        │   │   │   └── coupon_model.dart
        │   │   └── repositories/
        │   │       └── coupons_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── coupon.dart
        │   │   ├── repositories/
        │   │   │   └── coupons_repository.dart
        │   │   └── usecases/
        │   │       └── get_coupon_usecase.dart
        │   └── presentation/
        │       └── widgets/
        │           └── coupon_input.dart
        │
        ├── orders/              # Order management
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── orders_remote_datasource.dart
        │   │   ├── models/
        │   │   │   ├── order_model.dart
        │   │   │   └── order_item_model.dart
        │   │   └── repositories/
        │   │       └── orders_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   ├── order.dart
        │   │   │   └── order_item.dart
        │   │   ├── repositories/
        │   │   │   └── orders_repository.dart
        │   │   └── usecases/
        │   │       ├── create_order_usecase.dart
        │   │       ├── get_orders_usecase.dart
        │   │       └── get_order_detail_usecase.dart
        │   └── presentation/
        │       ├── cubit/
        │       │   ├── orders_cubit.dart
        │       │   └── orders_state.dart
        │       ├── screens/
        │       │   ├── order_confirmation_screen.dart
        │       │   ├── order_placed_screen.dart
        │       │   └── orders_screen.dart
        │       └── widgets/
        │           ├── order_card.dart
        │           └── order_timeline.dart
        │
        ├── maps/                # Address selection
        │   └── presentation/
        │       └── screens/
        │           └── maps_screen.dart (placeholder)
        │
        ├── profile/             # User profile
        │   └── presentation/
        │       └── screens/
        │           └── profile_screen.dart
        │
        └── settings/            # App settings
            └── presentation/
                └── screens/
                    └── settings_screen.dart
```

---

## 🔑 **CONCEPTOS CLAVE DE LA ARQUITECTURA**

### **1. Clean Architecture (3 Capas) - Feature-First**

Cada feature tiene su propia estructura de Clean Architecture:

#### **Data Layer** (Capa de Datos)
- **DataSources**: Fuentes de datos
  - `Remote`: Supabase API calls
  - `Local`: SharedPreferences storage
  
- **Models**: DTOs con JSON serialization
  - Extienden de las entidades del dominio
  - Incluyen `fromJson()` y `toJson()`
  - Anotaciones `@JsonSerializable()`
  
- **Repository Implementations**: Implementaciones concretas
  - Coordinan entre remote y local datasources
  - Manejan errores y convierten a Either

#### **Domain Layer** (Capa de Dominio - Business Logic)
- **Entities**: Objetos de negocio puros
  - `User` - Usuario/Cliente
  - `Product` - Producto
  - `Category` - Categoría
  - `CartItem` - Item del carrito
  - `Order` - Pedido
  - `OrderItem` - Item del pedido
  - `Coupon` - Cupón de descuento
  
- **Repositories**: Interfaces (contratos)
  - Define qué operaciones están disponibles
  - No sabe cómo se implementan
  
- **Use Cases**: Casos de uso (acciones específicas)
  - `LoginUseCase` - Iniciar sesión
  - `RegisterUseCase` - Registrar usuario
  - `GetProductsUseCase` - Obtener productos
  - `CreateOrderUseCase` - Crear pedido
  - Cada use case hace UNA cosa

#### **Presentation Layer** (Capa de Presentación)
- **Cubits**: State management con BLoC pattern
  - `AuthCubit` - Gestiona autenticación (Singleton)
  - `CartCubit` - Gestiona carrito (Singleton)
  - `OrdersCubit` - Gestiona pedidos (Factory)
  - `BusinessStatusCubit` - Gestiona estado del negocio (Factory)
  
- **States**: Estados de la UI
  - `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthError`
  - `CartState` con items, coupon, loading, error
  - `OrdersLoaded`, `OrdersLoading`, `OrdersError`
  
- **Screens**: Pantallas de la app
  - Widgets de Flutter
  - Escuchan cambios de estado con `BlocBuilder` o `BlocListener`
  
- **Widgets**: Componentes reutilizables
  - `ProductCard`, `CartItemCard`, `OrderCard`
  - `SizeSelector`, `QuantitySelector`

---

### **2. Dependency Injection con GetIt + Injectable**

```dart
// lib/src/di.dart
final getIt = GetIt.instance;

Future<void> initDi() async {
  await configureDependencies(environment: 'prod');
}
```

```dart
// lib/src/core/di/injection.dart
@InjectableInit(
  initializerName: 'configureDependencies',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies({required String environment}) async {
  // Code generated by injectable_generator
}
```

**Anotaciones Injectable**:
```dart
// Singleton - Una sola instancia para toda la app
@lazySingleton
class AuthCubit extends Cubit<AuthState> { ... }

@lazySingleton
class CartCubit extends Cubit<CartState> { ... }

// Factory - Nueva instancia cada vez
@injectable
class OrdersCubit extends Cubit<OrdersState> { ... }

// Repository
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository { ... }

// DataSource
@lazySingleton
class AuthRemoteDataSource { ... }
```

**Uso en app.dart**:
```dart
MultiBlocProvider(
  providers: [
    // Singletons - usar BlocProvider.value
    BlocProvider.value(value: getIt<AuthCubit>()),
    BlocProvider.value(value: getIt<CartCubit>()),
    
    // Factories - crear nueva instancia
    BlocProvider(create: (_) => getIt<OrdersCubit>()),
    BlocProvider(create: (_) => getIt<BusinessStatusCubit>()),
  ],
  child: MaterialApp.router(...),
)
```

---

### **3. Supabase Integration**

```dart
// lib/src/core/network/supabase_config.dart
class SupabaseConfig {
  static const String projectUrl = 'https://olrsqnoehkbswxcocqhq.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  
  static Future<void> initialize() async {
    await Supabase.initialize(url: projectUrl, anonKey: anonKey);
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
}
```

**Inicialización en main.dart**:
```dart
void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SupabaseConfig.initialize();  // Inicializar Supabase
      await initDi();                      // Inicializar DI
      runApp(const AppEntry());
    },
    (error, stack) {
      // Global error handling
      appRouter.go('/error', extra: error);
    },
  );
}
```

**Uso en DataSources**:
```dart
class AuthRemoteDataSource {
  final SupabaseClient _client = SupabaseConfig.client;
  
  Future<UserModel> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw ServerException('Login failed');
    }
    
    return UserModel.fromSupabaseUser(response.user!);
  }
}
```

---

### **4. Navigation con GoRouter**

```dart
// lib/src/core/router/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(
      path: '/order-confirmation',
      builder: (context, state) => const OrderConfirmationScreen(),
    ),
    GoRoute(
      path: '/order-placed',
      builder: (context, state) => const OrderPlacedScreen(),
    ),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/error',
      builder: (context, state) {
        final error = state.extra;
        return GlobalErrorScreen(error: error);
      },
    ),
  ],
);
```

**Navegación**:
```dart
// Navegar a una ruta
context.go('/home');

// Navegar con parámetros
context.go('/product/123');

// Navegar con extra data
context.go('/error', extra: errorObject);

// Navegar y reemplazar
context.replace('/login');

// Volver atrás
context.pop();
```

---

### **5. Theme Management**

```dart
// lib/src/core/core_ui/theme_controller.dart
class ThemeController extends ChangeNotifier {
  bool _dark = false;
  
  bool get dark => _dark;
  
  void toggleTheme() {
    _dark = !_dark;
    notifyListeners();
  }
}
```

```dart
// lib/src/core/core_ui/theme_provider.dart
class ThemeProvider extends InheritedNotifier<ThemeController> {
  const ThemeProvider({
    required ThemeController controller,
    required Widget child,
    super.key,
  }) : super(notifier: controller, child: child);
  
  static ThemeController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!.notifier!;
  }
}
```

**Uso en app.dart**:
```dart
ThemeProvider(
  controller: _themeController,
  child: Builder(
    builder: (context) {
      final tc = ThemeProvider.of(context);
      return AnimatedBuilder(
        animation: tc,
        builder: (context, _) {
          return MaterialApp.router(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: tc.dark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
          );
        },
      );
    },
  ),
)
```

---

### **6. Internationalization (i18n)**

```dart
// lib/l10n/arb/app_es.arb
{
  "@@locale": "es",
  "appTitle": "Napoli Pizza",
  "login": "Iniciar Sesión",
  "email": "Correo Electrónico",
  "password": "Contraseña",
  "addToCart": "Agregar al Carrito",
  "total": "Total",
  "placeOrder": "Realizar Pedido"
}
```

```dart
// lib/l10n/arb/app_en.arb
{
  "@@locale": "en",
  "appTitle": "Napoli Pizza",
  "login": "Login",
  "email": "Email",
  "password": "Password",
  "addToCart": "Add to Cart",
  "total": "Total",
  "placeOrder": "Place Order"
}
```

**Configuración en app.dart**:
```dart
MaterialApp.router(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('es'), // Spanish
    Locale('en'), // English
  ],
  routerConfig: appRouter,
)
```

**Uso en widgets**:
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.appTitle);
Text(l10n.login);
```

---

## 🔄 **FLUJO DE DATOS**

### **Autenticación (Login)**

```
1. Usuario ingresa email/password en LoginScreen
   ↓
2. LoginScreen llama authCubit.login(email, password)
   ↓
3. AuthCubit emite AuthLoading
   ↓
4. AuthCubit ejecuta LoginUseCase
   ↓
5. LoginUseCase llama authRepository.login()
   ↓
6. AuthRepositoryImpl llama authRemoteDataSource.login()
   ↓
7. AuthRemoteDataSource llama Supabase.auth.signInWithPassword()
   ↓
8. Supabase valida credenciales y retorna User
   ↓
9. AuthRemoteDataSource convierte a UserModel
   ↓
10. AuthRepositoryImpl convierte UserModel a User (entity)
   ↓
11. LoginUseCase retorna Either<Failure, User>
   ↓
12. AuthCubit procesa resultado:
    - Si success → emit Authenticated(user)
    - Si error → emit AuthError(message)
   ↓
13. LoginScreen escucha cambio de estado con BlocListener
   ↓
14. Si Authenticated → Navegar a HomeScreen
    Si AuthError → Mostrar error
```

---

### **Agregar Producto al Carrito**

```
1. Usuario está en DetailScreen
   ↓
2. Usuario selecciona tamaño, cantidad, addons
   ↓
3. Usuario presiona "Agregar al Carrito"
   ↓
4. DetailScreen crea CartItem con los datos
   ↓
5. DetailScreen llama cartCubit.addItem(cartItem)
   ↓
6. CartCubit agrega item a la lista actual
   ↓
7. CartCubit emite nuevo estado con items actualizados
   ↓
8. CartCubit llama _saveCart() para persistir
   ↓
9. _saveCart() ejecuta SaveCartUseCase
   ↓
10. SaveCartUseCase llama cartRepository.saveCart()
   ↓
11. CartRepositoryImpl llama cartLocalDataSource.saveCart()
   ↓
12. CartLocalDataSource guarda en SharedPreferences
   ↓
13. UI se actualiza automáticamente (BlocBuilder escucha CartState)
   ↓
14. Badge del carrito muestra cantidad actualizada
```

---

### **Realizar Pedido**

```
1. Usuario está en CartScreen
   ↓
2. Usuario revisa items, aplica cupón (opcional)
   ↓
3. Usuario presiona "Realizar Pedido"
   ↓
4. Navegar a OrderConfirmationScreen
   ↓
5. Usuario confirma dirección, método de pago
   ↓
6. Usuario presiona "Confirmar Pedido"
   ↓
7. OrderConfirmationScreen llama ordersCubit.createOrder()
   ↓
8. OrdersCubit emite OrdersLoading
   ↓
9. OrdersCubit ejecuta CreateOrderUseCase
   ↓
10. CreateOrderUseCase llama ordersRepository.createOrder()
   ↓
11. OrdersRepositoryImpl llama ordersRemoteDataSource.createOrder()
   ↓
12. OrdersRemoteDataSource:
    - Crea registro en tabla 'orders' (Supabase)
    - Crea registros en tabla 'order_items' (Supabase)
    - Actualiza inventario de productos
    - Retorna OrderModel
   ↓
13. OrdersRepositoryImpl convierte a Order (entity)
   ↓
14. CreateOrderUseCase retorna Either<Failure, Order>
   ↓
15. OrdersCubit procesa resultado:
    - Si success → emit OrderPlaced(order)
    - Si error → emit OrdersError(message)
   ↓
16. OrderConfirmationScreen escucha cambio de estado
   ↓
17. Si OrderPlaced:
    - cartCubit.clearCart()
    - Navegar a OrderPlacedScreen
    Si OrdersError:
    - Mostrar error
```

---

## 📊 **MODELOS DE DATOS (Domain Entities)**

### **User Entity**

```dart
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.createdAt,
  });
}
```

---

### **Product Entity**

```dart
class Product extends Equatable {
  final String id;
  final String restaurantId;
  final String? categoryId;
  final String name;
  final String? description;
  final int priceCents;
  final String? imageUrl;
  final List<String> images;
  final bool isAvailable;
  final bool isFeatured;
  final List<String> tags;
  final List<String> allergens;
  final int? preparationTimeMinutes;
  
  const Product({
    required this.id,
    required this.restaurantId,
    this.categoryId,
    required this.name,
    this.description,
    required this.priceCents,
    this.imageUrl,
    this.images = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    this.tags = const [],
    this.allergens = const [],
    this.preparationTimeMinutes,
  });
  
  // Precio formateado
  String get formattedPrice => '\$${(priceCents / 100).toStringAsFixed(2)}';
}
```

---

### **CartItem Entity**

```dart
class CartItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final int unitPriceCents;
  final String? size;
  final List<String> addons;
  final String? notes;
  
  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.unitPriceCents,
    this.size,
    this.addons = const [],
    this.notes,
  });
  
  // Total del item
  int get totalCents => unitPriceCents * quantity;
  
  // Precio formateado
  String get formattedTotal => '\$${(totalCents / 100).toStringAsFixed(2)}';
}
```

---

### **Order Entity**

```dart
class Order extends Equatable {
  final String id;
  final String restaurantId;
  final String customerId;
  final String orderNumber;
  final List<OrderItem> items;
  final int subtotalCents;
  final int taxCents;
  final int deliveryFeeCents;
  final int discountCents;
  final int totalCents;
  final String status;  // pending, accepted, processing, ready, delivering, delivered
  final String? deliveryAddress;
  final String? deliveryNotes;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  
  const Order({
    required this.id,
    required this.restaurantId,
    required this.customerId,
    required this.orderNumber,
    required this.items,
    required this.subtotalCents,
    required this.taxCents,
    required this.deliveryFeeCents,
    required this.discountCents,
    required this.totalCents,
    required this.status,
    this.deliveryAddress,
    this.deliveryNotes,
    this.paymentMethod,
    required this.createdAt,
    this.deliveredAt,
  });
  
  // Total formateado
  String get formattedTotal => '\$${(totalCents / 100).toStringAsFixed(2)}';
}
```

---

### **Coupon Entity**

```dart
class Coupon extends Equatable {
  final String id;
  final String code;
  final String description;
  final String type;  // 'percentage' or 'fixed'
  final int? discountPercentage;
  final int? discountAmountCents;
  final int minimumOrderCents;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  
  const Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    this.discountPercentage,
    this.discountAmountCents,
    required this.minimumOrderCents,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });
  
  // Calcular descuento
  int calculateDiscount(int subtotalCents) {
    if (type == 'percentage' && discountPercentage != null) {
      return (subtotalCents * discountPercentage! / 100).round();
    } else if (type == 'fixed' && discountAmountCents != null) {
      return discountAmountCents!;
    }
    return 0;
  }
}
```

---

## 🎨 **UI/UX Y THEMING**

### **App Theme**

```dart
// lib/src/core/core_ui/theme.dart
final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFE63946),  // Rojo Napoli
    brightness: Brightness.light,
  ),
  fontFamily: 'Avenir',
  // ... más configuración
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFE63946),
    brightness: Brightness.dark,
  ),
  fontFamily: 'Avenir',
  // ... más configuración
);
```

---

## 📱 **PANTALLAS PRINCIPALES**

### **1. Splash Screen** (`/`)
- **Funcionalidad**: Pantalla inicial con animación
- **Lógica**:
  - Muestra logo/animación Lottie
  - Verifica autenticación (authCubit.checkAuth())
  - Navega automáticamente:
    - Si authenticated → `/home`
    - Si unauthenticated → `/login`

---

### **2. Login Screen** (`/login`)
- **Funcionalidad**: Autenticación del usuario
- **Inputs**: Email, Password
- **Validaciones**:
  - Email válido
  - Password mínimo 6 caracteres
- **Estados**:
  - `AuthLoading`: Validando credenciales
  - `Authenticated`: Login exitoso → Navegar a `/home`
  - `AuthError`: Mostrar error
- **Extras**:
  - Link a registro
  - Opción "Recordar sesión"
  - Login social (Google, Facebook) - UI only

---

### **3. Home Screen** (`/home`)
- **Funcionalidad**: Listado de productos y categorías
- **Componentes**:
  - **Header**: Logo, ubicación, carrito badge
  - **Category Tabs**: Filtrar por categoría
  - **Product Grid/List**: Productos disponibles
  - **Featured Products**: Productos destacados
  - **Bottom Navigation**: Home, Orders, Profile
- **Estados**:
  - `ProductsLoading`: Cargando productos
  - `ProductsLoaded`: Muestra productos
  - `ProductsError`: Muestra error
- **Navegación**:
  - Tap en producto → `/product/:id`
  - Tap en carrito → `/cart`

---

### **4. Detail Screen** (`/product/:id`)
- **Funcionalidad**: Detalles del producto y personalización
- **Componentes**:
  - **Product Image**: Imagen principal
  - **Product Info**: Nombre, descripción, precio
  - **Size Selector**: S, M, L (si aplica)
  - **Quantity Selector**: +/-
  - **Addons Selector**: Extras disponibles
  - **Notes Input**: Notas especiales
  - **Add to Cart Button**: Agregar al carrito
- **Lógica**:
  - Calcular precio total según tamaño, cantidad, addons
  - Validar disponibilidad
  - Crear CartItem y agregar a cartCubit
- **Navegación**:
  - Después de agregar → Volver a `/home` o ir a `/cart`

---

### **5. Cart Screen** (`/cart`)
- **Funcionalidad**: Revisar y modificar carrito
- **Componentes**:
  - **Cart Items List**: Lista de items con:
    - Imagen, nombre, tamaño, addons
    - Cantidad (editable)
    - Precio unitario y total
    - Botón eliminar
  - **Coupon Input**: Aplicar cupón de descuento
  - **Cart Summary**:
    - Subtotal
    - Descuento (si hay cupón)
    - Delivery fee
    - Tax
    - Total
  - **Checkout Button**: "Realizar Pedido"
- **Estados**:
  - `CartState` con items, coupon, loading
- **Navegación**:
  - Tap "Realizar Pedido" → `/order-confirmation`

---

### **6. Order Confirmation Screen** (`/order-confirmation`)
- **Funcionalidad**: Confirmar detalles del pedido
- **Componentes**:
  - **Order Summary**: Items, total
  - **Delivery Address**: Seleccionar/editar dirección
  - **Payment Method**: Seleccionar método de pago
  - **Delivery Notes**: Notas para el repartidor
  - **Confirm Button**: "Confirmar Pedido"
- **Lógica**:
  - Validar dirección
  - Validar método de pago
  - Crear pedido (ordersCubit.createOrder())
- **Navegación**:
  - Si success → `/order-placed`
  - Si error → Mostrar error

---

### **7. Order Placed Screen** (`/order-placed`)
- **Funcionalidad**: Confirmación de pedido exitoso
- **Componentes**:
  - **Success Animation**: Lottie animation
  - **Order Number**: Número de pedido
  - **Estimated Time**: Tiempo estimado de entrega
  - **Track Order Button**: "Ver mi pedido"
  - **Continue Shopping Button**: "Seguir comprando"
- **Navegación**:
  - Tap "Ver mi pedido" → `/orders`
  - Tap "Seguir comprando" → `/home`

---

### **8. Orders Screen** (`/orders`)
- **Funcionalidad**: Historial de pedidos
- **Componentes**:
  - **Orders List**: Lista de pedidos con:
    - Número de pedido
    - Fecha
    - Estado (pending, delivered, etc.)
    - Total
    - Tap → Ver detalles
  - **Filter Tabs**: Todos, Activos, Completados
- **Estados**:
  - `OrdersLoading`: Cargando pedidos
  - `OrdersLoaded`: Muestra pedidos
  - `OrdersEmpty`: Sin pedidos
  - `OrdersError`: Muestra error
- **Navegación**:
  - Tap en pedido → Order Detail (modal o nueva pantalla)

---

## 🔐 **AUTENTICACIÓN Y PERSISTENCIA**

### **Supabase Auth**

```dart
// Login
final response = await SupabaseConfig.client.auth.signInWithPassword(
  email: email,
  password: password,
);

// Register
final response = await SupabaseConfig.client.auth.signUp(
  email: email,
  password: password,
  data: {'name': name},
);

// Logout
await SupabaseConfig.client.auth.signOut();

// Get current user
final user = SupabaseConfig.currentUser;

// Check if authenticated
final isAuth = SupabaseConfig.isAuthenticated;
```

### **Auto-Login**

```dart
// En AuthCubit
Future<void> checkAuth() async {
  emit(const AuthLoading());
  
  final result = await _getCurrentUserUseCase(NoParams());
  
  result.fold(
    (failure) => emit(const Unauthenticated()),
    (user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    },
  );
}
```

Llamado en SplashScreen:
```dart
@override
void initState() {
  super.initState();
  context.read<AuthCubit>().checkAuth();
}
```

---

## 📊 **SINCRONIZACIÓN CON NAPOLI_GUIDE.md**

### **✅ Cumple con la guía**:
1. ✅ Integración con Supabase (mismo backend que AdminDashboard)
2. ✅ Estructura de Customer (customers table)
3. ✅ Estructura de Order (orders table)
4. ✅ Precios en centavos (`_cents` suffix)
5. ✅ OrderStatus ENUM sincronizado
6. ✅ Snapshots en orders (customer_snapshot, address_snapshot)
7. ✅ Filtrado por `restaurant_id`
8. ✅ Cupones (coupons table)
9. ✅ Direcciones (customer_addresses table)

### **🔄 Flujo de sincronización con otras apps**:
```
CustomerApp → Crea Order (status: pending)
     ↓
AdminDashboard → Acepta Order (status: accepted)
     ↓
AdminDashboard → Procesa Order (status: processing)
     ↓
AdminDashboard → Ready Order (status: ready)
     ↓
CourierApp → Acepta Order (status: delivering)
     ↓
CourierApp → Entrega Order (status: delivered)
     ↓
CustomerApp → Recibe notificación (Realtime)
```

---

## 🚀 **COMANDOS**

```bash
# Desarrollo
flutter run

# Build APK (Android)
flutter build apk --release

# Build iOS
flutter build ios --release

# Tests
flutter test

# Generar código (models, DI)
flutter pub run build_runner build --delete-conflicting-outputs

# Generar traducciones
flutter gen-l10n

# Linting
flutter analyze

# Formatear código
flutter format .
```

---

## 📋 **RESUMEN EJECUTIVO**

**Napoli_CustomerApp_Mobile** es una aplicación móvil Flutter completa y bien arquitecturada que permite a los clientes realizar pedidos de pizzería. Utiliza **Clean Architecture** con feature-first organization, **BLoC pattern** para state management, **GetIt/Injectable** para dependency injection, **GoRouter** para navegación declarativa, y **Supabase** como backend. La app incluye internacionalización (es/en), tema claro/oscuro, y está completamente sincronizada con el schema de base de datos del proyecto NAPOLI.

**Estado actual**: ✅ Funcional con Supabase integration, arquitectura sólida y escalable, lista para producción.

**Características destacadas**:
- 🏗️ Clean Architecture (3 capas) con feature-first organization
- 🔄 BLoC pattern con Cubit (state management predecible)
- 💉 Dependency Injection con GetIt/Injectable (code generation)
- 🌐 Supabase integration (Auth + Database + Storage + Realtime)
- 🧪 Preparado para testing (unit, widget, integration)
- 🌍 Internationalization (es/en)
- 🎨 Tema claro/oscuro
- 📱 UI moderna y responsive
- 🔐 Autenticación con Supabase Auth
- 🛒 Carrito persistente con cupones
- 📦 Gestión completa de pedidos
- 🚀 Listo para producción
