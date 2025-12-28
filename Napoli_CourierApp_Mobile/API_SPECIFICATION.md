# Napoli Drivers App - API Specification v1.0

Complete REST API specification for the Napoli Drivers mobile application. This document provides detailed endpoint definitions, request/response schemas, authentication flows, error handling, and business logic requirements.

---

## 📋 Table of Contents
1. [General Information](#general-information)
2. [Authentication & Authorization](#authentication--authorization)
3. [Driver Management](#driver-management)
4. [Order Management](#order-management)
5. [Data Models](#data-models)
6. [Error Handling](#error-handling)
7. [Business Rules](#business-rules)

---

## 🌐 General Information

### Base URL
```
Production: https://api.napoli.com/v1
Staging: https://staging-api.napoli.com/v1
```

### Content Type
All requests and responses use `application/json`.

### Date Format
All timestamps follow ISO 8601 format: `2023-10-25T14:30:00Z`

### Authentication
Protected endpoints require JWT token in header:
```
Authorization: Bearer <jwt_token>
```

---

## 🔐 Authentication & Authorization

### 1. Driver Login

**Endpoint**: `POST /auth/login`

**Description**: Authenticates a driver and returns a JWT token.

**Request Body**:
```json
{
  "email": "driver@example.com",
  "password": "securepassword"
}
```

**Success Response** (`200 OK`):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "driver": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Juan Pérez",
    "email": "driver@example.com",
    "phone": "+5491112345678",
    "profile_image_url": "https://storage.napoli.com/drivers/550e8400.jpg",
    "vehicle_type": "moto",
    "license_plate": "ABC-123",
    "status": "active",
    "is_online": false,
    "created_at": "2023-10-25T14:30:00Z",
    "total_deliveries": 150,
    "rating": 4.8,
    "total_earnings": 15000.50
  }
}
```

**Error Responses**:
- `400 Bad Request`: Missing or invalid fields
  ```json
  {
    "error": "INVALID_CREDENTIALS",
    "message": "Email o contraseña incorrectos"
  }
  ```
- `403 Forbidden`: Driver account is not approved
  ```json
  {
    "error": "ACCOUNT_PENDING",
    "message": "Tu cuenta está pendiente de aprobación"
  }
  ```
- `423 Locked`: Driver account is inactive
  ```json
  {
    "error": "ACCOUNT_INACTIVE",
    "message": "Tu cuenta ha sido desactivada. Contacta soporte."
  }
  ```

**Validation Rules**:
- Email must be valid format
- Password minimum 6 characters
- Driver status must be `active` or `approved` to login

---

### 2. Driver Registration

**Endpoint**: `POST /auth/register`

**Description**: Registers a new driver. Account starts in `pending` status awaiting admin approval.

**Request Body**:
```json
{
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "password": "securepassword123",
  "phone": "+5491112345678",
  "vehicle_type": "moto",
  "license_plate": "ABC-123",
  "profile_image": "base64_encoded_image_optional"
}
```

**Success Response** (`201 Created`):
```json
{
  "driver": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "phone": "+5491112345678",
    "profile_image_url": null,
    "vehicle_type": "moto",
    "license_plate": "ABC-123",
    "status": "pending",
    "is_online": false,
    "created_at": "2023-10-25T14:30:00Z",
    "total_deliveries": 0,
    "rating": 0.0,
    "total_earnings": 0.0
  }
}
```

**Error Responses**:
- `409 Conflict`: Email already registered
  ```json
  {
    "error": "EMAIL_EXISTS",
    "message": "Este email ya está registrado"
  }
  ```
- `422 Unprocessable Entity`: Invalid data
  ```json
  {
    "error": "VALIDATION_ERROR",
    "message": "Datos inválidos",
    "details": {
      "phone": "Formato de teléfono inválido",
      "license_plate": "Placa ya registrada"
    }
  }
  ```

**Validation Rules**:
- Name: 2-100 characters
- Email: Valid format, unique
- Password: Minimum 6 characters
- Phone: Valid international format (E.164)
- Vehicle type: Must be one of: `moto`, `bici`, `auto`
- License plate: 3-10 characters, unique
- Profile image: Optional, max 5MB, formats: jpg, png

---

## 👤 Driver Management

### 3. Get Current Driver Profile

**Endpoint**: `GET /drivers/me`

**Headers**: `Authorization: Bearer <token>`

**Description**: Returns the authenticated driver's complete profile.

**Success Response** (`200 OK`):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "phone": "+5491112345678",
  "profile_image_url": "https://storage.napoli.com/drivers/550e8400.jpg",
  "vehicle_type": "moto",
  "license_plate": "ABC-123",
  "status": "active",
  "is_online": true,
  "created_at": "2023-10-25T14:30:00Z",
  "total_deliveries": 150,
  "rating": 4.8,
  "total_earnings": 15000.50
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or expired token

---

### 4. Update Driver Profile

**Endpoint**: `PATCH /drivers/me`

**Headers**: `Authorization: Bearer <token>`

**Description**: Updates driver profile information. Only modifiable fields are accepted.

**Request Body** (all fields optional):
```json
{
  "name": "Juan Pérez Actualizado",
  "phone": "+5491198765432",
  "vehicle_type": "auto",
  "license_plate": "XYZ-789",
  "profile_image": "base64_encoded_image"
}
```

**Success Response** (`200 OK`):
Returns updated driver object (same schema as GET /drivers/me)

**Error Responses**:
- `422 Unprocessable Entity`: Validation errors
  ```json
  {
    "error": "VALIDATION_ERROR",
    "message": "Datos inválidos",
    "details": {
      "license_plate": "Esta placa ya está registrada por otro conductor"
    }
  }
  ```

**Business Rules**:
- Cannot change email (requires separate endpoint)
- Cannot change status (admin only)
- License plate must be unique across all drivers
- Profile image upload triggers async processing

---

### 5. Change Password

**Endpoint**: `POST /drivers/me/password`

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "current_password": "oldpassword123",
  "new_password": "newpassword456"
}
```

**Success Response** (`204 No Content`)

**Error Responses**:
- `400 Bad Request`: Current password incorrect
  ```json
  {
    "error": "INVALID_PASSWORD",
    "message": "La contraseña actual es incorrecta"
  }
  ```
- `422 Unprocessable Entity`: New password doesn't meet requirements
  ```json
  {
    "error": "WEAK_PASSWORD",
    "message": "La nueva contraseña debe tener al menos 6 caracteres"
  }
  ```

---

### 6. Update Driver Settings

**Endpoint**: `PATCH /drivers/me/settings`

**Headers**: `Authorization: Bearer <token>`

**Request Body**:
```json
{
  "notifications_enabled": true
}
```

**Success Response** (`200 OK`):
```json
{
  "notifications_enabled": true
}
```

---

### 7. Toggle Online Status

**Endpoint**: `POST /drivers/me/status`

**Headers**: `Authorization: Bearer <token>`

**Description**: Toggles driver availability to receive new orders.

**Request Body**:
```json
{
  "is_online": true
}
```

**Success Response** (`200 OK`):
```json
{
  "is_online": true,
  "updated_at": "2023-10-25T15:30:00Z"
}
```

**Business Rules**:
- Driver must have `active` status to go online
- Going offline doesn't affect active deliveries
- System may auto-offline driver after inactivity (30 min)

---

## 📦 Order Management

### 8. Get Available Orders

**Endpoint**: `GET /orders/available`

**Headers**: `Authorization: Bearer <token>`

**Description**: Returns list of orders waiting to be accepted by any driver.

**Query Parameters**:
- `limit` (optional): Max results, default 20, max 100
- `offset` (optional): Pagination offset, default 0

**Success Response** (`200 OK`):
```json
{
  "orders": [
    {
      "id": "order-uuid-1",
      "order_number": "#1001",
      "customer_name": "María López",
      "customer_phone": "+5491198765432",
      "delivery_address": {
        "street": "Av. Libertador 1234",
        "details": "Piso 4, Depto B",
        "notes": "Tocar timbre 2 veces",
        "latitude": -34.603722,
        "longitude": -58.381592
      },
      "items": [
        {
          "name": "Pizza Napoli Grande",
          "quantity": 1,
          "price": 850.0,
          "notes": "Sin cebolla"
        },
        {
          "name": "Coca-Cola 500ml",
          "quantity": 2,
          "price": 150.0,
          "notes": null
        }
      ],
      "subtotal": 1150.0,
      "delivery_fee": 200.0,
      "total": 1350.0,
      "driver_earnings": 150.0,
      "distance_km": 1.2,
      "status": "available",
      "created_at": "2023-10-25T15:00:00Z",
      "accepted_at": null,
      "picked_up_at": null,
      "delivered_at": null
    }
  ],
  "total": 5,
  "limit": 20,
  "offset": 0
}
```

**Business Rules**:
- Only shows orders with `available` status
- Orders sorted by creation time (oldest first)
- Driver must be online to see available orders

---

### 9. Get Active Orders

**Endpoint**: `GET /orders/active`

**Headers**: `Authorization: Bearer <token>`

**Description**: Returns orders currently assigned to the authenticated driver.

**Success Response** (`200 OK`):
```json
{
  "orders": [
    {
      "id": "order-uuid-2",
      "order_number": "#1002",
      "status": "accepted",
      "accepted_at": "2023-10-25T15:05:00Z",
      // ... (same schema as available orders)
    }
  ]
}
```

**Business Rules**:
- Returns orders with status: `accepted`, `picked_up`
- Excludes `available`, `delivered`, `cancelled`
- Maximum 10 active orders per driver

---

### 10. Get Order History

**Endpoint**: `GET /orders/history`

**Headers**: `Authorization: Bearer <token>`

**Query Parameters**:
- `period` (required): `today`, `week`, `month`
- `limit` (optional): Default 50
- `offset` (optional): Default 0

**Success Response** (`200 OK`):
```json
{
  "orders": [
    {
      "id": "order-uuid-3",
      "order_number": "#1003",
      "status": "delivered",
      "delivered_at": "2023-10-25T16:30:00Z",
      // ... (same schema)
    }
  ],
  "summary": {
    "total_deliveries": 12,
    "total_earnings": 1800.0,
    "average_earnings": 150.0
  },
  "period": "today"
}
```

**Period Definitions**:
- `today`: From 00:00 to 23:59 current day
- `week`: Last 7 days
- `month`: Last 30 days

---

### 11. Get Order Detail

**Endpoint**: `GET /orders/{id}`

**Headers**: `Authorization: Bearer <token>`

**Path Parameters**:
- `id`: Order UUID

**Success Response** (`200 OK`):
Returns single order object (same schema as list endpoints)

**Error Responses**:
- `404 Not Found`: Order doesn't exist or driver has no access
  ```json
  {
    "error": "ORDER_NOT_FOUND",
    "message": "Pedido no encontrado"
  }
  ```

---

### 12. Update Order Status

**Endpoint**: `PATCH /orders/{id}/status`

**Headers**: `Authorization: Bearer <token>`

**Description**: Updates order status following the delivery workflow.

**Request Body**:
```json
{
  "status": "accepted"
}
```

**Valid Status Transitions**:
```
available → accepted (driver accepts order)
accepted → picked_up (driver picks up from restaurant)
picked_up → delivered (driver completes delivery)
any → cancelled (with reason)
```

**Success Response** (`200 OK`):
Returns updated order object with new timestamps

**Error Responses**:
- `400 Bad Request`: Invalid status transition
  ```json
  {
    "error": "INVALID_TRANSITION",
    "message": "No puedes cambiar de 'available' a 'delivered' directamente"
  }
  ```
- `409 Conflict`: Order already accepted by another driver
  ```json
  {
    "error": "ORDER_TAKEN",
    "message": "Este pedido ya fue aceptado por otro conductor"
  }
  ```

**Business Rules**:
- `accepted`: Order assigned to driver, updates `accepted_at` timestamp
- `picked_up`: Driver confirms pickup from restaurant, updates `picked_up_at`
- `delivered`: Delivery completed, updates `delivered_at`, increments driver stats
- Driver can only accept if online and has < 10 active orders

---

## 📝 Data Models

### Driver Object
```typescript
{
  id: string;                    // UUID
  name: string;                  // 2-100 chars
  email: string;                 // Valid email, unique
  phone: string;                 // E.164 format
  profile_image_url: string | null;
  vehicle_type: "moto" | "bici" | "auto";
  license_plate: string;         // 3-10 chars, unique
  status: "pending" | "approved" | "active" | "inactive";
  is_online: boolean;
  created_at: string;            // ISO 8601
  total_deliveries: number;      // >= 0
  rating: number;                // 0.0 - 5.0
  total_earnings: number;        // >= 0.0
}
```

### Order Object
```typescript
{
  id: string;                    // UUID
  order_number: string;          // Format: #XXXX
  customer_name: string;
  customer_phone: string;        // E.164 format
  delivery_address: {
    street: string;
    details: string;
    notes: string | null;
    latitude: number;            // -90 to 90
    longitude: number;           // -180 to 180
  };
  items: Array<{
    name: string;
    quantity: number;            // > 0
    price: number;               // > 0
    notes: string | null;
  }>;
  subtotal: number;              // Sum of items
  delivery_fee: number;          // >= 0
  total: number;                 // subtotal + delivery_fee
  driver_earnings: number;       // Driver's cut
  distance_km: number;           // > 0
  status: "available" | "accepted" | "picked_up" | "delivered" | "cancelled";
  created_at: string;            // ISO 8601
  accepted_at: string | null;    // ISO 8601
  picked_up_at: string | null;   // ISO 8601
  delivered_at: string | null;   // ISO 8601
}
```

---

## ⚠️ Error Handling

### Standard Error Response Format
```json
{
  "error": "ERROR_CODE",
  "message": "Human-readable message in Spanish",
  "details": {
    "field_name": "Specific error for this field"
  }
}
```

### HTTP Status Codes
- `200 OK`: Success
- `201 Created`: Resource created
- `204 No Content`: Success with no response body
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Missing or invalid auth token
- `403 Forbidden`: Valid auth but insufficient permissions
- `404 Not Found`: Resource doesn't exist
- `409 Conflict`: Resource conflict (e.g., duplicate)
- `422 Unprocessable Entity`: Validation errors
- `423 Locked`: Account locked/inactive
- `500 Internal Server Error`: Server error

### Common Error Codes
- `INVALID_CREDENTIALS`
- `ACCOUNT_PENDING`
- `ACCOUNT_INACTIVE`
- `EMAIL_EXISTS`
- `VALIDATION_ERROR`
- `ORDER_NOT_FOUND`
- `ORDER_TAKEN`
- `INVALID_TRANSITION`
- `UNAUTHORIZED`
- `TOKEN_EXPIRED`

---

## 📐 Business Rules

### Driver Status Flow
```
pending → approved (admin action)
approved → active (driver first login)
active ↔ inactive (admin action)
```

### Order Status Flow
```
available → accepted → picked_up → delivered
          ↓
       cancelled
```

### Earnings Calculation
- Driver earnings typically 10-15% of order total
- Minimum earnings per delivery: $100
- Earnings credited on `delivered` status

### Rating System
- Customers rate drivers 1-5 stars after delivery
- Driver rating = average of all ratings
- Minimum 10 deliveries before rating is displayed

### Online Status Rules
- Auto-offline after 30 minutes of inactivity
- Cannot go online if status is not `active`
- Going offline doesn't cancel active deliveries

### Privacy Rules
- Customer phone/address hidden for `delivered` orders older than 24 hours
- Driver can view own delivery history indefinitely
- Customer data anonymized after 90 days (GDPR compliance)
