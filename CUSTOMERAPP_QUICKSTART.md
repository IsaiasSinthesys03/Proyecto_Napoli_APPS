# 🚀 Quick Start Guide - CustomerApp Development

## 📌 Inicio Rápido

### **Tu Tarea:**
Desarrollar `Napoli_CustomerApp_Mobile` - la aplicación móvil para clientes del sistema de delivery de pizzas.

### **Contexto:**
- ✅ **CourierApp** ya está completa y funcional
- 🔄 **CustomerApp** es tu responsabilidad
- 📊 **AdminDashboard** existe pero no es tu enfoque

---

## 📚 Documentos OBLIGATORIOS a Leer

### **Antes de Empezar:**
1. **AI_TRAINING_GUIDE.md** - Metodología completa de trabajo
2. **COURIERAPP_FINAL_STATE.md** - Estado final de CourierApp
3. **NAPOLI_CUSTOMERAPP_ANALYSIS.md** - Análisis de CustomerApp
4. **INTEGRATION_PLAN.md** - Plan de integración general

### **Durante el Desarrollo:**
- **NAPOLI_GUIDE.md** - Guía general del sistema
- Artifacts de CourierApp (en `.gemini/antigravity/brain/...`)

---

## ⚡ Reglas de Oro

### **1. STORED PROCEDURES SIEMPRE**
```dart
// ❌ NUNCA HACER ESTO
final orders = await _client.from('orders').select();

// ✅ SIEMPRE HACER ESTO
final orders = await _client.rpc('get_customer_orders', params: {
  'p_customer_id': customerId,
});
```

### **2. VERIFICAR BD PRIMERO**
```sql
-- ANTES de crear stored procedures:
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'customers';
```

### **3. LOGS EXHAUSTIVOS**
```dart
print('🔍 DEBUG - Starting operation');
print('✅ SUCCESS - Operation completed');
print('❌ ERROR - Something failed: $error');
```

### **4. CLEAN ARCHITECTURE**
```
Screen → Cubit → Repository → DataSource → Supabase
```

### **5. EITHER PARA ERRORES**
```dart
Future<Either<String, List<Order>>> getOrders() async {
  try {
    return right(orders);
  } catch (e) {
    return left('Error: $e');
  }
}
```

---

## 🎯 Prioridades de Desarrollo

### **Fase 1: Foundation (Semana 1)**
1. Authentication (Login/Register)
2. Profile Management
3. Address Management

### **Fase 2: Core Features (Semana 2)**
4. Menu Browsing
5. Cart Management
6. Order Creation

### **Fase 3: Advanced (Semana 3)**
7. Order Tracking
8. Order History
9. Realtime Updates

---

## 🗄️ Base de Datos - Tablas Clave

### **Customers (Nueva)**
```sql
CREATE TABLE customers (
  id UUID PRIMARY KEY,
  email VARCHAR NOT NULL UNIQUE,
  name VARCHAR NOT NULL,
  phone VARCHAR NOT NULL,
  photo_url VARCHAR,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **Customer Addresses (Nueva)**
```sql
CREATE TABLE customer_addresses (
  id UUID PRIMARY KEY,
  customer_id UUID REFERENCES customers(id),
  label VARCHAR,
  address TEXT NOT NULL,
  latitude NUMERIC,
  longitude NUMERIC,
  is_default BOOLEAN DEFAULT false
);
```

### **Orders (Compartida con CourierApp)**
```sql
-- Ya existe, solo necesitas adaptarla
SELECT * FROM orders WHERE customer_id = ?;
```

### **Menu Items (Ya existe)**
```sql
SELECT * FROM menu_items WHERE restaurant_id = ?;
```

---

## 🔧 Stored Procedures a Crear

### **Authentication**
```sql
CREATE FUNCTION register_customer(
  p_email TEXT,
  p_password TEXT,
  p_name TEXT,
  p_phone TEXT
) RETURNS JSON;

CREATE FUNCTION login_customer(
  p_email TEXT,
  p_password TEXT
) RETURNS JSON;
```

### **Menu**
```sql
CREATE FUNCTION get_menu_items(
  p_restaurant_id UUID,
  p_category TEXT DEFAULT NULL
) RETURNS JSON;

CREATE FUNCTION get_pizza_details(
  p_pizza_id UUID
) RETURNS JSON;
```

### **Orders**
```sql
CREATE FUNCTION create_customer_order(
  p_customer_id UUID,
  p_restaurant_id UUID,
  p_items JSONB,
  p_delivery_address_id UUID,
  p_payment_method TEXT,
  p_special_instructions TEXT DEFAULT NULL
) RETURNS JSON;

CREATE FUNCTION get_customer_orders(
  p_customer_id UUID,
  p_status TEXT DEFAULT NULL
) RETURNS JSON;

CREATE FUNCTION cancel_customer_order(
  p_order_id UUID,
  p_customer_id UUID
) RETURNS JSON;
```

### **Tracking**
```sql
CREATE FUNCTION get_order_tracking(
  p_order_id UUID,
  p_customer_id UUID
) RETURNS JSON;
```

---

## 📁 Estructura de Proyecto

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart
│   ├── di/
│   │   └── injection.dart
│   └── network/
│       └── supabase_config.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── customer.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           └── register_screen.dart
│   ├── menu/
│   ├── cart/
│   ├── orders/
│   ├── tracking/
│   └── profile/
└── main.dart
```

---

## 🎨 Patrones de Código

### **DataSource Pattern**
```dart
class MenuRemoteDataSource {
  final SupabaseClient _client;
  
  MenuRemoteDataSource(this._client);
  
  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    print('🔍 DEBUG - Getting menu for restaurant: $restaurantId');
    
    final response = await _client.rpc('get_menu_items', params: {
      'p_restaurant_id': restaurantId,
    });
    
    print('✅ Response: $response');
    
    return (response as List)
      .map((json) => MenuItem.fromJson(json))
      .toList();
  }
}
```

### **Repository Pattern**
```dart
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource _dataSource;
  
  MenuRepositoryImpl(this._dataSource);
  
  @override
  Future<Either<String, List<MenuItem>>> getMenuItems(String restaurantId) async {
    try {
      final items = await _dataSource.getMenuItems(restaurantId);
      return right(items);
    } catch (e) {
      return left('Error al cargar menú: $e');
    }
  }
}
```

### **Cubit Pattern**
```dart
class MenuCubit extends Cubit<MenuState> {
  final MenuRepository _repository;
  
  MenuCubit({required MenuRepository repository})
      : _repository = repository,
        super(const MenuInitial());
  
  Future<void> loadMenu(String restaurantId) async {
    emit(const MenuLoading());
    
    final result = await _repository.getMenuItems(restaurantId);
    
    result.fold(
      (error) => emit(MenuError(error)),
      (items) => emit(MenuLoaded(items)),
    );
  }
}
```

---

## ⚠️ Errores Comunes a Evitar

### **1. No Verificar Estructura de BD**
```sql
-- ✅ SIEMPRE hacer esto primero
SELECT * FROM customers LIMIT 1;
```

### **2. Parsear JSON sin Verificar Tipo**
```dart
// ❌ INCORRECTO
final items = (response as List).map(...);

// ✅ CORRECTO
if (response is List) {
  final items = response.map(...);
} else {
  throw Exception('Unexpected response type');
}
```

### **3. Olvidar SECURITY DEFINER**
```sql
-- ✅ SIEMPRE incluir esto
CREATE FUNCTION my_function(...)
SECURITY DEFINER  -- ← Importante!
AS $$
...
$$;
```

### **4. No Manejar Errores**
```dart
// ❌ INCORRECTO
final orders = await getOrders();

// ✅ CORRECTO
final result = await getOrders();
result.fold(
  (error) => print('Error: $error'),
  (orders) => print('Success: ${orders.length} orders'),
);
```

---

## 🔍 Debugging Checklist

Cuando algo no funciona:

1. ✅ ¿El stored procedure existe?
   ```sql
   SELECT routine_name FROM information_schema.routines;
   ```

2. ✅ ¿Los parámetros son correctos?
   ```sql
   SELECT parameter_name, data_type 
   FROM information_schema.parameters 
   WHERE routine_name = 'my_function';
   ```

3. ✅ ¿RLS está configurado?
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'customers';
   ```

4. ✅ ¿Los logs muestran algo?
   ```dart
   print('🔍 DEBUG - ...');
   ```

5. ✅ ¿El JSON se parsea correctamente?
   ```dart
   print('📦 Raw response: $response');
   ```

---

## 📞 Cuando Necesites Ayuda

### **Revisa Primero:**
1. CourierApp artifacts (`.gemini/antigravity/brain/...`)
2. COURIERAPP_FINAL_STATE.md
3. AI_TRAINING_GUIDE.md

### **Pregunta al Usuario:**
- Estructura de BD no documentada
- Decisiones de diseño
- Prioridades de funcionalidades

---

## ✅ Checklist de Inicio

Antes de escribir código:

- [ ] Leí AI_TRAINING_GUIDE.md
- [ ] Leí COURIERAPP_FINAL_STATE.md
- [ ] Leí NAPOLI_CUSTOMERAPP_ANALYSIS.md
- [ ] Revisé estructura de CourierApp
- [ ] Verifiqué acceso a Supabase
- [ ] Entendí la metodología de stored procedures

---

## 🎯 Tu Objetivo

**Desarrollar CustomerApp con la misma calidad que CourierApp:**
- ✅ Clean Architecture
- ✅ Stored Procedures
- ✅ Debugging exhaustivo
- ✅ Error handling con Either
- ✅ Código limpio y documentado

---

## 🚀 ¡Comienza Ahora!

1. Lee los documentos obligatorios
2. Verifica estructura de BD
3. Crea tu primer stored procedure
4. Implementa Authentication
5. Sigue el patrón de CourierApp

**¡Buena suerte! 🍕**
