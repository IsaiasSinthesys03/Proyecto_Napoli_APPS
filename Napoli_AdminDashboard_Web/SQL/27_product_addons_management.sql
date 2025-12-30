-- ============================================================================
-- STORED PROCEDURES: Product-Addon Assignment
-- ============================================================================
-- Propósito: Asignar y desasignar complementos a productos
-- ============================================================================

-- ============================================================================
-- 1. ASSIGN ADDONS TO PRODUCT
-- ============================================================================
CREATE OR REPLACE FUNCTION assign_addons_to_product(
  p_product_id UUID,
  p_addon_ids UUID[]
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_addon_id UUID;
BEGIN
  RAISE NOTICE '🔍 DEBUG - assign_addons_to_product called';
  RAISE NOTICE '📦 DATA - product_id: %, addon_ids: %', p_product_id, p_addon_ids;
  
  -- Delete existing assignments for this product
  DELETE FROM product_addons
  WHERE product_id = p_product_id;
  
  RAISE NOTICE '✅ Deleted existing addon assignments';
  
  -- Insert new assignments
  IF p_addon_ids IS NOT NULL AND array_length(p_addon_ids, 1) > 0 THEN
    FOREACH v_addon_id IN ARRAY p_addon_ids
    LOOP
      INSERT INTO product_addons (product_id, addon_id)
      VALUES (p_product_id, v_addon_id)
      ON CONFLICT DO NOTHING;
    END LOOP;
    
    RAISE NOTICE '✅ SUCCESS - Assigned % addons to product', array_length(p_addon_ids, 1);
  ELSE
    RAISE NOTICE '✅ SUCCESS - No addons to assign';
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in assign_addons_to_product: %', SQLERRM;
    RAISE EXCEPTION 'Error al asignar complementos: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. GET PRODUCT ADDONS
-- ============================================================================
CREATE OR REPLACE FUNCTION get_product_addons(
  p_product_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_addon_ids JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - get_product_addons called';
  RAISE NOTICE '📦 DATA - product_id: %', p_product_id;
  
  SELECT json_agg(addon_id)
  INTO v_addon_ids
  FROM product_addons
  WHERE product_id = p_product_id;
  
  RAISE NOTICE '✅ SUCCESS - Returning addons for product';
  
  RETURN COALESCE(v_addon_ids, '[]'::json);
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in get_product_addons: %', SQLERRM;
    RAISE EXCEPTION 'Error al obtener complementos del producto: %', SQLERRM;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION assign_addons_to_product IS 'Asigna complementos a un producto (reemplaza asignaciones existentes)';
COMMENT ON FUNCTION get_product_addons IS 'Obtiene los IDs de complementos asignados a un producto';
