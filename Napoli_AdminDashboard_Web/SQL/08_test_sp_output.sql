-- ============================================================================
-- TEST: Ver exactamente qué devuelve get_admin_orders
-- ============================================================================

-- Ejecuta esto para ver la estructura exacta de datos
SELECT get_admin_orders(
  '06a5284c-0ef8-4efe-a882-ce1fc8319452'::uuid,
  1,
  NULL,
  NULL
);

-- Esto te mostrará el JSON completo que está devolviendo el SP
-- Compárteme el resultado completo para ver qué estructura tiene
