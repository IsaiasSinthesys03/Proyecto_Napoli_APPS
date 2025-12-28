-- ========================================
-- STORED PROCEDURE: get_driver_profile
-- Obtiene el perfil completo de un driver
-- ACTUALIZADO con estructura real de la BD
-- ========================================

CREATE OR REPLACE FUNCTION get_driver_profile(p_driver_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Obtener datos del driver
    SELECT json_build_object(
        'id', d.id,
        'restaurant_id', d.restaurant_id,
        'name', d.name,
        'email', d.email,
        'phone', d.phone,
        'photo_url', d.photo_url,
        'vehicle_type', d.vehicle_type,
        'vehicle_brand', d.vehicle_brand,
        'vehicle_model', d.vehicle_model,
        'vehicle_color', d.vehicle_color,
        'vehicle_year', d.vehicle_year,
        'license_plate', d.license_plate,
        'status', d.status,
        'is_online', d.is_online,
        'is_on_delivery', d.is_on_delivery,
        'created_at', d.created_at,
        'total_deliveries', COALESCE(d.total_deliveries, 0),
        'rating', COALESCE(d.average_rating, 0.0),
        'total_earnings_cents', COALESCE(d.total_earnings_cents, 0),
        'notifications_enabled', COALESCE(d.notifications_enabled, true),
        'email_notifications_enabled', COALESCE(d.email_notifications_enabled, true),
        'preferred_language', COALESCE(d.preferred_language, 'es')
    )
    INTO v_result
    FROM drivers d
    WHERE d.id = p_driver_id;

    -- Si no se encuentra el driver, retornar error
    IF v_result IS NULL THEN
        RAISE EXCEPTION 'Driver no encontrado con ID: %', p_driver_id;
    END IF;

    RETURN v_result;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION get_driver_profile(UUID) IS 'Obtiene el perfil completo de un driver por su ID';
