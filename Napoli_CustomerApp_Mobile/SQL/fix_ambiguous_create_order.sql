-- ============================================================================
-- FIX: Resolver ambigüedad en create_customer_order (Error PGRST203)
-- ============================================================================
-- Este script elimina la versión antigua de la función que entra en conflicto
-- con la nueva versión que incluye 'p_customer_notes'.
-- ============================================================================

-- Eliminar la versión vieja (9 parámetros)
DROP FUNCTION IF EXISTS create_customer_order(UUID, UUID, JSONB, JSONB, TEXT, INT, INT, INT, INT);

-- Nota: No es necesario recrear la nueva si ya existe, pero si quieres asegurarte
-- de que la nueva está correcta, puedes ejecutar después el archivo 09_create_customer_order.sql
