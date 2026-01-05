# Análisis Profundo: Napoli_CourierApp_Mobile

> **Documento de Análisis Técnico Completo**  
> Versión: 1.0  
> Fecha: Enero 2026  
> Proyecto: Aplicación Móvil para Repartidores de Napoli Pizzería

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
3. [Stack Tecnológico](#stack-tecnológico)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Integración con Base de Datos](#integración-con-base-de-datos)
6. [Modelos de Datos](#modelos-de-datos)
7. [Lógica de Negocio](#lógica-de-negocio)
8. [Flujos de Funcionalidad](#flujos-de-funcionalidad)
9. [Manejo de Errores y Resiliencia](#manejo-de-errores-y-resiliencia)
10. [Seguridad](#seguridad)
11. [Conclusiones y Recomendaciones](#conclusiones-y-recomendaciones)

---

## 1. Resumen Ejecutivo

### 1.1 Descripción General

**Napoli_CourierApp_Mobile** es una aplicación móvil desarrollada en Flutter para repartidores de Napoli Pizzería. La aplicación permite a los conductores gestionar entregas de pedidos en tiempo real, desde la aceptación hasta la entrega final.

### 1.2 Características Principales

- ✅ **Autenticación segura** con Supabase Auth
- ✅ **Gestión de pedidos** en tiempo real
- ✅ **Perfil de conductor** con estadísticas
- ✅ **Historial de entregas** con filtros por período
- ✅ **Actualización de estado** de pedidos (Aceptar → Recoger → Entregar)
- ✅ **Integración completa** con stored procedures de PostgreSQL
- ✅ **Manejo robusto de errores** con múltiples estrategias de fallback

### 1.3 Estado del Proyecto

- **Estado**: ✅ Completamente funcional
- **Arquitectura**: Clean Architecture implementada
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Patrón de Estado**: BLoC (Business Logic Component)
- **Inyección de Dependencias**: GetIt

---

## 2. Arquitectura del Proyecto

### 2.1 Clean Architecture

El proyecto sigue estrictamente los principios de **Clean Architecture**, dividiendo el código en tres capas principales:

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (UI, Screens, Widgets, Cubits)         │
│  - Maneja la interfaz de usuario        │
│  - Gestiona estados con BLoC            │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│          DOMAIN LAYER                   │
│  (Entities, Use Cases, Repositories)    │
│  - Lógica de negocio pura               │
│  - Independiente de frameworks          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│           DATA LAYER                    │
│  (Data Sources, Models, Repositories)   │
│  - Implementación de repositorios       │
│  - Comunicación con Supabase            │
└─────────────────────────────────────────┘
```

### 2.2 Ventajas de esta Arquitectura

1. **Separación de Responsabilidades**: Cada capa tiene un propósito específico
2. **Testabilidad**: Fácil de escribir tests unitarios y de integración
3. **Mantenibilidad**: Cambios en una capa no afectan a las demás
4. **Escalabilidad**: Fácil agregar nuevas funcionalidades
5. **Independencia de Framework**: La lógica de negocio no depende de Flutter

### 2.3 Patrón BLoC (Business Logic Component)

```dart
// Ejemplo de flujo BLoC
User Action → Event → Cubit → Use Case → Repository → Data Source
                ↓
            State Update → UI Rebuild
```

**Cubits implementados**:
- `AuthCubit`: Maneja autenticación y sesión
- `DashboardCubit`: Gestiona dashboard y estado online
- `OrdersCubit`: Administra pedidos disponibles y activos
- `HistoryCubit`: Controla historial de entregas
- `ProfileCubit`: Gestiona perfil y configuraciones

---

## 3. Stack Tecnológico

### 3.1 Frontend (Flutter)

| Categoría | Paquete | Versión | Propósito |
|-----------|---------|---------|-----------|
| **Framework** | Flutter SDK | 3.9.2+ | Framework principal |
| **Estado** | flutter_bloc | 8.1.6 | Gestión de estado |
| **Navegación** | go_router | 14.2.0 | Enrutamiento declarativo |
| **DI** | get_it | 7.7.0 | Inyección de dependencias |
| **DI Code Gen** | injectable | 2.4.2 | Generación de código DI |
| **Backend** | supabase_flutter | 2.9.0 | Cliente Supabase |
| **Persistencia** | shared_preferences | 2.2.2 | Almacenamiento local |
| **Serialización** | json_annotation | 4.9.0 | Serialización JSON |
| **Funcional** | fpdart | 1.1.0 | Programación funcional |
| **Utilidades** | equatable | 2.0.5 | Comparación de objetos |
| **Utilidades** | intl | 0.19.0 | Internacionalización |
| **Externos** | url_launcher | 6.2.5 | Abrir URLs/teléfonos |
| **Externos** | image_picker | 1.0.7 | Selección de imágenes |

### 3.2 Backend (Supabase)

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| **Base de Datos** | PostgreSQL 14+ | Almacenamiento principal |
| **Autenticación** | Supabase Auth | JWT + Email/Password |
| **Storage** | Supabase Storage | Fotos de perfil |
| **API** | PostgREST | API REST automática |
| **Realtime** | Supabase Realtime | Actualizaciones en tiempo real (futuro) |

### 3.3 Herramientas de Desarrollo

- **Code Generation**: build_runner, json_serializable
- **Testing**: mocktail, flutter_test
- **Linting**: flutter_lints 5.0.0

---

## 4. Estructura del Proyecto

### 4.1 Organización de Carpetas

```
lib/
├── main.dart                    # Punto de entrada
├── app.dart                     # Widget raíz
├── core/                        # Funcionalidades compartidas
│   ├── config/                  # Configuraciones
│   │   └── app_config.dart      # IDs de restaurante, etc.
│   ├── di/                      # Dependency Injection
│   │   └── injection.dart       # Configuración GetIt
│   ├── navigation/              # Navegación
│   │   ├── app_router.dart      # Rutas GoRouter
│   │   └── routes.dart          # Nombres de rutas
│   ├── network/                 # Configuración de red
│   │   └── supabase_config.dart # Inicialización Supabase
│   ├── services/                # Servicios globales
│   │   ├── phone_service.dart   # Llamadas telefónicas
│   │   └── navigation_service.dart
│   ├── theme/                   # Tema de la app
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   └── widgets/                 # Widgets reutilizables
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── ...
│
└── features/                    # Módulos por funcionalidad
    ├── auth/                    # Autenticación
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_remote_datasource.dart
    │   │   │   └── mock_auth_datasource.dart
    │   │   ├── models/
    │   │   │   └── driver_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── driver.dart
    │   │   │   ├── driver_status.dart
    │   │   │   └── vehicle_type.dart
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart
    │   │   └── usecases/
    │   │       ├── login_usecase.dart
    │   │       └── register_usecase.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── auth_cubit.dart
    │       │   └── auth_state.dart
    │       └── screens/
    │           ├── login_screen.dart
    │           └── register_screen.dart
    │
    ├── dashboard/               # Dashboard principal
    ├── orders/                  # Gestión de pedidos
    ├── history/                 # Historial de entregas
    └── profile/                 # Perfil de conductor
```

### 4.2 Características de cada Módulo

#### 4.2.1 Auth (Autenticación)

**Responsabilidades**:
- Login con email/password
- Registro de nuevos conductores
- Gestión de sesión
- Validación de estado del conductor

**Stored Procedures utilizados**:
- `login_driver(p_email)`: Obtiene datos del conductor al iniciar sesión
- `register_driver(...)`: Crea nuevo conductor en la BD

#### 4.2.2 Dashboard

**Responsabilidades**:
- Mostrar resumen de estadísticas del conductor
- Toggle de estado online/offline
- Navegación a otras secciones

**Características**:
- Estadísticas en tiempo real (entregas, ganancias, rating)
- Botón de estado online con animación
- Acceso rápido a pedidos disponibles

#### 4.2.3 Orders (Pedidos)

**Responsabilidades**:
- Listar pedidos disponibles
- Listar pedidos activos del conductor
- Aceptar pedidos
- Confirmar recogida
- Completar entrega
- Ver detalles de pedido

**Stored Procedures utilizados**:
- `get_available_orders(p_restaurant_id)`: Pedidos listos para asignar
- `get_driver_orders(p_driver_id, p_status)`: Pedidos del conductor
- `get_order_details(p_order_id)`: Detalles completos de un pedido
- `accept_order(p_order_id, p_driver_id)`: Aceptar pedido
- `pickup_order(p_order_id, p_driver_id)`: Confirmar recogida
- `complete_order(p_order_id, p_driver_id)`: Marcar como entregado

#### 4.2.4 History (Historial)

**Responsabilidades**:
- Mostrar historial de entregas completadas
- Filtrar por período (hoy, semana, mes)
- Mostrar resumen de ganancias

**Características**:
- Filtros por período
- Resumen de estadísticas
- Navegación a detalles de pedido

#### 4.2.5 Profile (Perfil)

**Responsabilidades**:
- Mostrar y editar información del conductor
- Cambiar foto de perfil
- Cambiar contraseña
- Configurar notificaciones
- Cerrar sesión

**Stored Procedures utilizados**:
- `get_driver_profile(p_driver_id)`: Obtener perfil completo
- `update_driver_profile(...)`: Actualizar información

---

## 5. Integración con Base de Datos

### 5.1 Arquitectura de Conexión

```
Flutter App
    ↓
Supabase Client (supabase_flutter)
    ↓
[Supabase Auth] ← JWT Token
    ↓
[PostgREST API] ← REST Calls
    ↓
[PostgreSQL] ← Stored Procedures (RPC)
```

### 5.2 Stored Procedures Implementados

#### 5.2.1 Autenticación

**`login_driver(p_email TEXT)`**
```sql
-- Propósito: Obtener datos del conductor después de autenticación
-- Retorna: JSON con datos completos del driver
-- Uso: Llamado después de signInWithPassword()
```

**`register_driver(...)`**
```sql
-- Propósito: Crear nuevo conductor en la BD
-- Parámetros:
--   - p_restaurant_id: UUID del restaurante
--   - p_name: Nombre completo
--   - p_email: Email único
--   - p_phone: Teléfono
--   - p_vehicle_type: Tipo de vehículo (moto/auto/bici)
--   - p_license_plate: Placa del vehículo
--   - p_photo_url: URL de foto (opcional)
-- Retorna: JSON con driver creado
-- Estado inicial: 'pending' (requiere aprobación admin)
```

#### 5.2.2 Perfil

**`get_driver_profile(p_driver_id UUID)`**
```sql
-- Propósito: Obtener perfil completo del conductor
-- Retorna: JSON con todos los campos del driver
-- Campos incluidos:
--   - Información personal (nombre, email, teléfono)
--   - Información del vehículo
--   - Estadísticas (entregas, rating, ganancias)
--   - Configuraciones (notificaciones, idioma)
--   - Estado (online, en entrega)
```

**`update_driver_profile(...)`**
```sql
-- Propósito: Actualizar información del conductor
-- Parámetros opcionales:
--   - p_name, p_phone, p_vehicle_type, p_license_plate
--   - p_photo_url
--   - p_notifications_enabled
--   - p_email_notifications_enabled
--   - p_preferred_language
-- Retorna: JSON con driver actualizado
-- Nota: Solo actualiza campos no nulos
```

#### 5.2.3 Pedidos

**`get_available_orders(p_restaurant_id UUID)`**
```sql
-- Propósito: Obtener pedidos disponibles para asignar
-- Filtros:
--   - status IN ('ready', 'processing')
--   - driver_id IS NULL
--   - restaurant_id = p_restaurant_id
-- Orden: created_at DESC (más recientes primero)
-- Retorna: Array de JSON con pedidos
```

**`get_driver_orders(p_driver_id UUID, p_status TEXT)`**
```sql
-- Propósito: Obtener pedidos del conductor
-- Parámetros:
--   - p_driver_id: UUID del conductor
--   - p_status: Filtro de estado (opcional)
-- Retorna: Array de JSON con pedidos
-- Incluye: Items del pedido, datos del cliente, dirección
```

**`get_order_details(p_order_id UUID)`**
```sql
-- Propósito: Obtener detalles completos de un pedido
-- Retorna: JSON con:
--   - Información del pedido
--   - Items con productos
--   - Datos del cliente (nombre, teléfono)
--   - Dirección de entrega (calle, coordenadas)
--   - Montos (subtotal, delivery, total)
--   - Timestamps (created, accepted, picked_up, delivered)
```

**`accept_order(p_order_id UUID, p_driver_id UUID)`**
```sql
-- Propósito: Aceptar un pedido disponible
-- Validaciones:
--   - Pedido existe y está en status 'ready'
--   - driver_id IS NULL (no asignado)
-- Acciones:
--   - UPDATE orders SET driver_id, status='accepted', accepted_at=NOW()
-- Retorna: JSON con pedido actualizado
-- Error: 'Pedido no disponible' si ya fue tomado
```

**`pickup_order(p_order_id UUID, p_driver_id UUID)`**
```sql
-- Propósito: Confirmar recogida del pedido en restaurante
-- Validaciones:
--   - Pedido pertenece al conductor
--   - Status = 'accepted'
-- Acciones:
--   - UPDATE orders SET status='delivering', picked_up_at=NOW()
-- Retorna: JSON con pedido actualizado
```

**`complete_order(p_order_id UUID, p_driver_id UUID)`**
```sql
-- Propósito: Marcar pedido como entregado
-- Validaciones:
--   - Pedido pertenece al conductor
--   - Status = 'delivering'
-- Acciones:
--   1. UPDATE orders SET status='delivered', delivered_at=NOW()
--   2. INSERT INTO driver_earnings (registro de ganancia)
--   3. UPDATE drivers SET total_earnings_cents += delivery_fee
-- Retorna: JSON con pedido actualizado
-- Nota: Actualiza estadísticas del conductor automáticamente
```

### 5.3 Estrategias de Fallback

El datasource de pedidos implementa **múltiples estrategias de fallback** para garantizar robustez:

```dart
// Estrategia 1: Query directa a tabla
try {
  final result = await _client
    .from('orders')
    .select('*, customers:customer_id(*)')
    .eq('driver_id', driverId);
  if (result.isNotEmpty) return parseOrders(result);
} catch (e) {
  // Continuar a fallback
}

// Estrategia 2: RPC con filtro de estado
try {
  final result = await _client.rpc(
    'get_driver_orders',
    params: {'p_driver_id': driverId, 'p_status': 'accepted'}
  );
  if (result.isNotEmpty) return parseOrders(result);
} catch (e) {
  // Continuar a fallback
}

// Estrategia 3: RPC sin filtro + filtrado local
try {
  final result = await _client.rpc(
    'get_driver_orders',
    params: {'p_driver_id': driverId, 'p_status': null}
  );
  return filterLocally(result, ['accepted', 'delivering']);
} catch (e) {
  return []; // Retornar vacío en lugar de error
}
```

**Ventajas**:
- ✅ Resiliencia ante cambios en la BD
- ✅ Compatibilidad con diferentes versiones de stored procedures
- ✅ Degradación elegante (graceful degradation)
- ✅ No rompe la UI si falla una estrategia

### 5.4 Manejo de Datos Incompletos

```dart
// Si falta customer_id, buscarlo
if (json['customer_id'] == null && json['id'] != null) {
  final orderSimple = await _client
    .from('orders')
    .select('customer_id')
    .eq('id', json['id'])
    .maybeSingle();
  if (orderSimple != null) {
    json['customer_id'] = orderSimple['customer_id'];
  }
}

// Si falta customer data, buscarlo
if (json['customers'] == null && json['customer_id'] != null) {
  final customerData = await _client
    .from('customers')
    .select()
    .eq('id', json['customer_id'])
    .maybeSingle();
  if (customerData != null) {
    json['customers'] = customerData;
  }
}

// Si el teléfono sigue vacío, obtener detalles completos
if (order.customerPhone.isEmpty) {
  final fullOrder = await getOrderDetails(order.id);
  if (fullOrder.customerPhone.isNotEmpty) {
    order = fullOrder;
  }
}
```

### 5.5 Esquema de Base de Datos Completo

La aplicación se integra con dos tablas principales de PostgreSQL que gestionan toda la información de los conductores y sus ganancias.

#### 5.5.1 Tabla `drivers`

**Propósito**: Almacena toda la información de los conductores, desde datos personales hasta estadísticas de rendimiento.

**Estructura completa** (37 campos):

```sql
CREATE TABLE public.drivers (
  -- Identificadores
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id UUID NOT NULL REFERENCES restaurants(id),
  
  -- Información Personal
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  photo_url TEXT,
  
  -- Información del Vehículo
  vehicle_type VARCHAR(50) NOT NULL,        -- 'moto', 'auto', 'bici'
  vehicle_brand VARCHAR(100),               -- Marca del vehículo
  vehicle_model VARCHAR(100),               -- Modelo del vehículo
  vehicle_color VARCHAR(50),                -- Color del vehículo
  vehicle_year INTEGER,                     -- Año del vehículo
  license_plate VARCHAR(20) NOT NULL,       -- Placa única
  
  -- Documentación (URLs a Supabase Storage)
  id_document_url TEXT,                     -- Documento de identidad
  license_url TEXT,                         -- Licencia de conducir
  vehicle_registration_url TEXT,            -- Registro del vehículo
  insurance_url TEXT,                       -- Seguro del vehículo
  
  -- Estado y Disponibilidad
  status VARCHAR(20) DEFAULT 'pending',     -- 'pending', 'approved', 'active', 'inactive'
  is_online BOOLEAN DEFAULT false,          -- ¿Disponible para pedidos?
  is_on_delivery BOOLEAN DEFAULT false,     -- ¿En una entrega actualmente?
  
  -- Ubicación en Tiempo Real
  current_latitude DECIMAL(10, 8),          -- Última latitud conocida
  current_longitude DECIMAL(11, 8),         -- Última longitud conocida
  last_location_update TIMESTAMP,           -- Última actualización de ubicación
  
  -- Configuraciones
  notifications_enabled BOOLEAN DEFAULT true,
  email_notifications_enabled BOOLEAN DEFAULT true,
  preferred_language VARCHAR(5) DEFAULT 'es',
  fcm_token TEXT,                           -- Token para push notifications
  max_concurrent_orders INTEGER DEFAULT 2,  -- Máximo de pedidos simultáneos
  
  -- Estadísticas de Rendimiento
  total_deliveries INTEGER DEFAULT 0,       -- Total de entregas completadas
  total_earnings_cents INTEGER DEFAULT 0,   -- Ganancias totales en centavos
  rating_sum INTEGER DEFAULT 0,             -- Suma de ratings (para cálculo)
  rating_count INTEGER DEFAULT 0,           -- Cantidad de ratings recibidos
  average_rating DECIMAL(3, 2) DEFAULT 0.0, -- Rating promedio (0.0 - 5.0)
  average_delivery_minutes INTEGER,         -- Tiempo promedio de entrega
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  approved_at TIMESTAMP,                    -- Fecha de aprobación por admin
  last_delivery_at TIMESTAMP                -- Última entrega realizada
);

-- Índices para optimización
CREATE INDEX idx_drivers_restaurant_id ON drivers(restaurant_id);
CREATE INDEX idx_drivers_email ON drivers(email);
CREATE INDEX idx_drivers_status ON drivers(status);
CREATE INDEX idx_drivers_is_online ON drivers(is_online);
CREATE INDEX idx_drivers_location ON drivers(current_latitude, current_longitude);
```

**Ejemplo de registro real** (del script SQL):

```sql
{
  "id": "792b8aa0-c10a-411d-973f-e0434b303f9a",
  "restaurant_id": "06a5284c-0ef8-4efe-a882-ce1fc8319452",
  "name": "Braulio Isaías Bernal Padrón",
  "email": "braulioisaiasbernalpadron@gmail.com",
  "phone": "9992727810",
  "photo_url": null,
  "vehicle_type": "moto",
  "vehicle_brand": null,
  "vehicle_model": null,
  "vehicle_color": null,
  "vehicle_year": null,
  "license_plate": "ABC123",
  "status": "active",
  "is_online": false,
  "is_on_delivery": false,
  "notifications_enabled": false,
  "email_notifications_enabled": true,
  "preferred_language": "es",
  "max_concurrent_orders": 2,
  "total_deliveries": 10,
  "total_earnings_cents": 800,
  "rating_sum": 0,
  "rating_count": 0,
  "average_rating": 0.0,
  "created_at": "2025-12-24 03:58:14.335191+00",
  "updated_at": "2026-01-04 12:03:44.651996+00",
  "last_delivery_at": "2026-01-04 12:03:44.651996+00"
}
```

**Campos clave y su uso en la aplicación**:

| Campo | Uso en la App | Stored Procedure |
|-------|---------------|------------------|
| `id` | Identificador único del conductor | Todos los procedures |
| `restaurant_id` | Filtra pedidos del restaurante asignado | `get_available_orders` |
| `name`, `email`, `phone` | Perfil del conductor | `get_driver_profile` |
| `photo_url` | Avatar en dashboard y perfil | `update_driver_profile` |
| `vehicle_type`, `license_plate` | Información del vehículo | `get_driver_profile` |
| `status` | Control de acceso (solo 'active' puede trabajar) | `login_driver` |
| `is_online` | Disponibilidad para recibir pedidos | Toggle en dashboard |
| `is_on_delivery` | Indica si está en una entrega activa | Actualizado automáticamente |
| `current_latitude`, `current_longitude` | Tracking en tiempo real (futuro) | No implementado aún |
| `notifications_enabled` | Configuración de notificaciones | `update_driver_profile` |
| `fcm_token` | Push notifications (futuro) | No implementado aún |
| `max_concurrent_orders` | Límite de pedidos simultáneos | Validación en `accept_order` |
| `total_deliveries` | Estadística en dashboard | Incrementado en `complete_order` |
| `total_earnings_cents` | Ganancias totales mostradas en perfil | Incrementado en `complete_order` |
| `average_rating` | Rating del conductor | No implementado aún |
| `last_delivery_at` | Última actividad | Actualizado en `complete_order` |

#### 5.5.2 Tabla `driver_earnings`

**Propósito**: Registra cada ganancia individual del conductor por entrega completada, permitiendo auditoría y reportes detallados.

**Estructura**:

```sql
CREATE TABLE public.driver_earnings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES restaurants(id),
  order_id UUID NOT NULL REFERENCES orders(id),
  amount_cents INTEGER NOT NULL,            -- Monto ganado en centavos
  type VARCHAR(50) DEFAULT 'delivery',      -- Tipo de ganancia
  description TEXT,                         -- Descripción opcional
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_driver_earnings_driver_id ON driver_earnings(driver_id);
CREATE INDEX idx_driver_earnings_order_id ON driver_earnings(order_id);
CREATE INDEX idx_driver_earnings_created_at ON driver_earnings(created_at);
```

**Ejemplo de registros reales** (del script SQL):

```sql
-- Ganancia de $2.00 (200 centavos)
{
  "id": "02a6a0d8-61d0-4e31-8fe8-847f49d4fa94",
  "driver_id": "792b8aa0-c10a-411d-973f-e0434b303f9a",
  "restaurant_id": "06a5284c-0ef8-4efe-a882-ce1fc8319452",
  "order_id": "7a2f2d8f-1505-41c2-86a5-1cfd72a269d7",
  "amount_cents": 200,
  "type": "delivery",
  "description": null,
  "created_at": "2025-12-24 08:00:38.708531+00"
}

-- Ganancia de $0 (pedido sin costo de envío)
{
  "id": "039d20a8-6ad6-419d-ab42-4e8ea4afc873",
  "driver_id": "792b8aa0-c10a-411d-973f-e0434b303f9a",
  "restaurant_id": "06a5284c-0ef8-4efe-a882-ce1fc8319452",
  "order_id": "ca9b7b6a-d916-4896-9240-aaa45860db02",
  "amount_cents": 0,
  "type": "delivery",
  "description": null,
  "created_at": "2026-01-04 12:03:04.298021+00"
}
```

**Integración con `complete_order` Stored Procedure**:

```sql
CREATE OR REPLACE FUNCTION complete_order(
  p_order_id UUID,
  p_driver_id UUID
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result json;
  v_restaurant_id UUID;
  v_driver_earnings_cents INT;
BEGIN
  -- 1. Validar que el pedido pertenece al driver
  IF NOT EXISTS (
    SELECT 1 FROM orders 
    WHERE id = p_order_id 
      AND driver_id = p_driver_id
      AND status = 'delivering'
  ) THEN
    RAISE EXCEPTION 'Pedido no válido para completar';
  END IF;
  
  -- 2. Obtener restaurant_id y earnings del pedido
  SELECT 
    restaurant_id,
    delivery_fee_cents
  INTO 
    v_restaurant_id,
    v_driver_earnings_cents
  FROM orders
  WHERE id = p_order_id;
  
  -- 3. Actualizar pedido a delivered
  UPDATE orders
  SET 
    status = 'delivered',
    delivered_at = NOW()
  WHERE id = p_order_id;
  
  -- 4. ⭐ INSERTAR REGISTRO EN driver_earnings
  INSERT INTO driver_earnings (
    id,
    driver_id,
    restaurant_id,
    order_id,
    amount_cents,
    created_at
  ) VALUES (
    gen_random_uuid(),
    p_driver_id,
    v_restaurant_id,
    p_order_id,
    v_driver_earnings_cents,
    NOW()
  );
  
  -- 5. ⭐ ACTUALIZAR TOTAL EN drivers
  UPDATE drivers
  SET 
    total_earnings_cents = COALESCE(total_earnings_cents, 0) + v_driver_earnings_cents,
    total_deliveries = COALESCE(total_deliveries, 0) + 1,
    last_delivery_at = NOW(),
    updated_at = NOW()
  WHERE id = p_driver_id;
  
  -- 6. Retornar pedido actualizado
  SELECT json_build_object(
    'id', o.id::text,
    'order_number', o.order_number,
    'status', o.status::text,
    'delivered_at', o.delivered_at::text
    -- ... más campos
  ) INTO v_result
  FROM orders o
  WHERE o.id = p_order_id;
  
  RETURN v_result;
END;
$$;
```

**Flujo completo de ganancias**:

```
1. Conductor completa entrega
   ↓
2. App llama complete_order(order_id, driver_id)
   ↓
3. Stored Procedure:
   a. Valida que pedido pertenece al conductor
   b. Obtiene delivery_fee_cents del pedido
   c. Marca pedido como 'delivered'
   d. ⭐ Inserta registro en driver_earnings
   e. ⭐ Actualiza total_earnings_cents en drivers
   f. Incrementa total_deliveries
   g. Actualiza last_delivery_at
   ↓
4. App actualiza UI con nuevas estadísticas
```

**Consultas útiles para reportes**:

```sql
-- Ganancias del conductor por día
SELECT 
  DATE(created_at) as date,
  COUNT(*) as deliveries,
  SUM(amount_cents) / 100.0 as total_earnings
FROM driver_earnings
WHERE driver_id = 'driver-uuid'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Ganancias por restaurante
SELECT 
  r.name as restaurant_name,
  COUNT(*) as deliveries,
  SUM(de.amount_cents) / 100.0 as total_earnings
FROM driver_earnings de
JOIN restaurants r ON de.restaurant_id = r.id
WHERE de.driver_id = 'driver-uuid'
GROUP BY r.name;

-- Top conductores por ganancias
SELECT 
  d.name,
  d.total_deliveries,
  d.total_earnings_cents / 100.0 as total_earnings,
  d.average_rating
FROM drivers d
WHERE d.status = 'active'
ORDER BY d.total_earnings_cents DESC
LIMIT 10;
```

**Ventajas de este diseño**:

1. ✅ **Auditoría completa**: Cada ganancia queda registrada individualmente
2. ✅ **Reportes flexibles**: Fácil generar reportes por período, restaurante, etc.
3. ✅ **Integridad referencial**: Relaciones con drivers, restaurants y orders
4. ✅ **Performance**: Campo desnormalizado `total_earnings_cents` en drivers para acceso rápido
5. ✅ **Escalabilidad**: Índices optimizados para queries frecuentes
6. ✅ **Trazabilidad**: Timestamp de cada ganancia para análisis temporal

**Limitaciones actuales**:

- ⚠️ No hay sistema de comisiones (conductor recibe 100% del delivery_fee)
- ⚠️ No hay bonificaciones o penalizaciones
- ⚠️ No hay sistema de pagos/retiros implementado
- ⚠️ El campo `type` solo usa 'delivery', podría expandirse a 'bonus', 'tip', etc.

---

## 6. Modelos de Datos

### 6.1 Driver (Conductor)

```dart
class Driver extends Equatable {
  final String id;                    // UUID
  final String restaurantId;          // UUID del restaurante asignado
  final String name;                  // Nombre completo
  final String email;                 // Email único
  final String phone;                 // Teléfono de contacto
  final String? photoUrl;             // URL de foto de perfil
  final VehicleType vehicleType;      // Tipo de vehículo
  final String licensePlate;          // Placa del vehículo
  final DriverStatus status;          // Estado del conductor
  final bool isOnline;                // ¿Está disponible para pedidos?
  final bool isOnDelivery;            // ¿Está en una entrega?
  final DateTime createdAt;           // Fecha de registro
  final int totalDeliveries;          // Total de entregas realizadas
  final double averageRating;         // Rating promedio (0.0 - 5.0)
  final int totalEarningsCents;       // Ganancias totales en centavos
}
```

**Enums relacionados**:

```dart
enum VehicleType {
  moto,   // Motocicleta
  auto,   // Automóvil
  bici    // Bicicleta
}

enum DriverStatus {
  pending,   // Pendiente de aprobación
  approved,  // Aprobado por admin
  active,    // Activo (puede trabajar)
  inactive   // Inactivo (suspendido)
}
```

### 6.2 Order (Pedido)

```dart
class Order extends Equatable {
  final String id;                       // UUID
  final String orderNumber;              // Número de orden (#1001)
  final String customerName;             // Nombre del cliente
  final String customerPhone;            // Teléfono del cliente
  final DeliveryAddress deliveryAddress; // Dirección de entrega
  final List<OrderItem> items;           // Items del pedido
  final double subtotal;                 // Subtotal (sin delivery)
  final double deliveryFee;              // Costo de envío
  final double total;                    // Total a pagar
  final double driverEarnings;           // Ganancia del conductor
  final double distanceKm;               // Distancia en km
  final OrderStatus status;              // Estado del pedido
  final DateTime createdAt;              // Fecha de creación
  final DateTime? acceptedAt;            // Fecha de aceptación
  final DateTime? pickedUpAt;            // Fecha de recogida
  final DateTime? deliveredAt;           // Fecha de entrega
}
```

**Enums relacionados**:

```dart
enum OrderStatus {
  ready,      // Listo para asignar (pending/processing/ready en BD)
  accepted,   // Aceptado por conductor
  delivering, // En camino (picked_up en BD)
  delivered,  // Entregado
  cancelled   // Cancelado
}
```

### 6.3 OrderItem (Item de Pedido)

```dart
class OrderItem extends Equatable {
  final String name;        // Nombre del producto
  final int quantity;       // Cantidad
  final double price;       // Precio unitario
  final String? notes;      // Notas especiales (ej: "Sin cebolla")
}
```

### 6.4 DeliveryAddress (Dirección de Entrega)

```dart
class DeliveryAddress extends Equatable {
  final String street;      // Calle y número
  final String? details;    // Detalles (piso, depto)
  final String? notes;      // Notas de entrega
  final double latitude;    // Latitud (para mapas)
  final double longitude;   // Longitud (para mapas)
}
```

### 6.5 DriverProfile (Perfil Completo)

```dart
class DriverProfile extends Equatable {
  final Driver driver;                      // Datos del conductor
  final bool notificationsEnabled;          // Notificaciones push
  final bool emailNotificationsEnabled;     // Notificaciones email
  final String language;                    // Idioma preferido
  final String appVersion;                  // Versión de la app
}
```

---

## 7. Lógica de Negocio

### 7.1 Flujo de Autenticación

```mermaid
graph TD
    A[Usuario ingresa email/password] --> B[AuthCubit.login]
    B --> C[LoginUseCase]
    C --> D[AuthRepository]
    D --> E[AuthRemoteDataSource]
    E --> F{Supabase Auth}
    F -->|Success| G[signInWithPassword]
    G --> H[Llamar RPC: login_driver]
    H --> I{Validar status}
    I -->|pending| J[Error: Cuenta pendiente]
    I -->|approved/active| K[Guardar sesión]
    K --> L[Navegar a Dashboard]
    F -->|Error| M[Mostrar error]
```

**Validaciones**:
1. Email debe ser válido
2. Password mínimo 6 caracteres
3. Conductor debe existir en tabla `drivers`
4. Status debe ser `approved` o `active`

**Almacenamiento de sesión**:
```dart
// Guardar en SharedPreferences
await _prefs.setString('driver_id', driver.id);
await _prefs.setString('driver_email', driver.email);
await _prefs.setBool('is_logged_in', true);
```

### 7.2 Flujo de Registro

```mermaid
graph TD
    A[Usuario completa formulario] --> B[AuthCubit.register]
    B --> C[RegisterUseCase]
    C --> D[AuthRepository]
    D --> E[AuthRemoteDataSource]
    E --> F[Crear usuario en Auth]
    F --> G[Llamar RPC: register_driver]
    G --> H[Driver creado con status='pending']
    H --> I[Mostrar mensaje: Pendiente de aprobación]
```

**Validaciones**:
- Nombre: 2-100 caracteres
- Email: Formato válido, único
- Password: Mínimo 6 caracteres
- Teléfono: Formato internacional
- Tipo de vehículo: moto/auto/bici
- Placa: 3-10 caracteres, única

**Estado inicial**: `pending` (requiere aprobación del administrador)

### 7.3 Flujo de Gestión de Pedidos

#### 7.3.1 Ciclo de Vida de un Pedido

```
┌─────────────┐
│   READY     │ ← Pedido creado por cliente
└──────┬──────┘
       │ accept_order()
       ▼
┌─────────────┐
│  ACCEPTED   │ ← Conductor acepta pedido
└──────┬──────┘
       │ pickup_order()
       ▼
┌─────────────┐
│ DELIVERING  │ ← Conductor recoge pedido
└──────┬──────┘
       │ complete_order()
       ▼
┌─────────────┐
│  DELIVERED  │ ← Entrega completada
└─────────────┘
```

#### 7.3.2 Aceptar Pedido

```dart
// 1. Usuario toca "Aceptar" en pedido disponible
onAcceptPressed() {
  ordersCubit.acceptOrder(order.id);
}

// 2. Cubit procesa
acceptOrder(String orderId) async {
  emit(OrdersLoading());
  
  final result = await repository.acceptOrder(orderId, driverId);
  
  result.fold(
    (failure) => emit(OrdersError(failure.message)),
    (order) => emit(OrderAccepted(order))
  );
}

// 3. Repository llama datasource
acceptOrder(String orderId, String driverId) async {
  try {
    final order = await dataSource.acceptOrder(orderId, driverId);
    return Right(order);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}

// 4. DataSource ejecuta RPC
acceptOrder(String orderId, String driverId) async {
  final result = await _client.rpc(
    'accept_order',
    params: {'p_order_id': orderId, 'p_driver_id': driverId}
  );
  return _orderFromJson(result);
}

// 5. Stored Procedure actualiza BD
-- Valida que pedido esté disponible
-- Asigna driver_id
-- Cambia status a 'accepted'
-- Registra accepted_at timestamp
-- Retorna pedido actualizado
```

#### 7.3.3 Confirmar Recogida

```dart
// Similar a accept, pero:
// - Valida que status = 'accepted'
// - Cambia a status = 'delivering'
// - Registra picked_up_at timestamp
```

#### 7.3.4 Completar Entrega

```dart
// Además de actualizar el pedido:
// 1. Marca status = 'delivered'
// 2. Registra delivered_at timestamp
// 3. Inserta registro en driver_earnings
// 4. Actualiza total_earnings_cents del driver
// 5. Incrementa total_deliveries del driver
```

### 7.4 Cálculo de Ganancias

```sql
-- En complete_order stored procedure:

-- 1. Obtener delivery_fee del pedido
SELECT delivery_fee_cents INTO v_driver_earnings_cents
FROM orders WHERE id = p_order_id;

-- 2. Registrar ganancia
INSERT INTO driver_earnings (
  driver_id, order_id, amount_cents
) VALUES (
  p_driver_id, p_order_id, v_driver_earnings_cents
);

-- 3. Actualizar total del driver
UPDATE drivers
SET total_earnings_cents = total_earnings_cents + v_driver_earnings_cents
WHERE id = p_driver_id;
```

**Nota**: Actualmente el conductor gana el 100% del delivery_fee. Esto puede ajustarse según el modelo de negocio.

### 7.5 Sistema de Rating

**Estado actual**: El campo `average_rating` existe en la BD pero no está implementado en la app.

**Implementación futura**:
```sql
-- Tabla ratings (sugerida)
CREATE TABLE ratings (
  id UUID PRIMARY KEY,
  order_id UUID REFERENCES orders(id),
  driver_id UUID REFERENCES drivers(id),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Trigger para actualizar average_rating
CREATE TRIGGER update_driver_rating
AFTER INSERT ON ratings
FOR EACH ROW
EXECUTE FUNCTION recalculate_driver_rating();
```

---

## 8. Flujos de Funcionalidad

### 8.1 Dashboard

**Componentes**:
- Header con foto, nombre y rating del conductor
- Toggle de estado online/offline
- Estadísticas: Entregas hoy, Ganancias hoy, Total entregas
- Botones de navegación: Pedidos Disponibles, Mis Pedidos, Historial, Perfil

**Lógica de estado online**:
```dart
toggleOnlineStatus() async {
  final newStatus = !driver.isOnline;
  
  // Actualizar en BD
  await _client
    .from('drivers')
    .update({'is_online': newStatus})
    .eq('id', driverId);
  
  // Actualizar estado local
  emit(DashboardUpdated(driver.copyWith(isOnline: newStatus)));
}
```

### 8.2 Pedidos Disponibles

**Flujo**:
1. Cargar pedidos con `get_available_orders(restaurant_id)`
2. Mostrar lista con:
   - Número de orden
   - Nombre del cliente
   - Dirección
   - Total a pagar
   - Ganancia del conductor
   - Distancia estimada
3. Al tocar un pedido → Ver detalles
4. Al tocar "Aceptar" → Ejecutar `accept_order()`
5. Navegar a "Mis Pedidos"

**Actualización automática**: Cada 30 segundos (polling) o con Supabase Realtime (futuro)

### 8.3 Mis Pedidos (Activos)

**Flujo**:
1. Cargar pedidos con `get_driver_orders(driver_id, 'accepted')`
2. Mostrar lista de pedidos en progreso
3. Para cada pedido, mostrar botón según estado:
   - `accepted` → "Confirmar Recogida"
   - `delivering` → "Completar Entrega"
4. Al completar → Actualizar lista

**Acciones**:
- Llamar al cliente (url_launcher)
- Ver en mapa (url_launcher con Google Maps)
- Ver detalles completos

### 8.4 Historial

**Filtros**:
- Hoy: `created_at >= CURRENT_DATE`
- Esta semana: `created_at >= CURRENT_DATE - INTERVAL '7 days'`
- Este mes: `created_at >= CURRENT_DATE - INTERVAL '30 days'`

**Resumen**:
```dart
class HistorySummary {
  final int totalDeliveries;
  final double totalEarnings;
  final double averageEarnings;
}
```

### 8.5 Perfil

**Secciones**:
1. **Información Personal**
   - Foto de perfil (editable)
   - Nombre (editable)
   - Email (solo lectura)
   - Teléfono (editable)

2. **Información del Vehículo**
   - Tipo (editable)
   - Placa (editable)

3. **Estadísticas**
   - Total de entregas
   - Rating promedio
   - Ganancias totales

4. **Configuraciones**
   - Notificaciones push (toggle)
   - Notificaciones email (toggle)
   - Idioma (selector)

5. **Seguridad**
   - Cambiar contraseña
   - Cerrar sesión

**Actualización de foto**:
```dart
uploadProfilePhoto(File photo) async {
  // 1. Subir a Supabase Storage
  final fileName = '${driverId}-${DateTime.now().millisecondsSinceEpoch}.jpg';
  await _client.storage.from('driver-photos').upload(fileName, photo);
  
  // 2. Obtener URL pública
  final photoUrl = _client.storage.from('driver-photos').getPublicUrl(fileName);
  
  // 3. Actualizar en BD
  await _client.rpc('update_driver_profile', params: {
    'p_driver_id': driverId,
    'p_photo_url': photoUrl
  });
}
```

---

## 9. Manejo de Errores y Resiliencia

### 9.1 Tipos de Errores

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

### 9.2 Manejo con Either (fpdart)

```dart
// Repository retorna Either<Failure, Success>
Future<Either<Failure, Order>> acceptOrder(String orderId, String driverId) async {
  try {
    final order = await dataSource.acceptOrder(orderId, driverId);
    return Right(order);
  } on PostgrestException catch (e) {
    return Left(ServerFailure(e.message));
  } on SocketException {
    return Left(NetworkFailure('Sin conexión a internet'));
  } catch (e) {
    return Left(ServerFailure('Error desconocido: $e'));
  }
}

// Cubit maneja el resultado
final result = await repository.acceptOrder(orderId, driverId);

result.fold(
  (failure) => emit(OrdersError(failure.message)),
  (order) => emit(OrderAccepted(order))
);
```

### 9.3 Estrategias de Resiliencia

#### 9.3.1 Retry con Exponential Backoff

```dart
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= maxAttempts) rethrow;
      
      final delay = initialDelay * pow(2, attempt - 1);
      await Future.delayed(delay);
    }
  }
}
```

#### 9.3.2 Fallback a Caché Local

```dart
Future<List<Order>> getActiveOrders(String driverId) async {
  try {
    // Intentar obtener de servidor
    final orders = await remoteDataSource.getActiveOrders(driverId);
    
    // Guardar en caché
    await cacheDataSource.cacheOrders(orders);
    
    return orders;
  } catch (e) {
    // Fallback a caché
    print('⚠️ Server failed, using cache');
    return await cacheDataSource.getCachedOrders();
  }
}
```

#### 9.3.3 Degradación Elegante

```dart
// Si falla obtener teléfono del cliente, no romper la UI
String customerPhone = '';
try {
  customerPhone = await getCustomerPhone(customerId);
} catch (e) {
  print('⚠️ Failed to get phone, using empty string');
  customerPhone = ''; // Valor por defecto
}

// La UI muestra "No disponible" en lugar de crashear
Text(customerPhone.isEmpty ? 'No disponible' : customerPhone)
```

### 9.4 Logging y Debugging

```dart
// Debug prints estratégicos
debugPrint('🔍 getActiveOrders: Attempting to fetch for driver: $driverId');
debugPrint('✅ Direct query returned ${response.length} orders');
debugPrint('⚠️ Direct query failed: $e. Trying RPC fallback...');
debugPrint('❌ Critical error: $e');

// Emojis para identificar rápidamente:
// 🔍 = Debug info
// ✅ = Success
// ⚠️ = Warning
// ❌ = Error
```

---

## 10. Seguridad

### 10.1 Autenticación

**Método**: JWT (JSON Web Tokens) vía Supabase Auth

```dart
// Login
final authResponse = await _client.auth.signInWithPassword(
  email: email,
  password: password,
);

// Token automáticamente incluido en headers
// Authorization: Bearer <jwt_token>
```

**Validaciones**:
- Password hasheado con bcrypt (manejado por Supabase)
- Tokens con expiración de 7 días
- Refresh tokens automáticos

### 10.2 Row Level Security (RLS)

**Políticas en PostgreSQL**:

```sql
-- Drivers solo pueden ver/editar su propio perfil
CREATE POLICY "Drivers can view own profile"
ON drivers FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Drivers can update own profile"
ON drivers FOR UPDATE
USING (auth.uid() = id);

-- Drivers solo pueden ver pedidos de su restaurante
CREATE POLICY "Drivers can view restaurant orders"
ON orders FOR SELECT
USING (
  restaurant_id IN (
    SELECT restaurant_id FROM drivers WHERE id = auth.uid()
  )
);
```

**Bypass con Stored Procedures**:
```sql
CREATE FUNCTION get_driver_profile(p_driver_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER  -- ← Ejecuta con permisos del owner, bypassing RLS
AS $$
...
$$;
```

### 10.3 Validación de Datos

**En el cliente (Flutter)**:
```dart
// Validación de email
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'El email es requerido';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Email inválido';
  }
  return null;
}

// Validación de teléfono
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'El teléfono es requerido';
  }
  if (value.length < 10) {
    return 'Teléfono debe tener al menos 10 dígitos';
  }
  return null;
}
```

**En el servidor (Stored Procedures)**:
```sql
-- Validar que el conductor pertenece al pedido
IF NOT EXISTS (
  SELECT 1 FROM orders 
  WHERE id = p_order_id 
    AND driver_id = p_driver_id
) THEN
  RAISE EXCEPTION 'No tienes permiso para completar este pedido';
END IF;
```

### 10.4 Manejo de Datos Sensibles

**SharedPreferences** (almacenamiento local):
```dart
// Solo se guarda información no sensible
await _prefs.setString('driver_id', driver.id);
await _prefs.setString('driver_email', driver.email);

// NO se guarda:
// - Passwords
// - Tokens (manejados por Supabase)
// - Información financiera
```

**Supabase Storage**:
```dart
// Fotos de perfil con permisos públicos
// Bucket: 'driver-photos'
// Policy: Public read, authenticated write
```

---

## 11. Conclusiones y Recomendaciones

### 11.1 Fortalezas del Proyecto

✅ **Arquitectura Sólida**
- Clean Architecture bien implementada
- Separación clara de responsabilidades
- Código testeable y mantenible

✅ **Integración Robusta**
- Múltiples estrategias de fallback
- Manejo elegante de errores
- Resiliencia ante fallos de red

✅ **Stored Procedures**
- Lógica de negocio centralizada en BD
- Transacciones atómicas
- Mejor performance

✅ **Seguridad**
- Autenticación JWT
- Row Level Security
- Validaciones en cliente y servidor

✅ **Experiencia de Usuario**
- UI intuitiva
- Feedback claro de estados
- Manejo de errores amigable

### 11.2 Áreas de Mejora

#### 11.2.1 Testing

**Estado actual**: Sin tests implementados

**Recomendación**:
```dart
// Unit tests para use cases
test('LoginUseCase should return Driver on success', () async {
  // Arrange
  final mockRepo = MockAuthRepository();
  final useCase = LoginUseCase(mockRepo);
  
  // Act
  final result = await useCase(email: 'test@test.com', password: '123456');
  
  // Assert
  expect(result.isRight(), true);
});

// Widget tests para screens
testWidgets('LoginScreen should show error on invalid credentials', (tester) async {
  // ...
});

// Integration tests para flujos completos
testWidgets('Complete order flow', (tester) async {
  // 1. Login
  // 2. Accept order
  // 3. Pickup order
  // 4. Complete order
  // 5. Verify earnings updated
});
```

#### 11.2.2 Realtime Updates

**Estado actual**: Polling cada 30 segundos

**Recomendación**: Implementar Supabase Realtime

```dart
// Suscribirse a cambios en pedidos
final subscription = _client
  .from('orders')
  .stream(primaryKey: ['id'])
  .eq('restaurant_id', restaurantId)
  .listen((data) {
    // Actualizar UI automáticamente
    emit(OrdersUpdated(parseOrders(data)));
  });
```

**Beneficios**:
- Actualizaciones instantáneas
- Menor consumo de batería
- Mejor experiencia de usuario

#### 11.2.3 Offline Support

**Estado actual**: Requiere conexión constante

**Recomendación**: Implementar caché local con Hive o Drift

```dart
// Guardar pedidos en caché
await hiveBox.put('active_orders', orders);

// Sincronizar cuando vuelva la conexión
if (await hasConnection()) {
  await syncPendingChanges();
}
```

#### 11.2.4 Analytics y Monitoring

**Recomendación**: Integrar Firebase Analytics y Crashlytics

```dart
// Track eventos
FirebaseAnalytics.instance.logEvent(
  name: 'order_accepted',
  parameters: {'order_id': orderId, 'driver_id': driverId}
);

// Reportar errores
FirebaseCrashlytics.instance.recordError(error, stackTrace);
```

#### 11.2.5 Push Notifications

**Estado actual**: No implementado

**Recomendación**: Firebase Cloud Messaging

```dart
// Notificar cuando hay nuevo pedido disponible
// Notificar cuando un pedido es cancelado
// Notificar cambios de estado de cuenta
```

#### 11.2.6 Internacionalización (i18n)

**Estado actual**: Textos hardcodeados en español

**Recomendación**: Usar Flutter Intl

```dart
// Antes
Text('Pedidos Disponibles')

// Después
Text(AppLocalizations.of(context).availableOrders)
```

#### 11.2.7 Performance Optimization

**Recomendaciones**:
1. **Lazy loading** en listas largas
2. **Image caching** para fotos de perfil
3. **Debouncing** en búsquedas
4. **Pagination** en historial

```dart
// Pagination
Future<List<Order>> getHistory({
  required int page,
  required int pageSize,
}) async {
  final offset = page * pageSize;
  return await _client
    .from('orders')
    .select()
    .range(offset, offset + pageSize - 1);
}
```

### 11.3 Roadmap Sugerido

#### Fase 1: Estabilización (1-2 semanas)
- [ ] Agregar tests unitarios (coverage 70%+)
- [ ] Implementar error tracking (Sentry/Crashlytics)
- [ ] Optimizar queries lentas
- [ ] Documentar APIs internas

#### Fase 2: Mejoras UX (2-3 semanas)
- [ ] Implementar Realtime updates
- [ ] Agregar push notifications
- [ ] Mejorar manejo offline
- [ ] Agregar animaciones y transiciones

#### Fase 3: Features Avanzados (3-4 semanas)
- [ ] Integración con Google Maps
- [ ] Sistema de rating funcional
- [ ] Chat con soporte
- [ ] Reportes de ganancias

#### Fase 4: Escalabilidad (2-3 semanas)
- [ ] Optimización de performance
- [ ] Caché inteligente
- [ ] Compresión de imágenes
- [ ] Lazy loading avanzado

### 11.4 Métricas de Éxito

**KPIs a monitorear**:
1. **Crash rate**: < 1%
2. **Tiempo de carga**: < 3 segundos
3. **Tasa de aceptación de pedidos**: > 80%
4. **Tiempo promedio de entrega**: Baseline + mejora continua
5. **Satisfacción del conductor**: Encuestas periódicas

### 11.5 Conclusión Final

El proyecto **Napoli_CourierApp_Mobile** es una aplicación móvil **sólida, bien arquitecturada y funcional**. La implementación de Clean Architecture, el uso de stored procedures, y las estrategias de resiliencia demuestran un alto nivel de calidad técnica.

**Puntos destacados**:
- ✅ Código limpio y mantenible
- ✅ Separación de responsabilidades
- ✅ Integración robusta con backend
- ✅ Manejo elegante de errores
- ✅ Seguridad implementada correctamente

**Próximos pasos recomendados**:
1. Implementar testing comprehensivo
2. Agregar Realtime updates
3. Mejorar soporte offline
4. Integrar analytics y monitoring

Con estas mejoras, la aplicación estará lista para **producción a gran escala** y podrá soportar cientos de conductores simultáneos con excelente performance y confiabilidad.

---

## Apéndices

### A. Comandos Útiles

```bash
# Instalar dependencias
flutter pub get

# Generar código (models, DI)
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Analizar código
flutter analyze

# Formatear código
flutter format .

# Ejecutar tests
flutter test

# Generar coverage
flutter test --coverage
```

### B. Variables de Entorno

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String defaultRestaurantId = 'YOUR_RESTAURANT_UUID';
}
```

### C. Estructura de Base de Datos

**Tablas principales**:
- `drivers`: Información de conductores
- `orders`: Pedidos
- `order_items`: Items de pedidos
- `customers`: Clientes
- `products`: Productos
- `restaurants`: Restaurantes
- `driver_earnings`: Registro de ganancias

**Stored Procedures**:
- `login_driver`
- `register_driver`
- `get_driver_profile`
- `update_driver_profile`
- `get_available_orders`
- `get_driver_orders`
- `get_order_details`
- `accept_order`
- `pickup_order`
- `complete_order`

### D. Recursos Adicionales

- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Documento generado**: Enero 2026  
**Autor**: Análisis Técnico Automatizado  
**Versión**: 1.0
