# 📚 NAPOLI SaaS - Guía Maestra de Sincronización

**Versión**: 4.3 | **Fuente de verdad**: `schema.sql`

---

## 🏗️ Arquitectura Multi-Tenant

```
┌─────────────────────────────────────────────────────────────────┐
│                    NAPOLI SaaS PLATFORM                         │
├─────────────────────────────────────────────────────────────────┤
│  Tenant 1 (Pizzería A)  │  Tenant 2 (Pizzería B)  │  ...       │
│  ├─ Customers           │  ├─ Customers           │            │
│  ├─ Drivers             │  ├─ Drivers             │            │
│  ├─ Orders              │  ├─ Orders              │            │
│  ├─ Products            │  ├─ Products            │            │
│  └─ Settings            │  └─ Settings            │            │
└─────────────────────────────────────────────────────────────────┘
```

**Principio clave**: Todo dato tiene `restaurant_id` para aislamiento de tenant.

---

## 📱 Las 3 Aplicaciones

| App                | Usuario           | Función Principal                               |
| ------------------ | ----------------- | ----------------------------------------------- |
| **AdminDashboard** | Dueño de pizzería | Gestionar menú, pedidos, repartidores, reportes |
| **CustomerApp**    | Cliente final     | Hacer pedidos, pagar, ver historial             |
| **CourierApp**     | Repartidor        | Ver pedidos, aceptar entregas, navegar          |

---

## 🔄 ENUMs Unificados

### OrderStatus (El más crítico)

```
pending → accepted → processing → ready → delivering → delivered
                                           ↓
                                      cancelled
```

| Valor        | Quién lo cambia | Descripción           | Timestamp       |
| ------------ | --------------- | --------------------- | --------------- |
| `pending`    | CustomerApp     | Cliente coloca pedido | `created_at`    |
| `accepted`   | AdminDashboard  | Admin acepta          | `accepted_at`   |
| `processing` | AdminDashboard  | Cocina preparando     | `processing_at` |
| `ready`      | AdminDashboard  | Listo para recoger    | `ready_at`      |
| `delivering` | CourierApp      | Repartidor en camino  | `picked_up_at`  |
| `delivered`  | CourierApp      | Entrega confirmada    | `delivered_at`  |
| `cancelled`  | Cualquiera      | Cancelado             | `cancelled_at`  |

### DriverStatus

```
pending → approved → active ↔ inactive
                        ↓
                   suspended
```

| Valor       | Descripción                    |
| ----------- | ------------------------------ |
| `pending`   | Esperando aprobación del admin |
| `approved`  | Aprobado, puede trabajar       |
| `active`    | En línea, disponible           |
| `inactive`  | Fuera de línea                 |
| `suspended` | Suspendido temporalmente       |

### CustomerStatus

`active` | `inactive` | `blocked`

### PaymentType

`card` | `cash` | `transfer` | `other`

### VehicleType

`moto` | `bici` | `auto` | `camioneta` | `otro`

### SubscriptionStatus (SaaS)

`trial` | `active` | `past_due` | `cancelled` | `expired` | `suspended`

---

## 🏪 Configuración de Restaurante (restaurants table)

### Identidad

| Campo         | Tipo         | Descripción              |
| ------------- | ------------ | ------------------------ |
| `id`          | UUID         | ID único del restaurante |
| `name`        | VARCHAR(255) | Nombre público           |
| `slug`        | VARCHAR(100) | URL slug (único)         |
| `description` | TEXT         | Descripción              |

### Branding

| Campo             | Tipo          | Descripción              |
| ----------------- | ------------- | ------------------------ |
| `logo_url`        | VARCHAR(2048) | URL del logo             |
| `banner_url`      | VARCHAR(2048) | URL del banner           |
| `primary_color`   | VARCHAR(7)    | Color primario (#RRGGBB) |
| `secondary_color` | VARCHAR(7)    | Color secundario         |

### Contacto

| Campo      | Tipo         | Descripción                |
| ---------- | ------------ | -------------------------- |
| `email`    | VARCHAR(255) | Email principal (required) |
| `phone`    | VARCHAR(50)  | Teléfono                   |
| `whatsapp` | VARCHAR(50)  | WhatsApp                   |
| `website`  | VARCHAR(500) | Sitio web                  |

### Ubicación

| Campo                      | Tipo         | Descripción                 |
| -------------------------- | ------------ | --------------------------- |
| `address`                  | VARCHAR(500) | Dirección                   |
| `city`, `state`, `country` | VARCHAR      | Ubicación                   |
| `latitude`, `longitude`    | DECIMAL      | Coordenadas                 |
| `timezone`                 | VARCHAR(50)  | Zona horaria (default: UTC) |

### Horarios (JSONB)

```json
{
  "monday": {"enabled": true, "open": "12:00", "close": "22:00"},
  "tuesday": {"enabled": false, "open": null, "close": null},
  "wednesday": {"enabled": true, "open": "12:00", "close": "22:00"},
  ...
}
```

### Configuración Regional (NO HARDCODEAR)

| Campo                    | Tipo         | Default  | Descripción          |
| ------------------------ | ------------ | -------- | -------------------- |
| `currency_code`          | VARCHAR(3)   | 'MXN'    | Código de moneda     |
| `currency_symbol`        | VARCHAR(5)   | '$'      | Símbolo              |
| `currency_position`      | VARCHAR(10)  | 'before' | 'before' o 'after'   |
| `decimal_separator`      | VARCHAR(1)   | '.'      | Separador decimal    |
| `thousands_separator`    | VARCHAR(1)   | ','      | Separador miles      |
| `decimal_places`         | INT          | 2        | Decimales a mostrar  |
| `tax_rate_percentage`    | DECIMAL(5,2) | 0.00     | IVA                  |
| `tax_included_in_prices` | BOOLEAN      | true     | Precios incluyen IVA |

### Configuración de Delivery

| Campo                           | Tipo         | Default | Descripción              |
| ------------------------------- | ------------ | ------- | ------------------------ |
| `is_open`                       | BOOLEAN      | true    | ¿Abierto ahora?          |
| `accepts_delivery`              | BOOLEAN      | true    | ¿Hace delivery?          |
| `accepts_pickup`                | BOOLEAN      | true    | ¿Permite pickup?         |
| `accepts_dine_in`               | BOOLEAN      | false   | ¿Comer en local?         |
| `delivery_radius_km`            | DECIMAL(5,2) | -       | Radio de entrega         |
| `minimum_order_cents`           | INT          | 0       | Pedido mínimo (centavos) |
| `delivery_fee_cents`            | INT          | 0       | Costo de envío fijo      |
| `delivery_fee_per_km_cents`     | INT          | 0       | Costo por km             |
| `free_delivery_threshold_cents` | INT          | -       | Envío gratis arriba de   |
| `estimated_prep_minutes`        | INT          | 30      | Tiempo preparación       |
| `estimated_delivery_minutes`    | INT          | 30      | Tiempo entrega           |

### Métodos de Pago

| Campo                | Tipo         | Default | Descripción               |
| -------------------- | ------------ | ------- | ------------------------- |
| `accepts_card`       | BOOLEAN      | true    | ¿Acepta tarjeta?          |
| `accepts_cash`       | BOOLEAN      | true    | ¿Acepta efectivo?         |
| `accepts_transfer`   | BOOLEAN      | true    | ¿Acepta transferencia?    |
| `bank_account_clabe` | VARCHAR(20)  | -       | CLABE para transferencias |
| `bank_account_name`  | VARCHAR(255) | -       | Nombre de cuenta          |
| `bank_name`          | VARCHAR(100) | -       | Banco                     |

### Comisiones Driver

| Campo                     | Tipo          | Default      | Descripción                     |
| ------------------------- | ------------- | ------------ | ------------------------------- |
| `driver_commission_type`  | VARCHAR(20)   | 'percentage' | 'percentage', 'fixed', 'per_km' |
| `driver_commission_value` | DECIMAL(10,2) | 15.00        | Valor de comisión               |

---

## 👥 Roles de Admin (restaurant_admins table)

| Rol       | Descripción              |
| --------- | ------------------------ |
| `owner`   | Dueño, acceso total      |
| `manager` | Gerente, casi todo       |
| `staff`   | Personal, pedidos y menú |
| `kitchen` | Cocina, solo pedidos     |

---

## 📦 Estructura de Order (orders table)

### IDs y Referencias

| Campo                 | Tipo        | Descripción            |
| --------------------- | ----------- | ---------------------- |
| `id`                  | UUID        | ID único               |
| `restaurant_id`       | UUID        | **REQUIRED** - Tenant  |
| `order_number`        | VARCHAR(20) | Número legible (#0001) |
| `customer_id`         | UUID        | Cliente que ordenó     |
| `driver_id`           | UUID        | Repartidor asignado    |
| `delivery_address_id` | UUID        | Dirección de entrega   |
| `coupon_id`           | UUID        | Cupón aplicado         |

### Precios (todos en centavos)

| Campo                   | Tipo | Descripción         |
| ----------------------- | ---- | ------------------- |
| `subtotal_cents`        | INT  | Subtotal productos  |
| `tax_cents`             | INT  | Impuestos           |
| `delivery_fee_cents`    | INT  | Costo de envío      |
| `tip_cents`             | INT  | Propina             |
| `discount_cents`        | INT  | Descuento (cupón)   |
| `total_cents`           | INT  | Total final         |
| `driver_earnings_cents` | INT  | Ganancia del driver |

### Snapshots (se guardan aunque se borre el original)

```json
// customer_snapshot
{"name": "Juan Pérez", "email": "juan@email.com", "phone": "+521234567890"}

// address_snapshot
{"street": "Calle 1 #123", "city": "CDMX", "lat": 19.4326, "lng": -99.1332}
```

### Tipo de Orden

| Valor      | Descripción         |
| ---------- | ------------------- |
| `delivery` | Entrega a domicilio |
| `pickup`   | Recoger en tienda   |
| `dine_in`  | Comer en local      |

### Estados de Pago (payment_status)

`pending` | `paid` | `failed` | `refunded`

### Notas

| Campo                 | Uso                                          |
| --------------------- | -------------------------------------------- |
| `customer_notes`      | "Sin cebolla, extra queso"                   |
| `kitchen_notes`       | Notas internas de cocina                     |
| `driver_notes`        | "Edificio gris, 3er piso"                    |
| `cancellation_reason` | Razón de cancelación                         |
| `cancelled_by`        | 'customer', 'restaurant', 'driver', 'system' |

### Ratings (1-5)

| Campo             | Quién califica           |
| ----------------- | ------------------------ |
| `customer_rating` | Customer → Order general |
| `driver_rating`   | Customer → Driver        |
| `food_rating`     | Customer → Comida        |

### Timestamps (Todos trackean)

| Campo           | Cuándo se llena   |
| --------------- | ----------------- |
| `created_at`    | Al crear orden    |
| `confirmed_at`  | Al confirmar pago |
| `accepted_at`   | Admin acepta      |
| `processing_at` | Cocina empieza    |
| `ready_at`      | Listo para pickup |
| `picked_up_at`  | Driver recoge     |
| `delivered_at`  | Entregado         |
| `cancelled_at`  | Cancelado         |

---

## 📊 Tablas por Proyecto

### 🖥️ AdminDashboard

#### Tablas de LECTURA + ESCRITURA

| Tabla               | Uso                                         |
| ------------------- | ------------------------------------------- |
| `restaurants`       | Mi pizzería (nombre, logo, horarios, pagos) |
| `restaurant_admins` | Usuarios admin de mi pizzería               |
| `categories`        | CRUD categorías del menú                    |
| `products`          | CRUD productos                              |
| `addons`            | CRUD extras/toppings                        |
| `promotions`        | CRUD promociones                            |
| `coupons`           | CRUD cupones                                |
| `drivers`           | Gestionar mis repartidores                  |
| `orders`            | Ver/modificar estado de pedidos             |

#### Tablas de SOLO LECTURA

| Tabla                          | Uso                    |
| ------------------------------ | ---------------------- |
| `customers`                    | Ver mis clientes       |
| `restaurant_daily_reports`     | Mis reportes de ventas |
| `restaurant_product_sales`     | Ranking de productos   |
| `restaurant_dashboard_summary` | Métricas del día/mes   |

---

### 📱 CustomerApp

#### Tablas de LECTURA + ESCRITURA

| Tabla                               | Uso                                       |
| ----------------------------------- | ----------------------------------------- |
| `customers`                         | Mi perfil (nombre, email, teléfono, foto) |
| `customer_addresses`                | Mis direcciones guardadas                 |
| `customer_payment_methods`          | Mis métodos de pago                       |
| `customer_notification_preferences` | Mis preferencias de notificación          |
| `orders`                            | Crear pedidos nuevos                      |
| `order_items`                       | Items de mis pedidos                      |
| `customer_coupons`                  | Usar cupones                              |

#### Tablas de SOLO LECTURA

| Tabla         | Uso                                           |
| ------------- | --------------------------------------------- |
| `restaurants` | Info del restaurante (horarios, delivery fee) |
| `categories`  | Ver menú                                      |
| `products`    | Ver productos                                 |
| `addons`      | Ver extras disponibles                        |
| `promotions`  | Ver promociones activas                       |
| `coupons`     | Verificar cupón válido                        |

---

### 🛵 CourierApp

#### Tablas de LECTURA + ESCRITURA

| Tabla             | Uso                                         |
| ----------------- | ------------------------------------------- |
| `drivers`         | Mi perfil, ubicación, status online         |
| `orders`          | Cambiar status (ready→delivering→delivered) |
| `driver_earnings` | Mi historial de ganancias                   |

#### Tablas de SOLO LECTURA

| Tabla                | Uso                            |
| -------------------- | ------------------------------ |
| `restaurants`        | Info del restaurante a recoger |
| `customers`          | Info del cliente para entregar |
| `customer_addresses` | Dirección de entrega           |

---

## 🔐 Storage Buckets (Supabase)

| Bucket              | Público | Quién sube | Límite | MIME Types           |
| ------------------- | ------- | ---------- | ------ | -------------------- |
| `restaurant-assets` | ✅      | Admin      | 5MB    | jpeg, png, webp, svg |
| `product-images`    | ✅      | Admin      | 5MB    | jpeg, png, webp      |
| `category-images`   | ✅      | Admin      | 5MB    | jpeg, png, webp      |
| `driver-photos`     | ✅      | Driver     | 5MB    | jpeg, png, webp      |
| `driver-documents`  | ❌      | Driver     | 10MB   | jpeg, png, webp, pdf |
| `customer-photos`   | ✅      | Customer   | 5MB    | jpeg, png, webp      |
| `payment-receipts`  | ❌      | Customer   | 10MB   | jpeg, png, webp, pdf |

---

## 🔄 Flujos de Datos

### Flujo: Crear Pedido (CustomerApp → AdminDashboard → CourierApp)

```
1. CustomerApp:
   - INSERT INTO orders (restaurant_id, customer_id, ..., status='pending')
   - INSERT INTO order_items (order_id, product_id, ...)
   - Supabase Realtime notifica

2. AdminDashboard:
   - Recibe notificación realtime
   - Admin revisa y UPDATE orders SET status='accepted', accepted_at=NOW()
   - Cocina prepara, UPDATE orders SET status='processing', processing_at=NOW()
   - Listo, UPDATE orders SET status='ready', ready_at=NOW()
   - Supabase Realtime notifica a CourierApp

3. CourierApp:
   - Recibe notificación de pedido listo
   - Driver acepta: UPDATE orders SET driver_id=?, status='delivering', picked_up_at=NOW()
   - Entrega: UPDATE orders SET status='delivered', delivered_at=NOW()
   - Supabase Realtime notifica a CustomerApp
```

### Flujo: Registro de Driver (CourierApp → AdminDashboard)

```
1. CourierApp:
   - INSERT INTO drivers (restaurant_id, ..., status='pending')
   - Sube foto a driver-photos bucket
   - Sube documentos a driver-documents bucket

2. AdminDashboard:
   - Admin ve nuevo driver pendiente
   - Revisa documentos
   - UPDATE drivers SET status='approved', approved_at=NOW()
   - Supabase Realtime notifica a CourierApp

3. CourierApp:
   - Driver recibe aprobación
   - Puede iniciar sesión y ver pedidos
```

### Flujo: Registro de Restaurante (AdminDashboard)

```
1. AdminDashboard Sign-up:
   - INSERT INTO restaurants (name, email, slug, ...)
   - INSERT INTO restaurant_admins (restaurant_id, email, password_hash, role='owner')
   - subscription_status = 'trial'
   - trial_ends_at = NOW() + 14 days

2. AdminDashboard Sign-in:
   - Verificar email + password en restaurant_admins
   - Obtener restaurant_id del admin
   - Todas las queries filtran por restaurant_id
```

---

## 📡 Supabase Realtime

Tablas con realtime habilitado:

- `orders` → Todas las apps ven cambios de estado
- `drivers` → AdminDashboard ve drivers online
- `notifications` → Push notifications

### Filtrado por Tenant

```sql
-- Siempre filtrar por restaurant_id
supabase.from('orders')
  .on('INSERT', payload => ...)
  .filter('restaurant_id', 'eq', myRestaurantId)
  .subscribe()
```

---

## 💰 Modelo de Precios

Todos los precios en **centavos** (`_cents` suffix):

- `price_cents` = precio en centavos
- `total_cents` = total en centavos
- División entre 100 solo en la UI

Moneda configurable por restaurante:

- `restaurants.currency_code` = 'MXN', 'USD', etc.
- `restaurants.currency_symbol` = '$', '€', etc.
- `restaurants.currency_position` = 'before' o 'after'

### Fórmula de Total

```
total_cents = subtotal_cents + tax_cents + delivery_fee_cents + tip_cents - discount_cents
```

### Fórmula de Ganancia Driver

```
Si driver_commission_type = 'percentage':
  driver_earnings_cents = delivery_fee_cents * driver_commission_value / 100

Si driver_commission_type = 'fixed':
  driver_earnings_cents = driver_commission_value * 100

Si driver_commission_type = 'per_km':
  driver_earnings_cents = distance_km * driver_commission_value * 100
```

---

## 🚫 Reglas de Negocio

1. **Un customer pertenece a UN restaurante** (por ahora)
2. **Un driver pertenece a UN restaurante** (por ahora)
3. **Orders siempre tienen restaurant_id** (multi-tenant)
4. **Drivers requieren aprobación** (status='approved') antes de trabajar
5. **Customers pueden ser guests** si `restaurants.allow_guest_orders = true`
6. **order_number es único por restaurante** (UNIQUE restaurant_id, order_number)
7. **Snapshots preservan datos** aunque se borre customer/address original
8. **Todos los precios en centavos** (evitar errores de floating point)
9. **Soft delete con deleted_at** (restaurants no se borran, se marcan)
10. **Trial de 14 días** por defecto al registrar restaurante

---

## ✅ Checklist de Sincronización

Para que las 3 apps funcionen correctamente:

- [ ] Todas usan el mismo `order_status` ENUM (7 valores)
- [ ] Todas incluyen `restaurant_id` en queries
- [ ] CustomerApp: Order entity tiene `restaurant_id`
- [ ] CourierApp: Driver registration incluye `restaurant_id`
- [ ] AdminDashboard: Sign-up incluye password
- [ ] Image uploads usan Storage buckets correctos
- [ ] Currency y horarios vienen de `restaurants` table
- [ ] Realtime subscriptions filtran por `restaurant_id`
- [ ] Precios en centavos, dividir por 100 solo en UI
- [ ] Snapshots se guardan al crear order
