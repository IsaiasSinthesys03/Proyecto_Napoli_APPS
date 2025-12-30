-- ============================================================================
-- DIAGNÓSTICO: Probar get_admin_orders
-- ============================================================================
-- Ejecuta estas queries para diagnosticar el problema
-- ============================================================================

-- 1. Verificar que el stored procedure existe
SELECT 
    proname as function_name,
    pg_get_function_arguments(oid) as arguments,
    pg_get_functiondef(oid) as definition
FROM pg_proc
WHERE proname = 'get_admin_orders';

-- 2. Obtener tu restaurant_id actual
SELECT 
    ra.restaurant_id,
    ra.email,
    r.name as restaurant_name
FROM restaurant_admins ra
JOIN restaurants r ON ra.restaurant_id = r.id
LIMIT 1;

-- 3. Probar el SP con NULL (sin filtros)
-- REEMPLAZA 'TU-RESTAURANT-ID' con el ID del paso 2
SELECT get_admin_orders(
  'TU-RESTAURANT-ID'::uuid,  -- Reemplaza con tu restaurant_id
  1,      -- página 1
  NULL,   -- sin filtro de status
  NULL    -- sin filtro de order_number
);

-- 4. Probar con array vacío (esto podría ser el problema)
SELECT get_admin_orders(
  'TU-RESTAURANT-ID'::uuid,
  1,
  ARRAY[]::TEXT[],  -- array vacío
  NULL
);

-- 5. Probar con filtro de status
SELECT get_admin_orders(
  'TU-RESTAURANT-ID'::uuid,
  1,
  ARRAY['pending', 'accepted']::TEXT[],
  NULL
);

-- 6. Ver si hay órdenes en la BD
SELECT 
    id,
    order_number,
    status,
    total_cents,
    created_at
FROM orders
WHERE restaurant_id = 'TU-RESTAURANT-ID'::uuid
ORDER BY created_at DESC
LIMIT 5;
