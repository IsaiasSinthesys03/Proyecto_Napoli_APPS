-- ========================================
-- STORED PROCEDURE: update_driver_profile
-- Actualiza la información de un driver
-- ACTUALIZADO con estructura real de la BD
-- ========================================

CREATE OR REPLACE FUNCTION update_driver_profile(
    p_driver_id UUID,
    p_name TEXT DEFAULT NULL,
    p_phone TEXT DEFAULT NULL,
    p_vehicle_type TEXT DEFAULT NULL,
    p_vehicle_brand TEXT DEFAULT NULL,
    p_vehicle_model TEXT DEFAULT NULL,
    p_vehicle_color TEXT DEFAULT NULL,
    p_vehicle_year INTEGER DEFAULT NULL,
    p_license_plate TEXT DEFAULT NULL,
    p_photo_url TEXT DEFAULT NULL,
    p_notifications_enabled BOOLEAN DEFAULT NULL,
    p_email_notifications_enabled BOOLEAN DEFAULT NULL,
    p_preferred_language TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Verificar que el driver existe
    IF NOT EXISTS (SELECT 1 FROM drivers WHERE id = p_driver_id) THEN
        RAISE EXCEPTION 'Driver no encontrado con ID: %', p_driver_id;
    END IF;

    -- Actualizar solo los campos que no son NULL
    UPDATE drivers
    SET
        name = COALESCE(p_name, name),
        phone = COALESCE(p_phone, phone),
        vehicle_type = COALESCE(p_vehicle_type::vehicle_type, vehicle_type),
        vehicle_brand = COALESCE(p_vehicle_brand, vehicle_brand),
        vehicle_model = COALESCE(p_vehicle_model, vehicle_model),
        vehicle_color = COALESCE(p_vehicle_color, vehicle_color),
        vehicle_year = COALESCE(p_vehicle_year, vehicle_year),
        license_plate = COALESCE(p_license_plate, license_plate),
        photo_url = COALESCE(p_photo_url, photo_url),
        notifications_enabled = COALESCE(p_notifications_enabled, notifications_enabled),
        email_notifications_enabled = COALESCE(p_email_notifications_enabled, email_notifications_enabled),
        preferred_language = COALESCE(p_preferred_language, preferred_language),
        updated_at = NOW()
    WHERE id = p_driver_id;

    -- Retornar el driver actualizado
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

    RETURN v_result;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION update_driver_profile IS 'Actualiza la información de un driver';
