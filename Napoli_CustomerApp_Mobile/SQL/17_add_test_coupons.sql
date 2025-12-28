-- ============================================================================
-- SCRIPT: Agregar Cupones de Prueba
-- ============================================================================
-- Propósito: Crear cupones de ejemplo para testing
-- Autor: AI Assistant
-- Fecha: 2024-12-27
-- ============================================================================

-- IMPORTANTE: Reemplaza 'YOUR_RESTAURANT_ID' con tu restaurant_id real
-- Puedes obtenerlo con: SELECT id FROM restaurants LIMIT 1;

-- ============================================================================
-- 1. CUPÓN DE PORCENTAJE - 10% de descuento
-- ============================================================================
INSERT INTO coupons (
  restaurant_id,
  code,
  description,
  type,
  discount_percentage,
  minimum_order_cents,
  is_active,
  valid_from,
  valid_until,
  max_uses,
  max_uses_per_customer
)
VALUES (
  'YOUR_RESTAURANT_ID',  -- ⚠️ CAMBIAR ESTO
  'WELCOME10',
  '10% de descuento en tu pedido',
  'percentage',
  10,                    -- 10%
  5000,                  -- Mínimo $50.00
  true,
  NOW(),
  NOW() + INTERVAL '30 days',
  100,                   -- Máximo 100 usos totales
  1                      -- 1 uso por cliente
);

-- ============================================================================
-- 2. CUPÓN DE MONTO FIJO - $20 de descuento
-- ============================================================================
INSERT INTO coupons (
  restaurant_id,
  code,
  description,
  type,
  discount_amount_cents,
  minimum_order_cents,
  is_active,
  valid_from,
  valid_until,
  max_uses,
  max_uses_per_customer
)
VALUES (
  'YOUR_RESTAURANT_ID',  -- ⚠️ CAMBIAR ESTO
  'SAVE20',
  '$20 de descuento en pedidos mayores a $100',
  'fixed',
  2000,                  -- $20.00
  10000,                 -- Mínimo $100.00
  true,
  NOW(),
  NOW() + INTERVAL '60 days',
  50,                    -- Máximo 50 usos totales
  2                      -- 2 usos por cliente
);

-- ============================================================================
-- 3. CUPÓN PARA PRIMERA ORDEN - 15% descuento
-- ============================================================================
INSERT INTO coupons (
  restaurant_id,
  code,
  description,
  type,
  discount_percentage,
  minimum_order_cents,
  maximum_discount_cents,
  is_active,
  first_order_only,
  valid_from,
  valid_until,
  max_uses_per_customer
)
VALUES (
  'YOUR_RESTAURANT_ID',  -- ⚠️ CAMBIAR ESTO
  'FIRST15',
  '15% de descuento en tu primera orden (máx $30)',
  'percentage',
  15,                    -- 15%
  3000,                  -- Mínimo $30.00
  3000,                  -- Descuento máximo $30.00
  true,
  true,                  -- Solo primera orden
  NOW(),
  NOW() + INTERVAL '90 days',
  1                      -- 1 uso por cliente
);

-- ============================================================================
-- 4. CUPÓN ILIMITADO - 5% siempre
-- ============================================================================
INSERT INTO coupons (
  restaurant_id,
  code,
  description,
  type,
  discount_percentage,
  is_active,
  valid_from
)
VALUES (
  'YOUR_RESTAURANT_ID',  -- ⚠️ CAMBIAR ESTO
  'ALWAYS5',
  '5% de descuento siempre',
  'percentage',
  5,                     -- 5%
  true,
  NOW()
  -- Sin valid_until = nunca expira
  -- Sin max_uses = usos ilimitados
);

-- ============================================================================
-- 5. CUPÓN PARA CLIENTE ESPECÍFICO
-- ============================================================================
-- Primero necesitas el customer_id del cliente
-- SELECT id FROM customers WHERE email = 'cliente@example.com';

INSERT INTO coupons (
  restaurant_id,
  code,
  description,
  type,
  discount_percentage,
  is_active,
  valid_from,
  valid_until,
  specific_customer_ids,
  max_uses_per_customer
)
VALUES (
  'YOUR_RESTAURANT_ID',  -- ⚠️ CAMBIAR ESTO
  'VIP20',
  '20% de descuento exclusivo VIP',
  'percentage',
  20,                    -- 20%
  true,
  NOW(),
  NOW() + INTERVAL '365 days',
  ARRAY['CUSTOMER_ID_1', 'CUSTOMER_ID_2']::UUID[],  -- ⚠️ CAMBIAR ESTO
  5                      -- 5 usos por cliente VIP
);

-- ============================================================================
-- VERIFICAR CUPONES CREADOS
-- ============================================================================
SELECT 
  code,
  description,
  type,
  discount_percentage,
  discount_amount_cents,
  is_active,
  valid_until,
  current_uses,
  max_uses
FROM coupons
WHERE restaurant_id = 'YOUR_RESTAURANT_ID'  -- ⚠️ CAMBIAR ESTO
ORDER BY created_at DESC;

-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================
-- 
-- TIPOS DE CUPÓN:
-- - 'percentage': Descuento por porcentaje (usa discount_percentage)
-- - 'fixed': Descuento de monto fijo (usa discount_amount_cents)
--
-- CAMPOS IMPORTANTES:
-- - minimum_order_cents: Monto mínimo de orden para aplicar cupón
-- - maximum_discount_cents: Descuento máximo (útil para porcentajes)
-- - valid_from / valid_until: Fechas de vigencia
-- - max_uses: Límite de usos totales del cupón
-- - max_uses_per_customer: Límite de usos por cliente
-- - first_order_only: true = solo primera orden del cliente
-- - specific_customer_ids: Array de UUIDs de clientes específicos
-- - is_active: true/false para activar/desactivar
--
-- PRECIOS EN CENTAVOS:
-- $1.00 = 100 centavos
-- $10.00 = 1000 centavos
-- $50.00 = 5000 centavos
-- $100.00 = 10000 centavos
--
-- ============================================================================
