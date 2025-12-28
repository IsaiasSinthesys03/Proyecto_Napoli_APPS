# 🍕 Napoli - Sistema Multi-Tenant de Gestión de Pizzerías

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Next.js](https://img.shields.io/badge/Next.js-14+-000000?logo=next.js)](https://nextjs.org)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?logo=postgresql)](https://postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Sistema SaaS completo para gestión de pizzerías con 3 aplicaciones integradas**: Dashboard Web para administración, App móvil para clientes y App móvil para repartidores.

---

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Arquitectura](#-arquitectura)
- [Proyectos](#-proyectos)
- [Tecnologías](#-tecnologías)
- [Características Principales](#-características-principales)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Documentación](#-documentación)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

---

## 🎯 Descripción General

**Napoli** es una plataforma SaaS multi-tenant diseñada para gestionar pizzerías de manera integral. El sistema permite a múltiples restaurantes operar de forma independiente en la misma infraestructura, con aislamiento completo de datos mediante `restaurant_id`.

### ¿Qué hace Napoli?

- 🏪 **Gestión de Restaurantes**: Administra menú, productos, categorías, promociones y cupones
- 📱 **Pedidos en Tiempo Real**: Sistema de pedidos con actualización en tiempo real usando Supabase Realtime
- 🛵 **Gestión de Repartidores**: Asignación automática, seguimiento GPS y cálculo de ganancias
- 💳 **Múltiples Métodos de Pago**: Efectivo, tarjeta, transferencia
- 📊 **Reportes y Analíticas**: Dashboard con métricas de ventas, productos más vendidos y reportes diarios
- 🌍 **Multi-tenant**: Soporte para múltiples restaurantes en la misma plataforma

---

## 🏗️ Arquitectura

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

### Principios de Arquitectura

- **Clean Architecture**: Separación en capas (Domain, Data, Presentation)
- **Stored Procedures**: Toda la lógica de negocio en PostgreSQL
- **Multi-tenant**: Aislamiento de datos por `restaurant_id`
- **Realtime**: Sincronización en tiempo real con Supabase
- **Offline-first**: Apps móviles funcionan sin conexión

---

## 📱 Proyectos

### 1. 🖥️ Napoli_AdminDashboard_Web

**Dashboard web para administradores de pizzerías**

- **Tecnología**: Next.js 14, TypeScript, Tailwind CSS, shadcn/ui
- **Funcionalidades**:
  - Gestión completa del menú (productos, categorías, extras)
  - Administración de pedidos en tiempo real
  - Gestión de repartidores y aprobaciones
  - Reportes de ventas y analíticas
  - Configuración del restaurante (horarios, métodos de pago, delivery)
  - Sistema de cupones y promociones

**Directorio**: `Napoli_AdminDashboard_Web/`

### 2. 📱 Napoli_CustomerApp_Mobile

**Aplicación móvil para clientes**

- **Tecnología**: Flutter, Dart, BLoC Pattern, Clean Architecture
- **Funcionalidades**:
  - Explorar menú y productos
  - Carrito de compras con personalización
  - Múltiples direcciones de entrega
  - Métodos de pago guardados
  - Seguimiento de pedidos en tiempo real
  - Historial de pedidos
  - Sistema de cupones
  - Calificaciones y reseñas

**Directorio**: `Napoli_CustomerApp_Mobile/`

### 3. 🛵 Napoli_CourierApp_Mobile

**Aplicación móvil para repartidores**

- **Tecnología**: Flutter, Dart, BLoC Pattern, Clean Architecture
- **Funcionalidades**:
  - Registro y aprobación de repartidores
  - Ver pedidos disponibles
  - Aceptar y gestionar entregas
  - Navegación GPS integrada
  - Historial de entregas
  - Cálculo automático de ganancias
  - Sistema de calificaciones

**Directorio**: `Napoli_CourierApp_Mobile/`

---

## 🛠️ Tecnologías

### Backend
- **Supabase**: Backend as a Service (BaaS)
- **PostgreSQL 15+**: Base de datos relacional
- **Stored Procedures**: Lógica de negocio en SQL
- **Supabase Realtime**: WebSockets para actualizaciones en tiempo real
- **Supabase Storage**: Almacenamiento de imágenes y documentos

### Frontend Web
- **Next.js 14**: Framework React con SSR
- **TypeScript**: Tipado estático
- **Tailwind CSS**: Framework CSS utility-first
- **shadcn/ui**: Componentes UI accesibles
- **React Query**: Gestión de estado del servidor

### Mobile Apps
- **Flutter 3.0+**: Framework multiplataforma
- **Dart**: Lenguaje de programación
- **BLoC Pattern**: Gestión de estado
- **Clean Architecture**: Arquitectura en capas
- **Supabase Flutter SDK**: Cliente de Supabase para Flutter

### DevOps & Tools
- **Git**: Control de versiones
- **GitHub**: Repositorio remoto
- **VS Code**: Editor de código
- **Android Studio**: IDE para Flutter

---

## ✨ Características Principales

### 🔐 Autenticación y Seguridad
- Autenticación con Supabase Auth
- Row Level Security (RLS) en PostgreSQL
- Aislamiento multi-tenant por `restaurant_id`
- Roles de usuario (owner, manager, staff, kitchen)

### 📦 Gestión de Pedidos
- **Estados de pedido**: pending → accepted → processing → ready → delivering → delivered
- **Snapshots**: Preservación de datos de cliente y dirección
- **Precios en centavos**: Evita errores de punto flotante
- **Cálculo automático**: Subtotal, impuestos, delivery, propinas, descuentos

### 💰 Sistema de Pagos
- Múltiples métodos: Efectivo, tarjeta, transferencia
- Configuración por restaurante
- Estados de pago: pending, paid, failed, refunded
- Recibos y comprobantes

### 🚚 Sistema de Delivery
- Radio de entrega configurable
- Costo de envío fijo o por kilómetro
- Envío gratis por monto mínimo
- Estimación de tiempos de preparación y entrega
- Seguimiento GPS en tiempo real

### 🎟️ Promociones y Cupones
- Cupones de descuento (porcentaje o monto fijo)
- Promociones por producto
- Validación automática
- Límites de uso

### 📊 Reportes y Analíticas
- Dashboard con métricas en tiempo real
- Reportes diarios de ventas
- Productos más vendidos
- Análisis de repartidores
- Exportación de datos

---

## 🚀 Instalación

### Prerrequisitos

- **Node.js** 18+ (para AdminDashboard)
- **Flutter** 3.0+ (para apps móviles)
- **Git**
- **Cuenta de Supabase** (gratuita)

### 1. Clonar el Repositorio

```bash
git clone https://github.com/IsaiasSinthesys03/Proyecto_Napoli_APPS.git
cd Proyecto_Napoli_APPS
```

### 2. Configurar AdminDashboard Web

```bash
cd Napoli_AdminDashboard_Web
npm install
cp .env.example .env.local
# Editar .env.local con tus credenciales de Supabase
npm run dev
```

### 3. Configurar CustomerApp Mobile

```bash
cd Napoli_CustomerApp_Mobile
flutter pub get
# Configurar lib/src/core/config/supabase_config.dart
flutter run
```

### 4. Configurar CourierApp Mobile

```bash
cd Napoli_CourierApp_Mobile
flutter pub get
# Configurar lib/src/core/config/supabase_config.dart
flutter run
```

---

## ⚙️ Configuración

### Variables de Entorno

#### AdminDashboard (.env.local)
```env
NEXT_PUBLIC_SUPABASE_URL=tu_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=tu_supabase_anon_key
```

#### Apps Móviles (supabase_config.dart)
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'tu_supabase_url';
  static const String supabaseAnonKey = 'tu_supabase_anon_key';
}
```

### Base de Datos

1. Crear proyecto en [Supabase](https://supabase.com)
2. Ejecutar los scripts SQL en orden:
   - `schema.sql`: Esquema completo de la base de datos
   - `stored_procedures.sql`: Procedimientos almacenados
   - `seed.sql`: Datos de prueba (opcional)

3. Habilitar Realtime en las tablas:
   - `orders`
   - `drivers`
   - `notifications`

4. Configurar Storage Buckets:
   - `restaurant-assets` (público)
   - `product-images` (público)
   - `driver-photos` (público)
   - `driver-documents` (privado)

---

## 📚 Documentación

El proyecto incluye documentación completa en archivos Markdown:

- **[NAPOLI_GUIDE.md](NAPOLI_GUIDE.md)**: Guía maestra de sincronización y arquitectura
- **[INTEGRATION_PLAN.md](INTEGRATION_PLAN.md)**: Plan de integración entre proyectos
- **[NAPOLI_ADMINDASHBOARD_ANALYSIS.md](NAPOLI_ADMINDASHBOARD_ANALYSIS.md)**: Análisis del Dashboard
- **[NAPOLI_COURIERAPP_ANALYSIS.md](NAPOLI_COURIERAPP_ANALYSIS.md)**: Análisis de CourierApp
- **[NAPOLI_CUSTOMERAPP_ANALYSIS.md](NAPOLI_CUSTOMERAPP_ANALYSIS.md)**: Análisis de CustomerApp
- **[COURIERAPP_FINAL_STATE.md](COURIERAPP_FINAL_STATE.md)**: Estado final de CourierApp
- **[CUSTOMERAPP_QUICKSTART.md](CUSTOMERAPP_QUICKSTART.md)**: Guía rápida de CustomerApp
- **[AI_TRAINING_GUIDE.md](AI_TRAINING_GUIDE.md)**: Guía de entrenamiento para IA
- **[AI_INITIALIZATION_PROMPT.md](AI_INITIALIZATION_PROMPT.md)**: Prompt de inicialización para IA

---

## 📂 Estructura del Proyecto

```
Proyecto_Napoli_APPS/
├── Napoli_AdminDashboard_Web/     # Dashboard web Next.js
│   ├── src/
│   │   ├── app/                   # App Router de Next.js
│   │   ├── components/            # Componentes React
│   │   ├── lib/                   # Utilidades y configuración
│   │   └── types/                 # Tipos TypeScript
│   ├── public/                    # Archivos estáticos
│   └── package.json
│
├── Napoli_CustomerApp_Mobile/     # App móvil de clientes Flutter
│   ├── lib/
│   │   ├── src/
│   │   │   ├── core/             # Configuración y utilidades
│   │   │   ├── data/             # Capa de datos (repositories, data sources)
│   │   │   ├── domain/           # Capa de dominio (entities, use cases)
│   │   │   └── presentation/     # Capa de presentación (UI, BLoC)
│   │   └── main.dart
│   ├── SQL/                       # Scripts SQL de CustomerApp
│   └── pubspec.yaml
│
├── Napoli_CourierApp_Mobile/      # App móvil de repartidores Flutter
│   ├── lib/
│   │   ├── src/
│   │   │   ├── core/             # Configuración y utilidades
│   │   │   ├── data/             # Capa de datos
│   │   │   ├── domain/           # Capa de dominio
│   │   │   └── presentation/     # Capa de presentación
│   │   └── main.dart
│   └── pubspec.yaml
│
├── README.md                      # Este archivo
├── NAPOLI_GUIDE.md               # Guía maestra
├── INTEGRATION_PLAN.md           # Plan de integración
└── [otros archivos de documentación]
```

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Guías de Contribución

- Seguir Clean Architecture en apps móviles
- Usar Stored Procedures para lógica de negocio
- Mantener sincronización de ENUMs entre proyectos
- Documentar cambios en archivos MD correspondientes
- Incluir `restaurant_id` en todas las queries multi-tenant

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

## 👥 Autores

- **Equipo Napoli** - *Desarrollo inicial*

---

## 🙏 Agradecimientos

- [Supabase](https://supabase.com) por el excelente BaaS
- [Flutter](https://flutter.dev) por el framework móvil
- [Next.js](https://nextjs.org) por el framework web
- [shadcn/ui](https://ui.shadcn.com) por los componentes UI

---

## 📞 Contacto

Para preguntas o soporte, por favor abre un issue en GitHub.

---

<div align="center">
  <strong>Hecho con ❤️ para pizzerías</strong>
</div>