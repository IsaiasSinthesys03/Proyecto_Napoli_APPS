-- ============================================================================
-- MIGRATION: Add image_url to addons table
-- ============================================================================
-- Propósito: Agregar campo image_url que falta en la tabla addons
-- ============================================================================

-- Add image_url column to addons table
ALTER TABLE addons 
ADD COLUMN IF NOT EXISTS image_url VARCHAR;

-- Add comment
COMMENT ON COLUMN addons.image_url IS 'URL de la imagen del complemento';
