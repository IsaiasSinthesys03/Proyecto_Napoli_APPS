# Napoli Pizza App - UI-Only Version

## 📱 Overview

Esta es una aplicación Flutter UI-only para pedidos de pizzería, construida siguiendo una arquitectura V5 adaptada (feature-first) con Flutter 3.35.6 y Dart 3.9.2.

La aplicación es una versión mejorada e independiente basada en el proyecto de referencia ubicado en `inspiracion/`, pero **sin dependencias externas** (Firebase, Google Maps, Razorpay, etc.). Se enfoca exclusivamente en la UI y widgets reutilizables.

## 🏗️ Arquitectura

La app sigue una arquitectura V5 adaptada (simplificada para UI-only):

```
lib/
├── main.dart              # Punto de entrada
└── src/
    ├── app.dart           # Widget raíz (MaterialApp)
    ├── di.dart            # Inyección de dependencias (singletons)
    │
    ├── core/              # Módulos transversales
    │   ├── core_domain/   # Contratos compartidos
    │   │   ├── entities/      # Product
    │   │   └── repositories/  # ProductRepository
    │   ├── core_ui/       # Theme, widgets genéricos
    │   │   ├── theme.dart
    │   │   ├── theme_controller.dart
    │   │   ├── theme_provider.dart
    │   │   └── widgets/   # AppScaffold, ProductCard, SafeImage, etc.
    │   └── services/      # CartService (in-memory)
    │
    └── features/          # Funcionalidades (feature-first)
        ├── splash/
        ├── auth/          # LoginScreen
        ├── home/          # HomeScreen (listado de productos)
        ├── detail/        # DetailScreen (detalle de producto)
        ├── cart/          # CartScreen (carrito con cupones)
        ├── maps/          # MapsScreen (UI placeholder)
        └── products/      # MockProductRepository
```

## ✨ Características Implementadas

### Pantallas
- ✅ **Splash Screen**: Pantalla inicial con navegación automática
- ✅ **Home Screen**: Listado de productos (horizontal + vertical) usando repository mock
- ✅ **Detail Screen**: Detalles del producto con selección de tamaño y extras
- ✅ **Cart Screen**: Carrito con cupones de descuento y cálculo de totales
- ✅ **Login Screen**: Pantalla de autenticación (UI-only)
- ✅ **Maps Screen**: Placeholder de mapa sin integración real

### Widgets Reutilizables
- `AppScaffold`: Scaffold genérico
- `AppHeader`: Header con localización y toggle de tema
- `AppFooter`: Footer flotante con botón de carrito
- `ProductCard`: Tarjeta de producto horizontal
- `ProductListItem`: Item de lista vertical
- `SizeSelector`: Selector de tamaño (S/M/L)
- `QuantitySelector`: Control +/-
- `SafeImage`: Image.asset con fallback automático
- `ThemeToggle`: Botón para alternar tema claro/oscuro

### Funcionalidades
- ✅ **Tema Dinámico**: Alternar entre modo claro y oscuro (sin paquetes externos)
- ✅ **Carrito In-Memory**: Agregar/eliminar items usando `ValueNotifier`
- ✅ **Cupones de Descuento**: Sistema de cupones mock (`PIZZA10`, `SAVE20`, `MEGA50`)
- ✅ **Repository Pattern**: Contrato + implementación mock para productos
- ✅ **Navegación**: Navigator.push/pop (preparado para migrar a GoRouter)

## 🎨 Assets

Los recursos están ubicados en `inspiracion/assets/`:
- **Animaciones**: `eating.json`, `pizza.json` (Lottie - no integradas aún)
- **Fuentes**: Avenir FF (declaradas en pubspec.yaml)
- **Imágenes**: `flamenco-waiting.png`, `payment.png`
- **Placeholder**: Icono de pizza cuando faltan imágenes

## 🚀 Cómo Ejecutar

### Requisitos
- Flutter 3.35.6 o superior
- Dart 3.9.2 o superior

### Instalación

```powershell
# 1. Obtener dependencias
flutter pub get

# 2. Analizar código
flutter analyze

# 3. Ejecutar en modo debug
flutter run

# 4. Ejecutar en modo release
flutter run --release
```

### Cupones Disponibles (Mock)
- `PIZZA10` → 10% descuento
- `SAVE20` → 20% descuento
- `MEGA50` → 50% descuento

## 📦 Dependencias

La app **NO usa dependencias externas** excepto las básicas de Flutter:
- `flutter/material.dart` - Framework UI
- `flutter/widgets.dart` - Widgets base

**Paquetes NO incluidos** (presentes en el proyecto de referencia):
- ❌ Firebase (auth, firestore, storage)
- ❌ Google Maps
- ❌ Razorpay (pagos)
- ❌ Provider (reemplazado por ValueNotifier)
- ❌ Lottie (animaciones declaradas pero no usadas)
- ❌ GetIt (DI simplificado con singletons)
- ❌ GoRouter (navegación directa con Navigator)

## 📝 Notas de Desarrollo

### Carpeta `inspiracion/`
Es solo para **referencia**. Contiene el proyecto original con todas sus dependencias y está **excluida del análisis** (`analysis_options.yaml`). Puede eliminarse después del desarrollo.

### Diferencias con el Proyecto de Referencia
1. **Sin backend**: Todos los datos son mock/in-memory
2. **Sin autenticación real**: LoginScreen es UI-only
3. **Sin pagos**: Checkout muestra mensaje informativo
4. **Sin mapa real**: MapsScreen es un placeholder
5. **Theme management**: InheritedNotifier en lugar de Provider
6. **Assets seguros**: SafeImage con fallback automático

### Próximos Pasos (Opcional)
Si deseas completar la arquitectura V5:
1. Migrar a `GoRouter` para navegación declarativa
2. Integrar `GetIt` para DI robusto
3. Añadir animaciones Lottie
4. Implementar UseCases para lógica de negocio
5. Crear más contratos en `core_domain`
6. Integrar Firebase/backend real

## 🧪 Testing

Actualmente la app no tiene tests unitarios/integración. Para añadir:

```powershell
# Crear archivo de test
# test/features/products/data/mock_product_repository_test.dart

flutter test
```

## 🐛 Issues Conocidos

1. **Análisis estático**: 4 avisos informativos (deprecaciones de Flutter):
   - `ThemeData.background` → Usar `surface` en futuras versiones
   - `Color.withOpacity()` → Usar `withValues()` (Flutter 3.18+)
   - Super-parameters sugerido en `ThemeProvider`

2. **Assets**: Imágenes de pizza usan placeholder (icono) por defecto

## 📄 Licencia

Este proyecto es un ejemplo educativo basado en el código de referencia en `inspiracion/`.

## 👥 Créditos

- **Referencia**: Proyecto original en `inspiracion/`
- **Arquitectura**: V5 (feature-first) adaptada para UI-only
- **Framework**: Flutter 3.35.6 / Dart 3.9.2

---

**Nota**: Esta es una versión UI-only enfocada en demostrar estructura y widgets. No incluye integración con servicios externos ni persistencia real.
