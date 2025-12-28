# Backend Technical Requirements - Napoli Drivers App

This document complements the API Specification with additional technical requirements for database design, real-time features, file handling, and infrastructure.

---

## 🗄️ Database Schema

### Recommended Tables

#### `drivers`
```sql
CREATE TABLE drivers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  profile_image_url TEXT,
  vehicle_type VARCHAR(10) NOT NULL CHECK (vehicle_type IN ('moto', 'bici', 'auto')),
  license_plate VARCHAR(10) UNIQUE NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'active', 'inactive')),
  is_online BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Statistics (denormalized for performance)
  total_deliveries INTEGER DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
  total_earnings DECIMAL(10,2) DEFAULT 0.0,
  
  -- Indexes
  INDEX idx_drivers_email (email),
  INDEX idx_drivers_status (status),
  INDEX idx_drivers_is_online (is_online)
);
```

#### `orders`
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number VARCHAR(20) UNIQUE NOT NULL,
  driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
  
  -- Customer info
  customer_name VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(20) NOT NULL,
  
  -- Delivery address
  delivery_street TEXT NOT NULL,
  delivery_details TEXT,
  delivery_notes TEXT,
  delivery_latitude DECIMAL(10,8) NOT NULL,
  delivery_longitude DECIMAL(11,8) NOT NULL,
  
  -- Pricing
  subtotal DECIMAL(10,2) NOT NULL,
  delivery_fee DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  driver_earnings DECIMAL(10,2) NOT NULL,
  distance_km DECIMAL(5,2) NOT NULL,
  
  -- Status tracking
  status VARCHAR(20) NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'accepted', 'picked_up', 'delivered', 'cancelled')),
  created_at TIMESTAMP DEFAULT NOW(),
  accepted_at TIMESTAMP,
  picked_up_at TIMESTAMP,
  delivered_at TIMESTAMP,
  cancelled_at TIMESTAMP,
  cancellation_reason TEXT,
  
  -- Indexes
  INDEX idx_orders_status (status),
  INDEX idx_orders_driver_id (driver_id),
  INDEX idx_orders_created_at (created_at),
  INDEX idx_orders_delivered_at (delivered_at)
);
```

#### `order_items`
```sql
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price DECIMAL(10,2) NOT NULL CHECK (price > 0),
  notes TEXT,
  
  INDEX idx_order_items_order_id (order_id)
);
```

#### `driver_settings`
```sql
CREATE TABLE driver_settings (
  driver_id UUID PRIMARY KEY REFERENCES drivers(id) ON DELETE CASCADE,
  notifications_enabled BOOLEAN DEFAULT true,
  language VARCHAR(5) DEFAULT 'es',
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### `ratings` (Optional - for future rating system)
```sql
CREATE TABLE ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(order_id),
  INDEX idx_ratings_driver_id (driver_id)
);
```

---

## 🔐 Security Requirements

### Password Hashing
- Use **bcrypt** with cost factor 10-12
- Never store plain text passwords
- Implement password reset flow (not in current app scope)

### JWT Tokens
- **Algorithm**: HS256 or RS256
- **Expiration**: 7 days (configurable)
- **Payload**: Include `driver_id`, `email`, `status`
- **Refresh tokens**: Recommended for production

### API Rate Limiting
- **Authentication endpoints**: 5 requests/minute per IP
- **General endpoints**: 100 requests/minute per user
- **Order updates**: 30 requests/minute per user

### CORS Configuration
```javascript
{
  origin: ['https://app.napoli.com', 'http://localhost:*'],
  credentials: true,
  methods: ['GET', 'POST', 'PATCH', 'DELETE']
}
```

---

## 📤 File Upload Requirements

### Profile Images
- **Endpoint**: `POST /drivers/me/upload-image`
- **Max size**: 5 MB
- **Formats**: JPEG, PNG, WebP
- **Processing**:
  - Resize to 512x512px
  - Compress to <200KB
  - Store in cloud storage (S3, Cloudinary, etc.)
  - Return public URL
- **Security**: Validate file type (magic bytes), scan for malware

### Image Storage Structure
```
/drivers/
  /{driver_id}/
    /profile.jpg
    /profile_thumb.jpg
```

---

## 🔔 Push Notifications (Future Feature)

### Events to Notify
1. **New Order Available** (when driver is online)
2. **Order Cancelled** (by customer or admin)
3. **Account Approved** (status changed to approved)
4. **Account Suspended** (status changed to inactive)

### Recommended Service
- **Firebase Cloud Messaging (FCM)** for cross-platform support
- Store FCM tokens in `driver_settings` table

### Notification Payload Example
```json
{
  "notification": {
    "title": "Nuevo pedido disponible",
    "body": "Pedido #1001 - $150 - 1.2km"
  },
  "data": {
    "type": "new_order",
    "order_id": "uuid",
    "driver_earnings": "150.0"
  }
}
```

---

## 🌐 Real-Time Features (Optional but Recommended)

### WebSocket Events
For real-time order updates without polling:

**Driver subscribes to**:
- `orders:available` - New orders appear
- `orders:{driver_id}:updated` - Active order status changes

**Events to emit**:
```javascript
// New order available
{
  event: 'order:created',
  data: { /* Order object */ }
}

// Order taken by another driver
{
  event: 'order:taken',
  data: { order_id: 'uuid' }
}
```

### Technology Options
- **Socket.io** (Node.js)
- **Pusher** (managed service)
- **Redis Pub/Sub** (self-hosted)

---

## 📊 Analytics & Logging

### Metrics to Track
- Driver registration rate
- Order acceptance rate (% of available orders accepted)
- Average delivery time (accepted → delivered)
- Driver online hours
- Revenue per driver

### Logging Requirements
- **Info**: All API requests (method, path, status, duration)
- **Warning**: Failed login attempts, validation errors
- **Error**: Server errors, database failures, external API failures

### Recommended Tools
- **Logging**: Winston (Node.js), Logback (Java), Serilog (.NET)
- **Monitoring**: Sentry, Datadog, New Relic
- **Analytics**: Mixpanel, Amplitude

---

## 🚀 Deployment & Infrastructure

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/napoli_db

# JWT
JWT_SECRET=your-super-secret-key-change-in-production
JWT_EXPIRATION=7d

# File Storage
AWS_S3_BUCKET=napoli-driver-images
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret

# External Services
FCM_SERVER_KEY=your-fcm-key
SENTRY_DSN=https://...

# App Config
NODE_ENV=production
PORT=3000
CORS_ORIGIN=https://app.napoli.com
```

### Recommended Stack
- **Runtime**: Node.js 18+ / Python 3.11+ / Java 17+
- **Framework**: Express/Fastify (Node), FastAPI (Python), Spring Boot (Java)
- **Database**: PostgreSQL 14+
- **Cache**: Redis 7+ (for sessions, rate limiting)
- **File Storage**: AWS S3 / Google Cloud Storage / Cloudinary
- **Hosting**: AWS EC2/ECS, Google Cloud Run, Heroku, Railway

### Database Migrations
Use a migration tool:
- **Node.js**: Knex.js, Prisma, TypeORM
- **Python**: Alembic, Django migrations
- **Java**: Flyway, Liquibase

---

## 🧪 Testing Requirements

### Unit Tests
- Repository layer (database operations)
- Service layer (business logic)
- Validation functions
- **Coverage target**: 70%+

### Integration Tests
- API endpoints (request → response)
- Authentication flow
- Order status transitions
- **Coverage target**: 80%+

### Test Data
Provide seed scripts with:
- 5 test drivers (various statuses)
- 10 test orders (various statuses)
- Realistic addresses in Buenos Aires area

---

## 📋 API Versioning Strategy

### URL Versioning (Recommended)
```
/v1/auth/login
/v1/orders/available
/v2/orders/available (future)
```

### Breaking Changes
When introducing breaking changes:
1. Create new version (`/v2`)
2. Maintain old version for 6 months
3. Add deprecation warnings in headers
4. Notify mobile team before deprecation

---

## 🔄 Background Jobs

### Scheduled Tasks
1. **Auto-offline inactive drivers** (every 5 minutes)
   - Set `is_online = false` for drivers inactive >30 min
   
2. **Anonymize old orders** (daily at 2 AM)
   - Remove customer phone/address from orders >90 days old
   
3. **Update driver statistics** (every hour)
   - Recalculate `total_deliveries`, `rating`, `total_earnings`

### Job Queue
- **Technology**: Bull (Redis-based), Celery (Python), Sidekiq (Ruby)
- **Retry policy**: 3 attempts with exponential backoff

---

## 📞 External API Integrations (Future)

### Google Maps API
- **Geocoding**: Convert addresses to coordinates
- **Distance Matrix**: Calculate delivery distance
- **Directions**: Provide route to driver

### Payment Gateway (Future)
- Stripe, MercadoPago, or PayPal
- For driver payouts

---

## 🛡️ Data Privacy & GDPR Compliance

### User Rights
1. **Right to Access**: Driver can download their data
2. **Right to Deletion**: Driver can request account deletion
3. **Data Retention**: 
   - Active drivers: Indefinite
   - Inactive drivers: 2 years
   - Delivered orders: 90 days (then anonymized)

### Anonymization Process
After 90 days, for delivered orders:
```sql
UPDATE orders 
SET 
  customer_name = 'Cliente Anónimo',
  customer_phone = '+00000000000',
  delivery_street = 'Dirección Anónima',
  delivery_details = NULL,
  delivery_notes = NULL
WHERE 
  status = 'delivered' 
  AND delivered_at < NOW() - INTERVAL '90 days';
```

---

## 📖 API Documentation

### Interactive Documentation
Generate with:
- **Swagger/OpenAPI**: Auto-generate from code
- **Postman Collection**: Export for team testing
- **ReDoc**: Beautiful API docs from OpenAPI spec

### Hosting
- Serve at `/api/docs`
- Include authentication examples
- Provide "Try it out" functionality

---

## ✅ Pre-Launch Checklist

- [ ] Database schema created with migrations
- [ ] All endpoints implemented and tested
- [ ] JWT authentication working
- [ ] File upload functional
- [ ] Error handling standardized
- [ ] Rate limiting configured
- [ ] CORS properly set
- [ ] Environment variables documented
- [ ] Database backups configured
- [ ] Monitoring/logging set up
- [ ] Load testing completed (100+ concurrent users)
- [ ] Security audit performed
- [ ] API documentation published
- [ ] Staging environment deployed
- [ ] Mobile team has tested integration

---

## 🆘 Support & Maintenance

### SLA Targets
- **Uptime**: 99.5% (production)
- **Response time**: <200ms (p95)
- **Error rate**: <1%

### On-Call Rotation
- 24/7 support for production issues
- Escalation path defined
- Incident response playbook

### Monitoring Alerts
- Database connection failures
- High error rate (>5% in 5 min)
- Slow queries (>1s)
- Disk space <20%
- Memory usage >80%
