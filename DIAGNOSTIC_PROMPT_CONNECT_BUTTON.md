# 🔍 PROMPT DE DIAGNÓSTICO: Botón Conectar/Desconectar No Funciona

## CONTEXTO DEL PROBLEMA

Eres un experto en Flutter, Dart, Clean Architecture y Supabase. Tu misión es diagnosticar por qué el botón **Conectar/Desconectar** en la app `Napoli_CourierApp_Mobile` no funciona correctamente para un usuario específico (Andri Yael), cuando en la versión original del desarrollador SÍ funciona perfectamente.

### Situación Actual

- **Versión Original (Funciona ✅):** El botón conectar/desconectar actualiza correctamente el estado `is_online` en la base de datos y el repartidor aparece en el Admin Dashboard
- **Versión Modificada (No Funciona ❌):** El usuario implementó funcionalidad de coordenadas/ubicación y ahora el botón no actualiza el estado correctamente

### Síntomas Observados

1. Al presionar el botón "CONECTAR", visualmente cambia a "DESCONECTAR" en la UI
2. Sin embargo, el estado `is_online` en la base de datos NO se actualiza (permanece en `false`)
3. El repartidor NO aparece como conectado en el Admin Dashboard
4. El campo `updated_at` en la tabla `drivers` SÍ se actualiza, lo que indica que algo está llegando a la base de datos

---

## ARQUITECTURA DEL SISTEMA

### 1. Base de Datos (PostgreSQL/Supabase)

#### Tabla `drivers`
```sql
CREATE TABLE drivers (
  id UUID PRIMARY KEY,
  restaurant_id UUID NOT NULL,
  name VARCHAR NOT NULL,
  email VARCHAR UNIQUE NOT NULL,
  phone VARCHAR NOT NULL,
  vehicle_type VARCHAR NOT NULL,
  license_plate VARCHAR,
  status VARCHAR DEFAULT 'pending', -- 'pending', 'approved', 'active', 'inactive'
  is_online BOOLEAN DEFAULT false,  -- ← CAMPO CRÍTICO
  photo_url VARCHAR,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT drivers_restaurant_id_phone_key UNIQUE (restaurant_id, phone)
);
```

#### Stored Procedure: `toggle_driver_online_status`
```sql
CREATE OR REPLACE FUNCTION toggle_driver_online_status(
  p_driver_id UUID,
  p_is_online BOOLEAN
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Actualizar estado online del repartidor
  UPDATE drivers
  SET 
    is_online = p_is_online,
    updated_at = NOW()
  WHERE id = p_driver_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Repartidor no encontrado';
  END IF;
  
  -- Retornar resultado
  SELECT json_build_object(
    'success', true,
    'is_online', p_is_online
  )
  INTO v_result;
  
  RETURN v_result;
END;
$$;
```

**IMPORTANTE:** Este stored procedure recibe el `driver_id` (UUID) y actualiza directamente la fila correspondiente.

---

### 2. Arquitectura Flutter (Clean Architecture)

```
lib/
├── features/
│   └── dashboard/
│       ├── domain/
│       │   ├── entities/driver.dart
│       │   └── repositories/dashboard_repository.dart
│       ├── data/
│       │   ├── datasources/
│       │   │   └── supabase_dashboard_datasource.dart  ← CLAVE
│       │   └── repositories/
│       │       └── dashboard_repository_impl.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── dashboard_cubit.dart  ← CLAVE
│           │   └── dashboard_state.dart
│           └── screens/
│               └── dashboard_screen.dart  ← UI DEL BOTÓN
```

---

### 3. Flujo de Ejecución del Botón Conectar/Desconectar

#### Paso 1: UI (dashboard_screen.dart)
```dart
FloatingActionButton.extended(
  onPressed: () {
    context.read<DashboardCubit>().toggleOnlineStatus();  // ← LLAMADA
  },
  backgroundColor: isOnline ? AppColors.primaryRed : AppColors.onlineGreen,
  icon: Icon(isOnline ? Icons.power_settings_new : Icons.play_arrow),
  label: Text(isOnline ? 'DESCONECTAR' : 'CONECTAR'),
)
```

#### Paso 2: Cubit (dashboard_cubit.dart)
```dart
void toggleOnlineStatus() async {
  if (state is DashboardLoaded) {
    final currentState = state as DashboardLoaded;
    final newStatus = !currentState.isOnline;
    
    try {
      // Llamar al repositorio
      final success = await repository.setOnlineStatus(
        currentState.driver.id,  // ← ID DEL DRIVER
        newStatus,
      );
      
      if (success) {
        emit(DashboardLoaded(
          driver: currentState.driver,
          isOnline: newStatus,  // ← ACTUALIZA ESTADO LOCAL
        ));
      }
    } catch (e) {
      // Manejar error
    }
  }
}
```

#### Paso 3: Repository (dashboard_repository_impl.dart)
```dart
@override
Future<bool> setOnlineStatus(String driverId, bool isOnline) async {
  return await dataSource.setOnlineStatus(driverId, isOnline);
}
```

#### Paso 4: DataSource (supabase_dashboard_datasource.dart)
```dart
Future<bool> setOnlineStatus(String driverId, bool isOnline) async {
  try {
    final response = await client.rpc(
      'toggle_driver_online_status',  // ← STORED PROCEDURE
      params: {
        'p_driver_id': driverId,  // ← PARÁMETRO CRÍTICO
        'p_is_online': isOnline,
      },
    );

    if (response != null && response['success'] == true) {
      return response['is_online'] as bool;
    }

    return isOnline;
  } catch (e) {
    print('❌ ERROR - Failed to update online status: $e');
    rethrow;
  }
}
```

---

## DIAGNÓSTICO REQUERIDO

### TAREA 1: Analizar el Flujo de Autenticación

1. **Verificar cómo se obtiene el `driver.id` al hacer login:**
   - Archivo: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
   - Método: `login()`
   - **Pregunta crítica:** ¿El `id` que se guarda en `SharedPreferences` es el User UID de `auth.users` o el ID de la tabla `drivers`?

2. **Revisar el stored procedure `login_driver`:**
   - Este procedure se llama durante el login
   - **Verificar:** ¿Qué ID retorna? ¿El de `auth.users` o el de `drivers`?

3. **Comparar IDs:**
   - ID guardado en la app (ver logs de debug)
   - ID en la tabla `drivers` para el usuario Andri Yael
   - ID en `auth.users` para el email `andriyaelr13@gmail.com`

### TAREA 2: Buscar Cambios Relacionados con Coordenadas

El usuario mencionó que implementó funcionalidad de coordenadas. Busca:

1. **Nuevos campos en la tabla `drivers`:**
   ```sql
   -- ¿Se agregaron campos como?
   latitude DOUBLE PRECISION,
   longitude DOUBLE PRECISION,
   last_location_update TIMESTAMPTZ
   ```

2. **Modificaciones en `toggle_driver_online_status`:**
   - ¿Se agregó lógica para actualizar coordenadas?
   - ¿Hay validaciones nuevas que puedan fallar?

3. **Cambios en `supabase_dashboard_datasource.dart`:**
   - ¿Se agregaron parámetros adicionales al RPC call?
   - ¿Hay lógica de geolocalización que pueda interferir?

4. **Cambios en `dashboard_cubit.dart`:**
   - ¿Se agregó lógica de permisos de ubicación?
   - ¿Hay `await` faltantes que causen race conditions?

### TAREA 3: Comparar con la Versión Original

**Archivos clave a comparar:**

1. `lib/features/dashboard/data/datasources/supabase_dashboard_datasource.dart`
2. `lib/features/dashboard/presentation/cubit/dashboard_cubit.dart`
3. `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`
4. `SQL/30_toggle_driver_online_status.sql`

**Buscar diferencias en:**
- Parámetros de funciones
- Llamadas RPC
- Manejo de errores
- Lógica condicional nueva

### TAREA 4: Revisar Logs y Errores

Pide al usuario que ejecute la app con logs de debug activados:

```dart
// En supabase_dashboard_datasource.dart
print('🔍 DEBUG - setOnlineStatus called: driverId=$driverId, isOnline=$isOnline');
print('📦 RESPONSE: $response');
```

**Verificar:**
1. ¿Se llama al método `setOnlineStatus`?
2. ¿Qué `driverId` se está enviando?
3. ¿Qué respuesta retorna el stored procedure?
4. ¿Hay excepciones silenciadas?

### TAREA 5: Verificar Permisos de Supabase

```sql
-- Verificar permisos de ejecución
GRANT EXECUTE ON FUNCTION toggle_driver_online_status(UUID, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION toggle_driver_online_status(UUID, BOOLEAN) TO service_role;
```

---

## POSIBLES CAUSAS (HIPÓTESIS)

### Hipótesis 1: ID Incorrecto
- El `driver.id` que se pasa a `setOnlineStatus()` no coincide con ningún registro en la tabla `drivers`
- El stored procedure falla silenciosamente con `NOT FOUND`
- **Solución:** Verificar que el ID guardado en login sea el correcto

### Hipótesis 2: Parámetros Adicionales
- La versión modificada agregó parámetros de coordenadas al RPC call
- El stored procedure espera solo 2 parámetros pero recibe más
- **Solución:** Revisar la firma del stored procedure vs los parámetros enviados

### Hipótesis 3: Race Condition
- La lógica de geolocalización hace un `await` que bloquea la actualización
- El estado local se actualiza pero la llamada a la BD nunca completa
- **Solución:** Revisar el orden de `await` en el cubit

### Hipótesis 4: Error Silenciado
- Hay un `try-catch` que captura el error pero no lo muestra
- El usuario no ve el error real
- **Solución:** Agregar logs en todos los catch blocks

### Hipótesis 5: Stored Procedure Modificado
- El stored procedure fue modificado para incluir validaciones de ubicación
- Esas validaciones fallan y lanzan excepción
- **Solución:** Comparar el código SQL actual vs el original

---

## PLAN DE ACCIÓN SUGERIDO

### Fase 1: Recolección de Información (15 min)

1. Ejecutar query de diagnóstico:
```sql
-- Ver el registro actual de Andri Yael
SELECT id, name, email, is_online, updated_at 
FROM drivers 
WHERE email = 'andriyaelr13@gmail.com';

-- Ver el User UID en auth
SELECT id, email FROM auth.users 
WHERE email = 'andriyaelr13@gmail.com';
```

2. Revisar logs de la app al presionar "Conectar"

3. Comparar archivos modificados con `git diff` (si usa control de versiones)

### Fase 2: Pruebas Aisladas (20 min)

1. **Test directo del stored procedure:**
```sql
SELECT toggle_driver_online_status(
  '73069c85-ef83-49e0-801a-7fd0bb9715aa',  -- ID actual en drivers
  true
);
```

2. **Test desde la app con logs:**
```dart
// Agregar en dashboard_cubit.dart
print('🔍 Toggling status for driver: ${currentState.driver.id}');
print('🔍 Current status: ${currentState.isOnline}');
print('🔍 New status will be: $newStatus');
```

### Fase 3: Comparación de Código (30 min)

1. Comparar `supabase_dashboard_datasource.dart` línea por línea
2. Buscar cualquier referencia a `latitude`, `longitude`, `location`, `coordinates`
3. Verificar si hay nuevos parámetros en el RPC call

### Fase 4: Solución (Variable)

Dependiendo de lo encontrado, aplicar el fix correspondiente.

---

## INFORMACIÓN ADICIONAL

### Estructura de `auth.users` vs `drivers`

**IMPORTANTE:** El sistema usa el **email** como vínculo entre `auth.users` y `drivers`, NO el ID.

- Cuando un usuario hace login, Supabase Auth lo autentica por email
- Luego, el stored procedure `login_driver` busca en `drivers` por ese email
- Retorna el registro completo del driver (con su ID de la tabla `drivers`)
- Ese ID se guarda en `SharedPreferences` y se usa para todas las operaciones

**Por lo tanto:** El `driver.id` usado en la app es el ID de la tabla `drivers`, no el User UID de `auth.users`.

### Comandos Útiles

```bash
# Ver diferencias en Git
git diff HEAD~5 lib/features/dashboard/

# Buscar referencias a coordenadas
grep -r "latitude\|longitude\|location" lib/features/dashboard/

# Ver logs de Flutter
flutter logs
```

---

## ENTREGABLES ESPERADOS

1. **Diagnóstico detallado** con la causa raíz del problema
2. **Comparación de código** entre versión original y modificada
3. **Plan de solución** paso a paso
4. **Código corregido** si es posible identificar el fix

---

## 📊 REPORTE FINAL OBLIGATORIO

**IMPORTANTE:** Al finalizar el diagnóstico, debes generar un reporte completo en formato Markdown con la siguiente estructura:

```markdown
# REPORTE DE DIAGNÓSTICO: Botón Conectar/Desconectar

## 1. RESUMEN EJECUTIVO
- **Problema identificado:** [Descripción breve]
- **Causa raíz:** [Explicación técnica]
- **Severidad:** [Alta/Media/Baja]
- **Tiempo estimado de corrección:** [X horas]

## 2. ANÁLISIS DETALLADO

### 2.1 Archivos Analizados
- Lista de archivos revisados con rutas completas
- Cambios detectados en cada archivo

### 2.2 Diferencias Encontradas
```diff
// Código original
[código antes]

// Código modificado
[código después]
```

### 2.3 Flujo de Ejecución Actual
- Paso a paso de qué ocurre cuando se presiona el botón
- Punto exacto donde falla

### 2.4 Logs y Evidencias
- Logs de consola relevantes
- Queries SQL ejecutadas
- Respuestas de la base de datos

## 3. CAUSA RAÍZ CONFIRMADA

[Explicación detallada y técnica de por qué falla]

## 4. SOLUCIÓN PROPUESTA

### 4.1 Cambios Necesarios

**Archivo 1:** `[ruta/al/archivo.dart]`
```dart
// Código corregido
```

**Archivo 2:** `[ruta/al/archivo.sql]`
```sql
-- Código corregido
```

### 4.2 Pasos de Implementación
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

### 4.3 Pruebas de Validación
- [ ] Test 1: [Descripción]
- [ ] Test 2: [Descripción]
- [ ] Test 3: [Descripción]

## 5. PREVENCIÓN FUTURA

- Recomendaciones para evitar este tipo de errores
- Mejoras sugeridas en la arquitectura
- Tests unitarios a implementar

## 6. ANEXOS

### 6.1 Queries SQL de Diagnóstico Ejecutadas
```sql
[queries usadas]
```

### 6.2 Comparación de Versiones
| Aspecto | Versión Original | Versión Modificada |
|---------|------------------|-------------------|
| [Item 1] | [Valor] | [Valor] |
| [Item 2] | [Valor] | [Valor] |

---

**Fecha del diagnóstico:** [Fecha]
**Analizado por:** [AI Assistant]
**Para revisión de:** Braulio Isaías (Desarrollador Original)
```

**INSTRUCCIONES FINALES:**

1. Copia este reporte completo
2. Pásaselo a Braulio Isaías (el desarrollador original)
3. Él revisará el diagnóstico y validará la solución propuesta
4. NO implementes cambios sin su aprobación

---

## NOTAS FINALES

- El problema es **específico de código**, no de base de datos (funciona en una versión pero no en otra)
- La implementación de coordenadas es el cambio más reciente y probable culpable
- El síntoma de que `updated_at` cambia pero `is_online` no, sugiere que el stored procedure SÍ se ejecuta pero con parámetros incorrectos o falla en alguna validación

¡Buena suerte con el diagnóstico! 🔍
