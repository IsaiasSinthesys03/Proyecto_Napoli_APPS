-- ============================================================================
-- FIX: Liberar pedidos en "limbo" (Ready pero asignados)
-- ============================================================================

-- El problema es que el pedido #0033 está en estado 'ready' PERO ya tiene driver_id.
-- La app busca:
-- 1. Disponibles: status='ready' AND driver_id IS NULL
-- 2. Activos: driver_id=YO AND status IN ('accepted', 'delivering')

-- El pedido #0033 no cumple ninguna de las dos condiciones.
-- Vamos a "desasignarlo" para que aparezca en Disponibles.

UPDATE orders
SET driver_id = NULL
WHERE status = 'ready' AND driver_id IS NOT NULL;

-- Verificación
SELECT id, order_number, status, driver_id 
FROM orders 
WHERE status = 'ready';
