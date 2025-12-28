# 🔗 Plan de Integración - Ecosistema NAPOLI

## 📋 **Resumen Ejecutivo**

**Objetivo**: Conectar las 3 aplicaciones del ecosistema NAPOLI (AdminDashboard Web, CourierApp Mobile, CustomerApp Mobile) para que se comuniquen en tiempo real y compartan datos de manera sincronizada.

**Solución Propuesta**: Utilizar **Supabase** como backend unificado con **Realtime subscriptions** para sincronización en tiempo real.

---

## 🎯 **Estado Actual vs Estado Deseado**

### **Estado Actual**

| Aplicación | Backend Actual | Estado |
|------------|---------------|--------|
| **AdminDashboard** | ✅ Supabase (conectado) | Funcional |
| **CourierApp** | ❌ Mock DataSources | Solo UI |
| **CustomerApp** | ✅ Supabase (conectado) | Funcional |

**Problemas**:
- CourierApp NO está conectado a Supabase (usa datos mock)
- AdminDashboard y CustomerApp usan el mismo Supabase pero NO se sincronizan en tiempo real
- No hay comunicación entre las 3 apps
- Los cambios de estado de pedidos NO se propagan automáticamente

### **Estado Deseado**

```
┌─────────────────────────────────────────────────────────────┐
│                    SUPABASE (Backend Único)                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  PostgreSQL Database (schema.sql)                    │  │
│  │  - restaurants, customers, drivers, orders, etc.     │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Realtime Subscriptions                              │  │
│  │  - orders table changes                              │  │
│  │  - drivers table changes                             │  │
│  │  - notifications table                               │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Auth (Supabase Auth)                                │  │
│  │  - Customers, Drivers, Restaurant Admins             │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Storage (Supabase Storage)                          │  │
│  │  - product-images, driver-photos, etc.               │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
           ↑                    ↑                    ↑
           │                    │                    │
    ┌──────┴──────┐      ┌─────┴──────┐      ┌─────┴──────┐
    │ AdminDash   │      │ CourierApp │      │ CustomerApp│
    │ (Web)       │      │ (Mobile)   │      │ (Mobile)   │
    │ React +     │      │ Flutter +  │      │ Flutter +  │
    │ Supabase JS │      │ Supabase   │      │ Supabase   │
    └─────────────┘      └────────────┘      └────────────┘
```

---

## 🏗️ **Arquitectura de Integración**

### **1. Backend Unificado: Supabase**

**Por qué Supabase**:
- ✅ Ya está implementado en AdminDashboard y CustomerApp
- ✅ Realtime subscriptions nativas (WebSockets)
- ✅ Row Level Security (RLS) para multi-tenant
- ✅ Auth integrado
- ✅ Storage integrado
- ✅ SDK para JavaScript (Web) y Dart (Flutter)
- ✅ Open source y escalable

**Configuración**:
```
Proyecto Supabase: https://olrsqnoehkbswxcocqhq.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

### **2. Sincronización en Tiempo Real**

#### **Tablas con Realtime Habilitado**

```sql
-- Habilitar Realtime en tablas críticas
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE drivers;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE order_items;
```

#### **Flujo de Sincronización**

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUJO DE PEDIDO                          │
└─────────────────────────────────────────────────────────────┘

1. CustomerApp → Crea Order (status: pending)
   ↓ INSERT en tabla 'orders'
   ↓ Realtime broadcast
   ↓
2. AdminDashboard → Recibe notificación (nuevo pedido)
   ↓ Admin acepta pedido
   ↓ UPDATE orders SET status='accepted'
   ↓ Realtime broadcast
   ↓
3. CustomerApp → Recibe notificación (pedido aceptado)
   ↓ Admin procesa pedido
   ↓ UPDATE orders SET status='processing'
   ↓ Realtime broadcast
   ↓
4. CustomerApp → Recibe notificación (pedido en preparación)
   ↓ Admin marca como listo
   ↓ UPDATE orders SET status='ready'
   ↓ Realtime broadcast
   ↓
5. CourierApp → Recibe notificación (pedido listo para recoger)
   ↓ Driver acepta pedido
   ↓ UPDATE orders SET status='delivering', driver_id=?
   ↓ Realtime broadcast
   ↓
6. AdminDashboard + CustomerApp → Reciben notificación (en camino)
   ↓ Driver entrega pedido
   ↓ UPDATE orders SET status='delivered'
   ↓ Realtime broadcast
   ↓
7. AdminDashboard + CustomerApp → Reciben notificación (entregado)
```

---

## 🔧 **Implementación por Aplicación**

### **A. AdminDashboard (Web) - YA CONECTADO ✅**

**Estado**: Ya usa Supabase directamente

**Mejoras Necesarias**:

1. **Agregar Realtime Subscriptions**

```typescript
// src/core/services/realtime.service.ts
import { supabase, getCurrentRestaurantId } from '@/core/lib/supabaseClient';

export class RealtimeService {
  private subscriptions: Map<string, RealtimeChannel> = new Map();

  // Suscribirse a cambios en orders
  subscribeToOrders(callback: (payload: any) => void) {
    const restaurantId = await getCurrentRestaurantId();
    
    const channel = supabase
      .channel('orders-changes')
      .on(
        'postgres_changes',
        {
          event: '*', // INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'orders',
          filter: `restaurant_id=eq.${restaurantId}`,
        },
        callback
      )
      .subscribe();
    
    this.subscriptions.set('orders', channel);
  }

  // Suscribirse a cambios en drivers
  subscribeToDrivers(callback: (payload: any) => void) {
    const restaurantId = await getCurrentRestaurantId();
    
    const channel = supabase
      .channel('drivers-changes')
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'drivers',
          filter: `restaurant_id=eq.${restaurantId}`,
        },
        callback
      )
      .subscribe();
    
    this.subscriptions.set('drivers', channel);
  }

  // Desuscribirse de todos los canales
  unsubscribeAll() {
    this.subscriptions.forEach((channel) => {
      supabase.removeChannel(channel);
    });
    this.subscriptions.clear();
  }
}
```

2. **Usar en Dashboard**

```typescript
// src/pages/app/dashboard/dashboard.tsx
import { useEffect } from 'react';
import { RealtimeService } from '@/core/services/realtime.service';

export function Dashboard() {
  const queryClient = useQueryClient();
  const realtimeService = new RealtimeService();

  useEffect(() => {
    // Suscribirse a cambios en orders
    realtimeService.subscribeToOrders((payload) => {
      console.log('Order changed:', payload);
      
      // Invalidar cache de React Query para refrescar
      queryClient.invalidateQueries({ queryKey: ['orders'] });
    });

    // Cleanup
    return () => {
      realtimeService.unsubscribeAll();
    };
  }, []);

  // ... resto del componente
}
```

---

### **B. CourierApp (Mobile) - NECESITA CONEXIÓN ❌**

**Estado**: Actualmente usa Mock DataSources

**Cambios Necesarios**:

1. **Agregar Supabase al proyecto**

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.9.0
```

2. **Crear Supabase Config**

```dart
// lib/core/network/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String projectUrl = 'https://olrsqnoehkbswxcocqhq.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  
  static Future<void> initialize() async {
    await Supabase.initialize(url: projectUrl, anonKey: anonKey);
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}
```

3. **Reemplazar Mock DataSources con Supabase DataSources**

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;
  
  AuthRemoteDataSource(this._client);
  
  Future<DriverModel> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw ServerException('Login failed');
    }
    
    // Obtener datos del driver desde tabla 'drivers'
    final driverData = await _client
      .from('drivers')
      .select()
      .eq('email', email)
      .single();
    
    return DriverModel.fromJson(driverData);
  }
  
  Future<DriverModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String licensePlate,
  }) async {
    // 1. Crear usuario en Supabase Auth
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );
    
    if (authResponse.user == null) {
      throw ServerException('Registration failed');
    }
    
    // 2. Crear registro en tabla 'drivers'
    final driverData = await _client
      .from('drivers')
      .insert({
        'name': name,
        'email': email,
        'phone': phone,
        'vehicle_type': vehicleType,
        'license_plate': licensePlate,
        'status': 'pending', // Esperando aprobación
      })
      .select()
      .single();
    
    return DriverModel.fromJson(driverData);
  }
}
```

4. **Implementar Realtime para Orders**

```dart
// lib/features/orders/data/datasources/orders_remote_datasource.dart
class OrdersRemoteDataSource {
  final SupabaseClient _client;
  
  OrdersRemoteDataSource(this._client);
  
  // Obtener pedidos disponibles (status: ready)
  Future<List<OrderModel>> getAvailableOrders() async {
    final data = await _client
      .from('orders')
      .select('''
        *,
        customer:customers(*),
        order_items(*)
      ''')
      .eq('status', 'ready')
      .order('created_at', ascending: true);
    
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }
  
  // Suscribirse a cambios en orders
  Stream<List<OrderModel>> subscribeToAvailableOrders() {
    return _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('status', 'ready')
      .map((data) => data.map((json) => OrderModel.fromJson(json)).toList());
  }
  
  // Actualizar estado del pedido
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    final data = await _client
      .from('orders')
      .update({
        'status': status,
        '${status}_at': DateTime.now().toIso8601String(),
      })
      .eq('id', orderId)
      .select()
      .single();
    
    return OrderModel.fromJson(data);
  }
}
```

5. **Actualizar DI (injection.dart)**

```dart
// lib/core/di/injection.dart
@module
abstract class NetworkModule {
  @lazySingleton
  SupabaseClient get supabaseClient => SupabaseConfig.client;
}

@injectable
class AuthRemoteDataSource {
  final SupabaseClient client;
  AuthRemoteDataSource(this.client);
  // ...
}
```

---

### **C. CustomerApp (Mobile) - YA CONECTADO ✅**

**Estado**: Ya usa Supabase

**Mejoras Necesarias**:

1. **Agregar Realtime Subscriptions para Orders**

```dart
// lib/src/features/orders/data/datasources/orders_remote_datasource.dart
class OrdersRemoteDataSource {
  final SupabaseClient _client;
  
  // Suscribirse a cambios en orders del usuario
  Stream<List<OrderModel>> subscribeToMyOrders(String customerId) {
    return _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('customer_id', customerId)
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => OrderModel.fromJson(json)).toList());
  }
  
  // Suscribirse a un pedido específico
  Stream<OrderModel> subscribeToOrder(String orderId) {
    return _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', orderId)
      .map((data) => OrderModel.fromJson(data.first));
  }
}
```

2. **Usar en OrdersCubit**

```dart
// lib/src/features/orders/presentation/cubit/orders_cubit.dart
class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repository;
  StreamSubscription? _ordersSubscription;
  
  Future<void> subscribeToOrders(String customerId) async {
    emit(state.copyWith(isLoading: true));
    
    _ordersSubscription = _repository.subscribeToMyOrders(customerId).listen(
      (orders) {
        emit(OrdersLoaded(orders));
      },
      onError: (error) {
        emit(OrdersError(error.toString()));
      },
    );
  }
  
  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
```

---

## 📊 **Sincronización de Estados de Order**

### **Mapeo de Estados entre Apps**

| Estado en DB | AdminDashboard | CourierApp | CustomerApp |
|--------------|----------------|------------|-------------|
| `pending` | "Nuevo Pedido" | - | "Pendiente" |
| `accepted` | "Aceptado" | - | "Aceptado" |
| `processing` | "En Preparación" | - | "Preparando" |
| `ready` | "Listo" | "Disponible" | "Listo para Recoger" |
| `delivering` | "En Camino" | "En Entrega" | "En Camino" |
| `delivered` | "Entregado" | "Completado" | "Entregado" |
| `cancelled` | "Cancelado" | "Cancelado" | "Cancelado" |

### **Transiciones de Estado**

```typescript
// Validación de transiciones permitidas
const ALLOWED_TRANSITIONS = {
  pending: ['accepted', 'cancelled'],
  accepted: ['processing', 'cancelled'],
  processing: ['ready', 'cancelled'],
  ready: ['delivering', 'cancelled'],
  delivering: ['delivered', 'cancelled'],
  delivered: [], // Estado final
  cancelled: [], // Estado final
};
```

---

## 🔔 **Sistema de Notificaciones (Opcional - Fase 2)**

### **Push Notifications con Supabase Edge Functions**

```typescript
// supabase/functions/send-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const { orderId, status, userId, userType } = await req.json();
  
  // Obtener FCM token del usuario
  const { data: user } = await supabase
    .from(userType === 'driver' ? 'drivers' : 'customers')
    .select('fcm_token')
    .eq('id', userId)
    .single();
  
  if (!user?.fcm_token) {
    return new Response('No FCM token', { status: 400 });
  }
  
  // Enviar notificación push
  const message = getNotificationMessage(status);
  
  await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=${Deno.env.get('FCM_SERVER_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: user.fcm_token,
      notification: {
        title: 'Actualización de Pedido',
        body: message,
      },
      data: {
        orderId,
        status,
      },
    }),
  });
  
  return new Response('OK', { status: 200 });
});
```

---

## 🧪 **Plan de Testing**

### **1. Testing de Integración**

```typescript
// AdminDashboard: test/integration/realtime.test.ts
describe('Realtime Integration', () => {
  it('should receive order updates in real-time', async () => {
    const realtimeService = new RealtimeService();
    const updates: any[] = [];
    
    realtimeService.subscribeToOrders((payload) => {
      updates.push(payload);
    });
    
    // Simular cambio en order desde otra app
    await supabase.from('orders').update({ status: 'accepted' }).eq('id', testOrderId);
    
    // Esperar a recibir actualización
    await waitFor(() => expect(updates.length).toBeGreaterThan(0));
    
    expect(updates[0].new.status).toBe('accepted');
  });
});
```

### **2. Testing End-to-End**

```gherkin
Feature: Order Flow Integration
  Scenario: Customer creates order and driver delivers it
    Given a customer is logged in CustomerApp
    When the customer creates a new order
    Then AdminDashboard should receive the order notification
    
    When admin accepts the order in AdminDashboard
    Then CustomerApp should show order status as "Aceptado"
    
    When admin marks order as ready in AdminDashboard
    Then CourierApp should show the order as available
    
    When driver accepts the order in CourierApp
    Then AdminDashboard and CustomerApp should show status as "En Camino"
    
    When driver marks order as delivered in CourierApp
    Then CustomerApp should show order status as "Entregado"
```

---

## 📅 **Plan de Implementación (Fases)**

### **Fase 1: Conexión Básica (1-2 semanas)**

**Objetivo**: Conectar CourierApp a Supabase

- [ ] Agregar Supabase Flutter a CourierApp
- [ ] Crear SupabaseConfig
- [ ] Reemplazar MockAuthDataSource con AuthRemoteDataSource
- [ ] Reemplazar MockOrdersDataSource con OrdersRemoteDataSource
- [ ] Actualizar DI (injection.dart)
- [ ] Testing básico de login y obtener orders

### **Fase 2: Realtime Básico (1 semana)**

**Objetivo**: Implementar sincronización en tiempo real

- [ ] Habilitar Realtime en tablas (orders, drivers)
- [ ] Implementar RealtimeService en AdminDashboard
- [ ] Implementar Stream subscriptions en CourierApp
- [ ] Implementar Stream subscriptions en CustomerApp
- [ ] Testing de sincronización

### **Fase 3: Optimización y UX (1 semana)**

**Objetivo**: Mejorar experiencia de usuario

- [ ] Agregar indicadores de "actualizando" en UI
- [ ] Implementar optimistic updates
- [ ] Agregar sonidos/vibraciones en cambios importantes
- [ ] Implementar reconexión automática
- [ ] Testing de edge cases (sin internet, etc.)

### **Fase 4: Notificaciones Push (Opcional - 1 semana)**

**Objetivo**: Notificaciones push nativas

- [ ] Configurar Firebase Cloud Messaging
- [ ] Crear Supabase Edge Function para enviar notificaciones
- [ ] Implementar FCM en CourierApp
- [ ] Implementar FCM en CustomerApp
- [ ] Testing de notificaciones

---

## 🎯 **Métricas de Éxito**

1. **Latencia de Sincronización**: < 2 segundos
2. **Uptime de Realtime**: > 99%
3. **Tasa de Errores**: < 1%
4. **Satisfacción de Usuario**: Feedback positivo en cambios de estado
5. **Performance**: No degradación en rendimiento de apps

---

## 🚨 **Riesgos y Mitigaciones**

| Riesgo | Impacto | Probabilidad | Mitigación |
|--------|---------|--------------|------------|
| Supabase Realtime falla | Alto | Bajo | Implementar polling fallback |
| Conflictos de estado | Medio | Medio | Validar transiciones en backend |
| Latencia de red | Medio | Alto | Optimistic updates en UI |
| Costo de Supabase | Bajo | Bajo | Monitorear uso, optimizar queries |

---

## 💰 **Estimación de Costos**

**Supabase Pricing** (Plan Pro - $25/mes):
- ✅ 8 GB Database
- ✅ 100 GB Bandwidth
- ✅ 50 GB File Storage
- ✅ Realtime ilimitado
- ✅ 500,000 Edge Function invocations

**Estimación para 1 restaurante con 100 pedidos/día**:
- Database: ~500 MB/mes
- Bandwidth: ~10 GB/mes
- Storage: ~5 GB (imágenes)
- **Costo Total**: $25/mes (Plan Pro suficiente)

---

## 📚 **Documentación Adicional Necesaria**

1. **API Documentation**: Documentar todos los endpoints de Supabase
2. **Realtime Events Guide**: Guía de eventos y payloads
3. **Error Handling Guide**: Manejo de errores de conexión
4. **Deployment Guide**: Guía de despliegue y configuración
5. **Monitoring Guide**: Guía de monitoreo y alertas

---

## ✅ **Checklist de Implementación**

### **Pre-requisitos**
- [ ] Verificar que schema.sql está actualizado en Supabase
- [ ] Verificar RLS policies están configuradas
- [ ] Verificar Storage buckets están creados
- [ ] Tener credenciales de Supabase (URL, Anon Key)

### **CourierApp**
- [ ] Instalar supabase_flutter
- [ ] Crear SupabaseConfig
- [ ] Implementar AuthRemoteDataSource
- [ ] Implementar OrdersRemoteDataSource
- [ ] Implementar DashboardRemoteDataSource
- [ ] Actualizar DI
- [ ] Testing

### **AdminDashboard**
- [ ] Crear RealtimeService
- [ ] Implementar subscriptions en Dashboard
- [ ] Implementar subscriptions en Orders
- [ ] Implementar subscriptions en DeliveryMen
- [ ] Testing

### **CustomerApp**
- [ ] Implementar Stream subscriptions en OrdersCubit
- [ ] Actualizar UI para mostrar cambios en tiempo real
- [ ] Testing

---

## 🎓 **Conclusión**

Esta solución proporciona:
- ✅ **Backend unificado** con Supabase
- ✅ **Sincronización en tiempo real** con Realtime subscriptions
- ✅ **Escalabilidad** para múltiples restaurantes
- ✅ **Seguridad** con RLS y Auth
- ✅ **Bajo costo** ($25/mes por restaurante)
- ✅ **Fácil mantenimiento** (un solo backend)
- ✅ **Experiencia de usuario mejorada** (actualizaciones instantáneas)

**Próximo Paso**: Revisar y aprobar este plan para comenzar con la Fase 1.
