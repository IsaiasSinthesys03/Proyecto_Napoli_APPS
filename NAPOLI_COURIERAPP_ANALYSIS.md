# 📱 **ANÁLISIS COMPLETO: Napoli_CourierApp_Mobile**

## 🏗️ **ARQUITECTURA GENERAL**

### **Stack Tecnológico**
- **Framework**: Flutter 3.9.2+ (Dart)
- **State Management**: BLoC (flutter_bloc 8.1.6) + Cubit pattern
- **Dependency Injection**: GetIt 7.7.0 + Injectable 2.4.2
- **Navigation**: GoRouter 14.2.0 (declarative routing)
- **Data Persistence**: SharedPreferences 2.2.2
- **Functional Programming**: fpdart 1.1.0 (Either type for error handling)
- **Equality**: Equatable 2.0.5 (value comparison)
- **Image Handling**: image_picker 1.0.7
- **External Actions**: url_launcher 6.2.5
- **Internationalization**: intl 0.19.0
- **Testing**: mocktail 1.0.3
- **Code Generation**: build_runner, json_serializable, injectable_generator

---

## 📁 **ESTRUCTURA DE CARPETAS (Clean Architecture)**

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root widget con providers
│
├── core/                        # Funcionalidades compartidas
│   ├── di/                      # Dependency Injection
│   │   └── injection.dart       # GetIt configuration
│   ├── navigation/              # Routing
│   │   ├── app_router.dart      # GoRouter configuration
│   │   ├── routes.dart          # Route constants
│   │   └── bottom_nav_scaffold.dart  # Bottom navigation shell
│   ├── services/                # Core services
│   │   ├── phone_service.dart   # Llamadas telefónicas
│   │   └── navigation_service.dart  # Navegación programática
│   ├── theme/                   # App theming
│   │   ├── app_theme.dart       # Theme configuration
│   │   ├── app_colors.dart      # Color palette
│   │   ├── app_text_styles.dart # Typography
│   │   └── app_dimensions.dart  # Spacing/sizing
│   └── widgets/                 # Shared widgets
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_indicator.dart
│       ├── error_message.dart
│       ├── empty_state.dart
│       └── order_card.dart
│
└── features/                    # Feature modules (Clean Architecture)
    ├── auth/                    # Autenticación
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── mock_auth_datasource.dart
    │   │   ├── models/
    │   │   │   └── driver_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── driver.dart
    │   │   │   ├── driver_status.dart (ENUM)
    │   │   │   └── vehicle_type.dart (ENUM)
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart (interface)
    │   │   └── usecases/
    │   │       ├── login_usecase.dart
    │   │       └── register_usecase.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── auth_cubit.dart
    │       │   └── auth_state.dart
    │       └── screens/
    │           ├── login_screen.dart
    │           ├── register_screen.dart
    │           └── pending_approval_screen.dart
    │
    ├── dashboard/               # Panel principal
    │   ├── data/
    │   ├── domain/
    │   │   └── usecases/
    │   │       └── toggle_online_status_usecase.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── dashboard_cubit.dart
    │       │   └── dashboard_state.dart
    │       └── screens/
    │           └── dashboard_screen.dart
    │
    ├── orders/                  # Gestión de pedidos
    │   ├── data/
    │   ├── domain/
    │   │   └── entities/
    │   │       ├── order.dart
    │   │       ├── order_status.dart (ENUM)
    │   │       ├── order_item.dart
    │   │       └── delivery_address.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── orders_cubit.dart
    │       │   └── orders_state.dart
    │       └── screens/
    │           └── order_detail_screen.dart
    │
    ├── history/                 # Historial de entregas
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── history_cubit.dart
    │       │   └── history_state.dart
    │       └── screens/
    │           └── history_screen.dart
    │
    └── profile/                 # Perfil del repartidor
        ├── data/
        ├── domain/
        │   └── entities/
        │       └── driver_profile.dart
        └── presentation/
            ├── cubit/
            │   ├── profile_cubit.dart
            │   └── profile_state.dart
            └── screens/
                ├── profile_screen.dart
                └── edit_profile_screen.dart
```

---

## 🔑 **CONCEPTOS CLAVE DE LA ARQUITECTURA**

### **1. Clean Architecture (3 Capas)**

#### **Data Layer** (Capa de Datos)
- **DataSources**: Fuentes de datos (API, Local Storage, Mock)
  - `MockAuthDataSource` - Datos simulados de autenticación
  - `MockOrdersDataSource` - Datos simulados de pedidos
  - `MockHistoryDataSource` - Datos simulados de historial
  - `MockProfileDataSource` - Datos simulados de perfil
  
- **Models**: DTOs para serialización JSON
  - Extienden de las entidades del dominio
  - Incluyen `fromJson()` y `toJson()`
  
- **Repository Implementations**: Implementaciones concretas
  - `AuthRepositoryImpl`
  - `OrdersRepositoryImpl`
  - `HistoryRepositoryImpl`
  - `ProfileRepositoryImpl`

#### **Domain Layer** (Capa de Dominio - Business Logic)
- **Entities**: Objetos de negocio puros (sin dependencias)
  - `Driver` - Repartidor
  - `Order` - Pedido
  - `OrderItem` - Item del pedido
  - `DeliveryAddress` - Dirección de entrega
  - `DriverProfile` - Perfil del repartidor
  
- **Repositories**: Interfaces (contratos)
  - Define qué operaciones están disponibles
  - No sabe cómo se implementan
  
- **Use Cases**: Casos de uso (acciones específicas)
  - `LoginUseCase` - Iniciar sesión
  - `RegisterUseCase` - Registrar repartidor
  - `ToggleOnlineStatusUseCase` - Cambiar estado online/offline
  - Cada use case hace UNA cosa

#### **Presentation Layer** (Capa de Presentación)
- **Cubits**: State management con BLoC pattern
  - `AuthCubit` - Gestiona autenticación
  - `DashboardCubit` - Gestiona dashboard
  - `OrdersCubit` - Gestiona pedidos
  - `HistoryCubit` - Gestiona historial
  - `ProfileCubit` - Gestiona perfil
  
- **States**: Estados de la UI
  - `AuthInitial`, `AuthLoading`, `Authenticated`, `AuthError`
  - `DashboardLoaded`, `DashboardError`
  - `OrdersLoaded`, `OrdersLoading`, `OrdersError`
  
- **Screens**: Pantallas de la app
  - Widgets de Flutter
  - Escuchan cambios de estado con `BlocBuilder` o `BlocListener`

---

### **2. Dependency Injection con GetIt**

```dart
// lib/core/di/injection.dart
final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Services
  getIt.registerLazySingleton<PhoneService>(() => PhoneService());
  
  // DataSources
  getIt.registerLazySingleton<MockAuthDataSource>(() => MockAuthDataSource());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dataSource: getIt<MockAuthDataSource>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  
  // Cubits (Factory - nueva instancia cada vez)
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      repository: getIt<AuthRepository>(),
    ),
  );
}
```

**Tipos de registro**:
- `registerSingleton`: Una sola instancia para toda la app
- `registerLazySingleton`: Se crea cuando se solicita por primera vez
- `registerFactory`: Nueva instancia cada vez que se solicita

---

### **3. Navigation con GoRouter**

```dart
// lib/core/navigation/app_router.dart
final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    // Auth routes (sin bottom nav)
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    
    // Main app con bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const DashboardScreen(),
              routes: [
                // Nested: Order Detail
                GoRoute(
                  path: AppRoutes.orderDetail,
                  builder: (context, state) {
                    final orderId = state.pathParameters['id']!;
                    final order = state.extra as Order?;
                    return OrderDetailScreen(orderId: orderId, order: order);
                  },
                ),
              ],
            ),
          ],
        ),
        
        // Branch 2: History
        StatefulShellBranch(...),
        
        // Branch 3: Profile
        StatefulShellBranch(...),
      ],
    ),
  ],
);
```

**Características**:
- **Declarative routing**: Rutas definidas en un solo lugar
- **StatefulShellRoute**: Mantiene el estado de cada tab
- **Nested routes**: Rutas anidadas (ej: `/dashboard/order/:id`)
- **Type-safe navigation**: Parámetros tipados
- **Deep linking**: Soporte para URLs profundas

---

### **4. State Management con BLoC/Cubit**

#### **Ejemplo: AuthCubit**

```dart
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository repository;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.repository,
  }) : super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    
    final result = await loginUseCase(email: email, password: password);
    
    result.fold(
      (error) => emit(AuthError(error)),
      (driver) {
        if (driver.canLogin) {
          emit(Authenticated(driver));
        } else if (driver.isPending) {
          emit(Registered(driver));
        } else {
          emit(const AuthError('Tu cuenta no está activa'));
        }
      },
    );
  }
}
```

**Patrón**:
1. Emitir estado de carga (`AuthLoading`)
2. Ejecutar use case
3. Manejar resultado con `Either` (fpdart)
   - `Left`: Error
   - `Right`: Éxito
4. Emitir nuevo estado

---

## 🔄 **FLUJO DE DATOS**

### **Autenticación (Login)**

```
1. Usuario ingresa email/password en LoginScreen
   ↓
2. LoginScreen llama authCubit.login()
   ↓
3. AuthCubit emite AuthLoading
   ↓
4. AuthCubit ejecuta LoginUseCase
   ↓
5. LoginUseCase llama authRepository.login()
   ↓
6. AuthRepositoryImpl llama mockAuthDataSource.login()
   ↓
7. MockAuthDataSource valida credenciales y retorna DriverModel
   ↓
8. AuthRepositoryImpl convierte DriverModel a Driver (entity)
   ↓
9. AuthRepositoryImpl guarda token en SharedPreferences
   ↓
10. LoginUseCase retorna Either<String, Driver>
   ↓
11. AuthCubit procesa resultado:
    - Si driver.canLogin → emit Authenticated(driver)
    - Si driver.isPending → emit Registered(driver)
    - Si error → emit AuthError(message)
   ↓
12. LoginScreen escucha cambio de estado con BlocListener
   ↓
13. Si Authenticated → Navegar a Dashboard
    Si Registered → Navegar a PendingApprovalScreen
    Si AuthError → Mostrar error
```

---

### **Gestión de Pedidos**

```
1. DashboardScreen se monta
   ↓
2. OrdersCubit.loadAvailableOrders() se ejecuta
   ↓
3. OrdersCubit emite OrdersLoading
   ↓
4. OrdersCubit llama ordersRepository.getAvailableOrders()
   ↓
5. OrdersRepositoryImpl llama mockOrdersDataSource.getAvailableOrders()
   ↓
6. MockOrdersDataSource retorna lista de OrderModel
   ↓
7. OrdersRepositoryImpl convierte a List<Order>
   ↓
8. OrdersCubit emite OrdersLoaded(orders)
   ↓
9. DashboardScreen muestra lista de pedidos
   ↓
10. Usuario toca un pedido
   ↓
11. Navegar a OrderDetailScreen con orderId
   ↓
12. OrderDetailScreen muestra detalles
   ↓
13. Usuario presiona "Aceptar Pedido"
   ↓
14. OrdersCubit.updateOrderStatus(orderId, 'accepted')
   ↓
15. OrdersCubit emite OrdersLoading
   ↓
16. OrdersCubit llama ordersRepository.updateOrderStatus()
   ↓
17. MockOrdersDataSource actualiza estado del pedido
   ↓
18. OrdersCubit emite OrdersLoaded con pedido actualizado
   ↓
19. UI se actualiza automáticamente
```

---

## 📊 **MODELOS DE DATOS (Domain Entities)**

### **Driver Entity**

```dart
class Driver extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final VehicleType vehicleType;  // ENUM: moto, bici, auto
  final String licensePlate;
  final DriverStatus status;      // ENUM: pending, approved, active, inactive
  final bool isOnline;
  final DateTime createdAt;
  
  // Estadísticas
  final int totalDeliveries;
  final double rating;            // 0.0 - 5.0
  final double totalEarnings;
  
  // Getters
  bool get canLogin => status.canLogin;
  bool get isPending => status == DriverStatus.pending;
}
```

**DriverStatus ENUM**:
```dart
enum DriverStatus {
  pending,   // Esperando aprobación del admin
  approved,  // Aprobado, puede trabajar
  active,    // Activo, puede recibir pedidos
  inactive,  // Inactivo
}

extension DriverStatusExtension on DriverStatus {
  bool get canLogin => this == DriverStatus.active || this == DriverStatus.approved;
}
```

**VehicleType ENUM**:
```dart
enum VehicleType {
  moto,
  bici,
  auto,
}
```

---

### **Order Entity**

```dart
class Order extends Equatable {
  final String id;
  final String orderNumber;      // "#1001"
  final String customerName;
  final String customerPhone;
  final DeliveryAddress deliveryAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final double driverEarnings;
  final double distanceKm;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  
  // Getter
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
```

**OrderStatus ENUM**:
```dart
enum OrderStatus {
  available,   // Disponible para aceptar
  accepted,    // Aceptado por el driver
  pickedUp,    // Recogido del restaurante
  delivered,   // Entregado al cliente
  cancelled,   // Cancelado
}
```

**Flujo de estados**:
```
available → accepted → pickedUp → delivered
            ↓
         cancelled
```

---

### **OrderItem Entity**

```dart
class OrderItem extends Equatable {
  final String name;
  final int quantity;
  final double price;
  final String? notes;
}
```

---

### **DeliveryAddress Entity**

```dart
class DeliveryAddress extends Equatable {
  final String street;
  final String details;
  final String? notes;
  final double latitude;
  final double longitude;
}
```

---

## 🎨 **UI/UX Y THEMING**

### **App Theme**

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'Avenir',
      textTheme: AppTextStyles.textTheme,
      // ... más configuración
    );
  }
  
  static ThemeData getDarkTheme() {
    // Similar pero con Brightness.dark
  }
}
```

### **Color Palette**

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFFE63946);      // Rojo Napoli
  static const Color secondary = Color(0xFF457B9D);    // Azul
  static const Color success = Color(0xFF06D6A0);      // Verde
  static const Color warning = Color(0xFFF77F00);      // Naranja
  static const Color error = Color(0xFFD62828);        // Rojo error
  static const Color background = Color(0xFFF8F9FA);   // Gris claro
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
}
```

### **Typography**

```dart
// lib/core/theme/app_text_styles.dart
class AppTextStyles {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
  );
}
```

---

## 📱 **PANTALLAS PRINCIPALES**

### **1. Login Screen** (`/login`)
- **Funcionalidad**: Autenticación del repartidor
- **Inputs**: Email, Password
- **Validaciones**:
  - Email válido
  - Password mínimo 6 caracteres
- **Estados**:
  - `AuthInitial`: Formulario vacío
  - `AuthLoading`: Validando credenciales
  - `Authenticated`: Login exitoso → Navegar a Dashboard
  - `Registered`: Cuenta pendiente → Navegar a PendingApprovalScreen
  - `AuthError`: Mostrar error
- **Navegación**: Link a RegisterScreen

---

### **2. Register Screen** (`/register`)
- **Funcionalidad**: Registro de nuevo repartidor
- **Inputs**:
  - Nombre
  - Email
  - Password
  - Confirmar Password
  - Teléfono
  - Tipo de vehículo (Dropdown: moto, bici, auto)
  - Placa del vehículo
  - Foto de perfil (opcional)
- **Validaciones**:
  - Todos los campos requeridos
  - Email válido y único
  - Passwords coinciden
  - Teléfono formato válido
  - Placa única
- **Estados**:
  - `AuthLoading`: Registrando
  - `Registered`: Registro exitoso → Navegar a PendingApprovalScreen
  - `AuthError`: Mostrar error
- **Navegación**: Link a LoginScreen

---

### **3. Pending Approval Screen** (`/pending-approval`)
- **Funcionalidad**: Pantalla de espera mientras admin aprueba cuenta
- **Contenido**:
  - Mensaje: "Tu cuenta está siendo revisada"
  - Información del driver registrado
  - Botón "Volver a Login"
- **No hay estado**: Pantalla estática

---

### **4. Dashboard Screen** (`/dashboard`)
- **Funcionalidad**: Panel principal con pedidos disponibles
- **Componentes**:
  - **Header**: Nombre del driver, estado online/offline toggle
  - **Estadísticas**: Total entregas, rating, ganancias
  - **Lista de pedidos disponibles**:
    - OrderCard con:
      - Número de pedido
      - Nombre del cliente
      - Dirección
      - Total
      - Ganancias del driver
      - Distancia
      - Botón "Ver Detalles"
  - **Bottom Navigation**: Dashboard, History, Profile
- **Estados**:
  - `DashboardLoaded`: Muestra pedidos
  - `DashboardError`: Muestra error
- **Navegación**: Tap en pedido → OrderDetailScreen

---

### **5. Order Detail Screen** (`/dashboard/order/:id`)
- **Funcionalidad**: Detalles completos del pedido
- **Componentes**:
  - **Header**: Número de pedido, estado
  - **Info del cliente**:
    - Nombre
    - Teléfono (con botón para llamar)
  - **Dirección de entrega**:
    - Calle
    - Detalles
    - Notas
    - Botón "Abrir en Maps"
  - **Items del pedido**:
    - Lista de productos
    - Cantidad
    - Precio
    - Notas especiales
  - **Resumen**:
    - Subtotal
    - Delivery fee
    - Total
    - Ganancias del driver
    - Distancia
  - **Botones de acción** (según estado):
    - `available`: "Aceptar Pedido"
    - `accepted`: "Marcar como Recogido"
    - `pickedUp`: "Marcar como Entregado"
    - `delivered`: Mostrar timestamp de entrega
- **Estados**:
  - `OrdersLoading`: Actualizando estado
  - `OrdersLoaded`: Muestra detalles
  - `OrdersError`: Muestra error
- **Navegación**: Back → Dashboard

---

### **6. History Screen** (`/history`)
- **Funcionalidad**: Historial de entregas completadas
- **Componentes**:
  - **Filtros**: Hoy, Semana, Mes
  - **Resumen del período**:
    - Total entregas
    - Total ganancias
    - Promedio por entrega
  - **Lista de pedidos completados**:
    - OrderCard (versión simplificada)
    - Fecha de entrega
    - Ganancias
    - Tap → OrderDetailScreen (solo lectura)
- **Estados**:
  - `HistoryLoading`: Cargando historial
  - `HistoryLoaded`: Muestra pedidos
  - `HistoryEmpty`: Sin entregas en el período
  - `HistoryError`: Muestra error
- **Navegación**: Tap en pedido → OrderDetailScreen

---

### **7. Profile Screen** (`/profile`)
- **Funcionalidad**: Perfil del repartidor
- **Componentes**:
  - **Header**:
    - Foto de perfil
    - Nombre
    - Email
    - Rating (estrellas)
  - **Información**:
    - Teléfono
    - Tipo de vehículo
    - Placa
    - Estado de cuenta
  - **Estadísticas**:
    - Total entregas
    - Total ganancias
    - Miembro desde
  - **Botones**:
    - "Editar Perfil" → EditProfileScreen
    - "Cerrar Sesión"
- **Estados**:
  - `ProfileLoaded`: Muestra perfil
  - `ProfileError`: Muestra error
- **Navegación**: 
  - Tap "Editar Perfil" → EditProfileScreen
  - Tap "Cerrar Sesión" → Logout y navegar a LoginScreen

---

### **8. Edit Profile Screen** (`/profile/edit`)
- **Funcionalidad**: Editar información del perfil
- **Inputs**:
  - Nombre
  - Teléfono
  - Tipo de vehículo
  - Placa
  - Foto de perfil (cambiar)
  - Cambiar contraseña (opcional)
- **Validaciones**: Similares a registro
- **Estados**:
  - `ProfileLoading`: Guardando cambios
  - `ProfileUpdated`: Cambios guardados → Volver a ProfileScreen
  - `ProfileError`: Mostrar error
- **Navegación**: Back → ProfileScreen

---

## 🔐 **AUTENTICACIÓN Y PERSISTENCIA**

### **Token Storage**

```dart
// SharedPreferences para guardar token
class AuthRepositoryImpl implements AuthRepository {
  final MockAuthDataSource dataSource;
  final SharedPreferences prefs;
  
  static const String _tokenKey = 'auth_token';
  static const String _driverIdKey = 'driver_id';
  
  Future<void> _saveToken(String token, String driverId) async {
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_driverIdKey, driverId);
  }
  
  Future<String?> getToken() async {
    return prefs.getString(_tokenKey);
  }
  
  Future<void> logout() async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_driverIdKey);
  }
}
```

### **Auto-Login**

```dart
// En AuthCubit
Future<void> checkAuthStatus() async {
  emit(const AuthLoading());
  
  final driver = await repository.getCurrentDriver();
  
  if (driver != null && driver.canLogin) {
    emit(Authenticated(driver));
  } else {
    emit(const AuthInitial());
  }
}
```

Llamado en `app.dart`:
```dart
BlocProvider(
  create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
),
```

---

## 🌐 **INTEGRACIÓN CON API (Preparado para Backend Real)**

### **API Specification**

Según `API_SPECIFICATION.md`, el backend debe proveer:

#### **Auth Endpoints**
- `POST /auth/login` - Login
- `POST /auth/register` - Registro

#### **Driver Endpoints**
- `GET /drivers/me` - Perfil actual
- `PATCH /drivers/me` - Actualizar perfil
- `POST /drivers/me/password` - Cambiar contraseña
- `PATCH /drivers/me/settings` - Configuración
- `POST /drivers/me/status` - Toggle online/offline

#### **Order Endpoints**
- `GET /orders/available` - Pedidos disponibles
- `GET /orders/active` - Pedidos activos del driver
- `GET /orders/history?period=today|week|month` - Historial
- `GET /orders/{id}` - Detalle de pedido
- `PATCH /orders/{id}/status` - Actualizar estado

### **Transición de Mock a API Real**

**Actualmente** (Mock):
```dart
class MockAuthDataSource {
  Future<DriverModel> login(String email, String password) async {
    // Simula delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Valida credenciales hardcodeadas
    if (email == 'driver@napoli.com' && password == '123456') {
      return DriverModel(...);
    }
    throw Exception('Credenciales inválidas');
  }
}
```

**Futuro** (API Real):
```dart
class ApiAuthDataSource {
  final http.Client client;
  final String baseUrl;
  
  Future<DriverModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DriverModel.fromJson(json['driver']);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }
}
```

**Solo cambiar en `injection.dart`**:
```dart
// Antes
getIt.registerLazySingleton<MockAuthDataSource>(() => MockAuthDataSource());

// Después
getIt.registerLazySingleton<ApiAuthDataSource>(
  () => ApiAuthDataSource(
    client: http.Client(),
    baseUrl: 'https://api.napoli.com/v1',
  ),
);
```

---

## 📋 **ENUMS Y CONSTANTES**

### **OrderStatus**
```dart
enum OrderStatus {
  available,   // Disponible para aceptar
  accepted,    // Aceptado por driver
  pickedUp,    // Recogido del restaurante
  delivered,   // Entregado al cliente
  cancelled,   // Cancelado
}
```

### **DriverStatus**
```dart
enum DriverStatus {
  pending,     // Esperando aprobación
  approved,    // Aprobado por admin
  active,      // Activo, puede trabajar
  inactive,    // Inactivo
}
```

### **VehicleType**
```dart
enum VehicleType {
  moto,
  bici,
  auto,
}
```

### **Routes**
```dart
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String pendingApproval = '/pending-approval';
  static const String dashboard = '/dashboard';
  static const String orderDetail = 'order/:id';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String editProfile = 'edit';
}
```

---

## 🧪 **TESTING**

### **Unit Tests**
- Tests de Use Cases
- Tests de Repositories
- Tests de Cubits

### **Widget Tests**
- Tests de Screens
- Tests de Widgets compartidos

### **Ejemplo de Test**

```dart
void main() {
  group('LoginUseCase', () {
    late LoginUseCase useCase;
    late MockAuthRepository mockRepository;
    
    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginUseCase(mockRepository);
    });
    
    test('should return Driver when login is successful', () async {
      // Arrange
      final driver = Driver(...);
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => Right(driver));
      
      // Act
      final result = await useCase(email: 'test@test.com', password: '123456');
      
      // Assert
      expect(result, Right(driver));
      verify(() => mockRepository.login('test@test.com', '123456')).called(1);
    });
  });
}
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

# Linting
flutter analyze

# Formatear código
flutter format .
```

---

## 📊 **SINCRONIZACIÓN CON NAPOLI_GUIDE.md**

### **✅ Cumple con la guía**:
1. ✅ OrderStatus ENUM con valores correctos (available, accepted, pickedUp, delivered, cancelled)
2. ✅ DriverStatus ENUM (pending, approved, active, inactive)
3. ✅ VehicleType ENUM (moto, bici, auto)
4. ✅ Timestamps para cada estado de orden
5. ✅ Estructura de Driver con estadísticas (totalDeliveries, rating, totalEarnings)
6. ✅ Estructura de Order con todos los campos necesarios
7. ✅ Snapshots de customer y address (en deliveryAddress entity)

### **⚠️ Diferencias con AdminDashboard**:
- **AdminDashboard** usa Supabase directamente
- **CourierApp** usa Mock DataSources (preparado para API REST)
- **Razón**: CourierApp es mobile, necesita API REST para comunicación

### **🔄 Flujo de sincronización**:
```
CustomerApp → Crea Order (status: pending)
     ↓
AdminDashboard → Acepta Order (status: accepted)
     ↓
AdminDashboard → Procesa Order (status: processing)
     ↓
AdminDashboard → Ready Order (status: ready)
     ↓
CourierApp → Acepta Order (status: accepted en CourierApp)
     ↓
CourierApp → Recoge Order (status: pickedUp)
     ↓
CourierApp → Entrega Order (status: delivered)
```

**Nota**: Los estados de CourierApp son diferentes a los de AdminDashboard porque representan el flujo desde la perspectiva del repartidor.

---

## 🔍 **PUNTOS CLAVE PARA CORRECCIONES**

Ahora que soy experto en este proyecto, estoy listo para:

1. **Sincronizar estados** entre AdminDashboard y CourierApp
2. **Implementar API real** reemplazando Mock DataSources
3. **Agregar validaciones** faltantes
4. **Optimizar performance** de la UI
5. **Implementar features** faltantes según API_SPECIFICATION.md

---

## 📋 **RESUMEN EJECUTIVO**

**Napoli_CourierApp_Mobile** es una aplicación móvil Flutter bien arquitecturada que permite a los repartidores gestionar sus entregas. Utiliza **Clean Architecture** con 3 capas claramente separadas (data, domain, presentation), **BLoC pattern** para state management, **GetIt** para dependency injection, y **GoRouter** para navegación declarativa. La app está preparada para integrarse con un backend REST API, actualmente usando Mock DataSources para desarrollo y testing.

**Estado actual**: ✅ Funcional con datos mock, arquitectura sólida y escalable, lista para integración con API real.

**Características destacadas**:
- 🏗️ Clean Architecture (separación de responsabilidades)
- 🔄 BLoC pattern (state management predecible)
- 💉 Dependency Injection (código testeable)
- 🧪 Preparado para testing (unit, widget, integration)
- 📱 UI moderna y responsive
- 🔐 Autenticación con persistencia
- 🚀 Listo para producción (solo falta backend real)
