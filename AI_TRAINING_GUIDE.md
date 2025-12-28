# 🤖 AI Training Guide - Napoli Pizza Delivery System

## 📋 Índice
1. [Visión General del Proyecto](#visión-general-del-proyecto)
2. [Metodología de Trabajo](#metodología-de-trabajo)
3. [Proyectos Completados](#proyectos-completados)
4. [Proyecto Actual: CustomerApp](#proyecto-actual-customerapp)
5. [Arquitectura y Tecnologías](#arquitectura-y-tecnologías)
6. [Guías de Referencia](#guías-de-referencia)
7. [Patrones y Mejores Prácticas](#patrones-y-mejores-prácticas)

---

## 🎯 Visión General del Proyecto

### **Sistema Napoli Pizza Delivery**
Sistema completo de delivery de pizzas con 3 aplicaciones principales:

1. **✅ CourierApp (COMPLETADA)** - App móvil para repartidores (Flutter)
2. **🔄 CustomerApp (EN DESARROLLO)** - App móvil para clientes (Flutter)
3. **📊 AdminDashboard** - Panel web de administración (React)

### **Backend**
- **Supabase** (PostgreSQL + Realtime + Storage + Auth)
- **Stored Procedures** para toda la lógica de negocio
- **Row Level Security (RLS)** para seguridad de datos

---

## 🛠️ Metodología de Trabajo

### **Principios Fundamentales**

#### 1. **Stored Procedures First**
```sql
-- ✅ CORRECTO: Toda la lógica en stored procedures
CREATE OR REPLACE FUNCTION get_available_orders(p_restaurant_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Lógica aquí
END;
$$;
```

**❌ NUNCA hacer queries directas desde la app:**
```dart
// ❌ INCORRECTO
final response = await _client
  .from('orders')
  .select()
  .eq('status', 'available');
```

**✅ SIEMPRE usar stored procedures:**
```dart
// ✅ CORRECTO
final response = await _client.rpc('get_available_orders', params: {
  'p_restaurant_id': restaurantId,
});
```

#### 2. **Arquitectura Limpia (Clean Architecture)**

```
lib/
├── core/                    # Configuración, DI, utils
├── features/               # Funcionalidades por módulo
│   └── orders/
│       ├── data/           # DataSources, Repositories
│       ├── domain/         # Entities, Repositories (interfaces)
│       └── presentation/   # UI, Cubits, States
```

**Flujo de Datos:**
```
UI (Screen) 
  ↓
Cubit (State Management)
  ↓
Repository (Interface)
  ↓
RepositoryImpl (Implementation)
  ↓
RemoteDataSource
  ↓
Supabase (Stored Procedure)
```

#### 3. **Debugging Exhaustivo**

**SIEMPRE agregar logs detallados:**
```dart
Future<List<Order>> getAvailableOrders(String restaurantId) async {
  try {
    print('🔍 DEBUG - Getting available orders for restaurant: $restaurantId');
    
    final response = await _client.rpc('get_available_orders', params: {
      'p_restaurant_id': restaurantId,
    });
    
    print('✅ Response received: $response');
    
    // Parse data...
    
    print('📦 Parsed ${orders.length} orders');
    return orders;
  } catch (e) {
    print('❌ Error getting orders: $e');
    throw Exception('Error: $e');
  }
}
```

**Emojis para logs:**
- 🔍 DEBUG - Inicio de operación
- ✅ SUCCESS - Operación exitosa
- ❌ ERROR - Error detectado
- 📦 DATA - Datos parseados
- 🔄 PROCESS - Proceso en curso

#### 4. **Manejo de Errores con Either**

```dart
import 'package:fpdart/fpdart.dart';

// ✅ SIEMPRE retornar Either<String, T>
Future<Either<String, List<Order>>> getOrders() async {
  try {
    final orders = await _dataSource.getOrders();
    return right(orders);
  } catch (e) {
    return left('Error al obtener órdenes: $e');
  }
}
```

#### 5. **Verificación de Estructura de BD**

**ANTES de crear stored procedures, SIEMPRE verificar estructura:**
```sql
-- Diagnóstico de tabla
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;

-- Ver ejemplo de datos
SELECT * FROM orders LIMIT 1;
```

---

## ✅ Proyectos Completados

### **Napoli_CourierApp_Mobile**

#### **Funcionalidades Implementadas:**

1. **Authentication** ✅
   - Login con email/password
   - Registro de nuevos drivers
   - Validación de estado del driver (pending/approved/active)
   - Stored Procedures: `login_driver`, `register_driver`

2. **Dashboard** ✅
   - Visualización de datos del driver
   - Toggle online/offline
   - Estadísticas básicas
   - Mock data (pendiente conectar a Supabase)

3. **Orders (Órdenes)** ✅
   - Ver órdenes disponibles
   - Aceptar órdenes
   - Marcar como recogida
   - Completar entrega
   - Stored Procedures:
     - `get_available_orders`
     - `accept_order`
     - `pickup_order`
     - `complete_order`

4. **History (Historial)** ✅
   - Ver órdenes completadas
   - Detalles de cada orden
   - Items y costos
   - Privacidad del cliente (teléfono/ubicación ocultos)
   - Stored Procedure: `get_driver_orders`

5. **Profile (Perfil)** ✅
   - Ver perfil del driver
   - Editar información personal
   - Actualización de vehículo
   - Configuraciones (notificaciones, idioma)
   - Stored Procedures:
     - `get_driver_profile`
     - `update_driver_profile`

#### **Lecciones Aprendidas:**

1. **RLS (Row Level Security)**
   - Configurar políticas ANTES de hacer queries
   - Usar `SECURITY DEFINER` en stored procedures
   - Verificar permisos con `SELECT current_user;`

2. **Parseo de JSON**
   - Supabase retorna JSON desde stored procedures
   - SIEMPRE verificar estructura antes de parsear
   - Manejar campos opcionales con `??` operator

3. **Estados de Pedidos**
   - Flujo simplificado: `available` → `accepted` → `picked_up` → `delivered`
   - Validaciones en stored procedures
   - Actualizar múltiples tablas en una transacción

4. **Fechas y Zonas Horarias**
   - Supabase guarda en UTC
   - Convertir a local en UI: `.toLocal()`
   - Usar `timestamp with time zone` en BD

---

## 🔄 Proyecto Actual: CustomerApp

### **Objetivo**
Desarrollar la aplicación móvil para clientes que permita:
- Navegar menú de pizzas
- Personalizar pedidos
- Realizar órdenes
- Rastrear delivery en tiempo real
- Ver historial de pedidos

### **Documentos de Referencia**
1. `NAPOLI_CUSTOMERAPP_ANALYSIS.md` - Análisis completo de la app
2. `INTEGRATION_PLAN.md` - Plan de integración con Supabase
3. `NAPOLI_GUIDE.md` - Guía general del proyecto

### **Funcionalidades a Implementar**

#### **Fase 1: Authentication**
- [ ] Login/Registro de clientes
- [ ] Gestión de direcciones
- [ ] Perfil del cliente

#### **Fase 2: Menu & Cart**
- [ ] Visualización de menú
- [ ] Personalización de pizzas
- [ ] Carrito de compras
- [ ] Cálculo de precios

#### **Fase 3: Orders**
- [ ] Crear orden
- [ ] Seleccionar método de pago
- [ ] Confirmar pedido
- [ ] Ver estado de orden

#### **Fase 4: Tracking**
- [ ] Rastreo en tiempo real
- [ ] Notificaciones de estado
- [ ] Chat con repartidor (opcional)

#### **Fase 5: History**
- [ ] Historial de pedidos
- [ ] Reordenar pedidos anteriores
- [ ] Calificaciones y reviews

### **Stored Procedures Necesarios**

```sql
-- Authentication
CREATE FUNCTION register_customer(...)
CREATE FUNCTION login_customer(...)
CREATE FUNCTION update_customer_profile(...)

-- Menu
CREATE FUNCTION get_menu_items(p_restaurant_id UUID)
CREATE FUNCTION get_pizza_details(p_pizza_id UUID)

-- Cart & Orders
CREATE FUNCTION create_order(...)
CREATE FUNCTION get_customer_orders(p_customer_id UUID)
CREATE FUNCTION cancel_order(p_order_id UUID)

-- Tracking
CREATE FUNCTION get_order_status(p_order_id UUID)
CREATE FUNCTION get_driver_location(p_order_id UUID)
```

---

## 🏗️ Arquitectura y Tecnologías

### **Stack Tecnológico**

#### **Frontend (Flutter)**
```yaml
dependencies:
  flutter_bloc: ^8.1.3        # State management
  go_router: ^12.0.0          # Navigation
  supabase_flutter: ^2.0.0    # Backend
  fpdart: ^1.1.0              # Functional programming
  google_maps_flutter: ^2.5.0 # Maps
  geolocator: ^10.1.0         # Location
```

#### **Backend (Supabase)**
- **PostgreSQL** - Base de datos
- **Realtime** - Actualizaciones en tiempo real
- **Storage** - Almacenamiento de imágenes
- **Auth** - Autenticación de usuarios
- **Edge Functions** - Lógica serverless (opcional)

### **Estructura de Base de Datos**

#### **Tablas Principales:**

```sql
-- Clientes
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR NOT NULL UNIQUE,
  name VARCHAR NOT NULL,
  phone VARCHAR NOT NULL,
  photo_url VARCHAR,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Direcciones
CREATE TABLE customer_addresses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES customers(id),
  label VARCHAR,  -- 'Casa', 'Trabajo', etc.
  address TEXT NOT NULL,
  latitude NUMERIC,
  longitude NUMERIC,
  is_default BOOLEAN DEFAULT false
);

-- Menú
CREATE TABLE menu_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID REFERENCES restaurants(id),
  name VARCHAR NOT NULL,
  description TEXT,
  category VARCHAR,  -- 'pizza', 'bebida', 'postre'
  base_price_cents INT NOT NULL,
  image_url VARCHAR,
  is_available BOOLEAN DEFAULT true
);

-- Órdenes (ya existe, compartida con CourierApp)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES customers(id),
  driver_id UUID REFERENCES drivers(id),
  restaurant_id UUID REFERENCES restaurants(id),
  status order_status,
  -- ... más campos
);
```

---

## 📚 Guías de Referencia

### **Documentos Clave**

#### 1. **NAPOLI_GUIDE.md**
- Visión general del sistema
- Flujo de trabajo
- Roles y permisos

#### 2. **INTEGRATION_PLAN.md**
- Plan de integración con Supabase
- Roadmap de funcionalidades
- Dependencias entre apps

#### 3. **NAPOLI_CUSTOMERAPP_ANALYSIS.md**
- Análisis detallado de CustomerApp
- Wireframes y flujos
- Casos de uso

#### 4. **NAPOLI_ADMINDASHBOARD_ANALYSIS.md**
- Análisis del panel de administración
- Gestión de órdenes
- Reportes y estadísticas

### **Artifacts Importantes de CourierApp**

Revisa estos artifacts para entender patrones implementados:

1. **orders_implementation_plan.md** - Cómo se implementó Orders
2. **history_implementation_plan.md** - Cómo se implementó History
3. **profile_implementation_summary.md** - Cómo se implementó Profile
4. **orders_success_summary.md** - Resumen de éxito de Orders

---

## 🎨 Patrones y Mejores Prácticas

### **1. Naming Conventions**

#### **Stored Procedures:**
```sql
-- Patrón: <verbo>_<entidad>
get_available_orders
accept_order
update_driver_profile
complete_order
```

#### **Dart Files:**
```dart
// DataSources
orders_remote_datasource.dart
auth_remote_datasource.dart

// Repositories
orders_repository_impl.dart
profile_repository_impl.dart

// Cubits
orders_cubit.dart
auth_cubit.dart

// States
orders_state.dart
profile_state.dart
```

### **2. Error Handling Pattern**

```dart
// Repository
Future<Either<String, List<Order>>> getOrders() async {
  try {
    final orders = await _dataSource.getOrders();
    return right(orders);
  } catch (e) {
    return left('Error al obtener órdenes: $e');
  }
}

// Cubit
Future<void> loadOrders() async {
  emit(const OrdersLoading());
  
  final result = await _repository.getOrders();
  
  result.fold(
    (error) => emit(OrdersError(error)),
    (orders) => emit(OrdersLoaded(orders)),
  );
}

// UI
BlocBuilder<OrdersCubit, OrdersState>(
  builder: (context, state) {
    if (state is OrdersLoading) return LoadingWidget();
    if (state is OrdersError) return ErrorWidget(state.message);
    if (state is OrdersLoaded) return OrdersList(state.orders);
    return EmptyWidget();
  },
)
```

### **3. Dependency Injection Pattern**

```dart
// lib/core/di/injection.dart
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  getIt.registerLazySingleton<SupabaseClient>(
    () => SupabaseConfig.client
  );
  
  // DataSources
  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSource(getIt<SupabaseClient>())
  );
  
  // Repositories
  getIt.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(getIt<OrdersRemoteDataSource>())
  );
  
  // Cubits
  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(repository: getIt<OrdersRepository>())
  );
}
```

### **4. Stored Procedure Pattern**

```sql
CREATE OR REPLACE FUNCTION get_entity_data(
    p_param1 UUID,
    p_param2 TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM table WHERE id = p_param1) THEN
        RAISE EXCEPTION 'Entity not found: %', p_param1;
    END IF;
    
    -- Query principal
    SELECT json_build_object(
        'id', t.id,
        'field1', t.field1,
        'field2', t.field2,
        'nested', (
            SELECT json_agg(json_build_object(
                'id', n.id,
                'value', n.value
            ))
            FROM nested_table n
            WHERE n.parent_id = t.id
        )
    )
    INTO v_result
    FROM table t
    WHERE t.id = p_param1;
    
    RETURN v_result;
END;
$$;

-- Comentario
COMMENT ON FUNCTION get_entity_data(UUID, TEXT) IS 
'Obtiene datos de entidad con relaciones anidadas';
```

### **5. Realtime Pattern**

```dart
// DataSource
Stream<List<Order>> subscribeToOrders(String customerId) {
  return _client
    .from('orders')
    .stream(primaryKey: ['id'])
    .eq('customer_id', customerId)
    .map((data) => data.map((json) => Order.fromJson(json)).toList());
}

// Cubit
StreamSubscription? _ordersSubscription;

Future<void> startRealtimeOrders(String customerId) async {
  _ordersSubscription = _dataSource
    .subscribeToOrders(customerId)
    .listen(
      (orders) => emit(OrdersUpdated(orders)),
      onError: (error) => emit(OrdersError(error.toString())),
    );
}

@override
Future<void> close() {
  _ordersSubscription?.cancel();
  return super.close();
}
```

---

## 🚀 Workflow de Desarrollo

### **Paso a Paso para Nueva Funcionalidad**

#### **1. Análisis**
```markdown
- [ ] Leer documentación de la funcionalidad
- [ ] Identificar entidades y relaciones
- [ ] Revisar flujos de usuario
- [ ] Verificar dependencias con otras features
```

#### **2. Base de Datos**
```markdown
- [ ] Verificar estructura de tablas existentes
- [ ] Crear/modificar tablas si es necesario
- [ ] Diseñar stored procedures
- [ ] Configurar RLS policies
- [ ] Probar procedures en Supabase
```

#### **3. Backend (DataSource)**
```markdown
- [ ] Crear RemoteDataSource
- [ ] Implementar métodos que llaman a procedures
- [ ] Agregar logs de debugging
- [ ] Manejar errores correctamente
```

#### **4. Domain**
```markdown
- [ ] Crear/actualizar entidades
- [ ] Definir interfaces de repositorios
- [ ] Documentar contratos
```

#### **5. Data (Repository)**
```markdown
- [ ] Implementar repositorio
- [ ] Usar Either para manejo de errores
- [ ] Parsear respuestas de procedures
```

#### **6. Presentation (Cubit)**
```markdown
- [ ] Crear estados necesarios
- [ ] Implementar lógica de negocio
- [ ] Emitir estados apropiados
- [ ] Manejar casos de error
```

#### **7. UI**
```markdown
- [ ] Crear screens
- [ ] Implementar widgets
- [ ] Conectar con Cubit
- [ ] Manejar estados (loading, error, success)
```

#### **8. Dependency Injection**
```markdown
- [ ] Registrar DataSource
- [ ] Registrar Repository
- [ ] Registrar Cubit
- [ ] Verificar orden de dependencias
```

#### **9. Testing**
```markdown
- [ ] Probar flujo completo
- [ ] Verificar casos de error
- [ ] Validar datos en BD
- [ ] Revisar logs
```

---

## ⚠️ Problemas Comunes y Soluciones

### **1. RLS Blocking Queries**

**Problema:**
```
Error: new row violates row-level security policy
```

**Solución:**
```sql
-- Usar SECURITY DEFINER en stored procedures
CREATE OR REPLACE FUNCTION my_function(...)
SECURITY DEFINER  -- ← Esto bypassa RLS
AS $$
...
$$;
```

### **2. JSON Parsing Errors**

**Problema:**
```
type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'
```

**Solución:**
```dart
// ✅ Verificar tipo antes de parsear
if (response is List) {
  return (response as List).map((json) => Order.fromJson(json)).toList();
} else if (response is Map) {
  return [Order.fromJson(response as Map<String, dynamic>)];
}
```

### **3. UUID vs String**

**Problema:**
```
Invalid UUID format
```

**Solución:**
```dart
// ✅ SIEMPRE usar String en Dart
class Driver {
  final String id;  // ← String, no UUID
  final String restaurantId;
}

// En stored procedure, usar UUID
CREATE FUNCTION my_func(p_id UUID) ...
```

### **4. Fechas en UTC**

**Problema:**
```
Fecha muestra hora incorrecta
```

**Solución:**
```dart
// ✅ Convertir a local en UI
Text(order.createdAt.toLocal().toString())

// O usar intl para formato
DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt.toLocal())
```

### **5. Stored Procedure Not Found**

**Problema:**
```
function get_orders(uuid) does not exist
```

**Solución:**
```sql
-- Verificar que existe
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name = 'get_orders';

-- Verificar parámetros
SELECT 
    routine_name,
    parameter_name,
    data_type
FROM information_schema.parameters
WHERE specific_schema = 'public'
AND routine_name = 'get_orders';
```

---

## 📝 Checklist de Inicio

Antes de empezar a trabajar en CustomerApp:

### **Preparación**
- [ ] Leer `NAPOLI_GUIDE.md` completo
- [ ] Leer `INTEGRATION_PLAN.md`
- [ ] Leer `NAPOLI_CUSTOMERAPP_ANALYSIS.md`
- [ ] Revisar estructura de CourierApp
- [ ] Familiarizarse con stored procedures existentes

### **Configuración**
- [ ] Verificar acceso a Supabase
- [ ] Revisar tablas existentes en BD
- [ ] Verificar RLS policies
- [ ] Configurar proyecto Flutter
- [ ] Instalar dependencias

### **Análisis**
- [ ] Identificar funcionalidades prioritarias
- [ ] Mapear flujos de usuario
- [ ] Diseñar arquitectura de datos
- [ ] Planificar stored procedures

---

## 🎯 Objetivos del Nuevo Chat

### **Tu Misión:**
Desarrollar `Napoli_CustomerApp_Mobile` siguiendo los mismos estándares de calidad y metodología usados en `CourierApp`.

### **Expectativas:**
1. **Código Limpio** - Seguir Clean Architecture
2. **Stored Procedures** - Toda lógica en BD
3. **Debugging** - Logs exhaustivos
4. **Testing** - Probar cada funcionalidad
5. **Documentación** - Actualizar guías

### **Comunicación:**
- Hacer preguntas cuando algo no esté claro
- Proponer soluciones antes de implementar
- Documentar decisiones importantes
- Reportar problemas encontrados

---

## 📞 Contacto y Soporte

Si encuentras problemas o necesitas clarificación:

1. **Revisar artifacts de CourierApp** - Muchas soluciones ya están documentadas
2. **Consultar guías de referencia** - NAPOLI_GUIDE.md, INTEGRATION_PLAN.md
3. **Verificar stored procedures existentes** - Pueden servir de ejemplo
4. **Preguntar al usuario** - Si algo no está documentado

---

## 🎓 Recursos Adicionales

### **Documentación Oficial:**
- [Flutter Docs](https://docs.flutter.dev/)
- [Supabase Docs](https://supabase.com/docs)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Flutter Bloc](https://bloclibrary.dev/)

### **Patrones de Diseño:**
- Clean Architecture
- Repository Pattern
- BLoC Pattern
- Dependency Injection

---

## ✅ Conclusión

Esta guía te proporciona todo lo necesario para continuar el desarrollo del sistema Napoli. Recuerda:

1. **Seguir la metodología** establecida
2. **Usar stored procedures** para toda la lógica
3. **Mantener Clean Architecture**
4. **Agregar logs** exhaustivos
5. **Documentar** tu trabajo

**¡Buena suerte con el desarrollo de CustomerApp!** 🚀🍕
