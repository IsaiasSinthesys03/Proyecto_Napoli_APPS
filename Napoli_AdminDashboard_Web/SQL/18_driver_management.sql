-- ============================================================================
-- STORED PROCEDURES: Driver Management (Create, Update, Delete, Toggle, Approve)
-- ============================================================================
-- Propósito: Operaciones CRUD para repartidores
-- ============================================================================

-- ============================================================================
-- 1. CREATE DRIVER
-- ============================================================================
CREATE OR REPLACE FUNCTION create_admin_driver(
  p_restaurant_id UUID,
  p_name VARCHAR,
  p_email VARCHAR,
  p_phone VARCHAR,
  p_photo_url VARCHAR DEFAULT NULL,
  p_vehicle_type VARCHAR DEFAULT 'moto',
  p_vehicle_brand VARCHAR DEFAULT NULL,
  p_vehicle_model VARCHAR DEFAULT NULL,
  p_vehicle_color VARCHAR DEFAULT NULL,
  p_vehicle_year INTEGER DEFAULT NULL,
  p_license_plate VARCHAR DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_driver JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - create_admin_driver called';
  RAISE NOTICE '📦 DATA - name: %, email: %', p_name, p_email;
  
  INSERT INTO drivers (
    restaurant_id,
    name,
    email,
    phone,
    photo_url,
    vehicle_type,
    vehicle_brand,
    vehicle_model,
    vehicle_color,
    vehicle_year,
    license_plate,
    status
  ) VALUES (
    p_restaurant_id,
    p_name,
    p_email,
    p_phone,
    p_photo_url,
    p_vehicle_type::vehicle_type,
    p_vehicle_brand,
    p_vehicle_model,
    p_vehicle_color,
    p_vehicle_year,
    p_license_plate,
    'active'::driver_status
  )
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'email', email,
    'phone', phone,
    'photo_url', photo_url,
    'vehicle_type', vehicle_type,
    'vehicle_brand', vehicle_brand,
    'vehicle_model', vehicle_model,
    'vehicle_color', vehicle_color,
    'vehicle_year', vehicle_year,
    'license_plate', license_plate,
    'id_document_url', id_document_url,
    'license_url', license_url,
    'vehicle_registration_url', vehicle_registration_url,
    'insurance_url', insurance_url,
    'status', status,
    'is_online', is_online,
    'is_on_delivery', is_on_delivery,
    'current_latitude', current_latitude,
    'current_longitude', current_longitude,
    'last_location_update', last_location_update,
    'notifications_enabled', notifications_enabled,
    'email_notifications_enabled', email_notifications_enabled,
    'preferred_language', preferred_language,
    'fcm_token', fcm_token,
    'max_concurrent_orders', max_concurrent_orders,
    'total_deliveries', total_deliveries,
    'total_earnings_cents', total_earnings_cents,
    'rating_sum', rating_sum,
    'rating_count', rating_count,
    'average_rating', average_rating,
    'average_delivery_minutes', average_delivery_minutes,
    'created_at', created_at,
    'updated_at', updated_at,
    'approved_at', approved_at,
    'last_delivery_at', last_delivery_at
  )
  INTO v_driver;
  
  RAISE NOTICE '✅ SUCCESS - Driver created with id: %', (v_driver->>'id');
  
  RETURN v_driver;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in create_admin_driver: %', SQLERRM;
    RAISE EXCEPTION 'Error al crear repartidor: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. UPDATE DRIVER
-- ============================================================================
CREATE OR REPLACE FUNCTION update_admin_driver(
  p_driver_id UUID,
  p_name VARCHAR DEFAULT NULL,
  p_email VARCHAR DEFAULT NULL,
  p_phone VARCHAR DEFAULT NULL,
  p_photo_url VARCHAR DEFAULT NULL,
  p_vehicle_type VARCHAR DEFAULT NULL,
  p_vehicle_brand VARCHAR DEFAULT NULL,
  p_vehicle_model VARCHAR DEFAULT NULL,
  p_vehicle_color VARCHAR DEFAULT NULL,
  p_vehicle_year INTEGER DEFAULT NULL,
  p_license_plate VARCHAR DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_driver JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - update_admin_driver called';
  RAISE NOTICE '📦 DATA - driver_id: %', p_driver_id;
  
  UPDATE drivers
  SET
    name = COALESCE(p_name, name),
    email = COALESCE(p_email, email),
    phone = COALESCE(p_phone, phone),
    photo_url = COALESCE(p_photo_url, photo_url),
    vehicle_type = CASE WHEN p_vehicle_type IS NOT NULL THEN p_vehicle_type::vehicle_type ELSE vehicle_type END,
    vehicle_brand = COALESCE(p_vehicle_brand, vehicle_brand),
    vehicle_model = COALESCE(p_vehicle_model, vehicle_model),
    vehicle_color = COALESCE(p_vehicle_color, vehicle_color),
    vehicle_year = COALESCE(p_vehicle_year, vehicle_year),
    license_plate = COALESCE(p_license_plate, license_plate),
    updated_at = NOW()
  WHERE id = p_driver_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'email', email,
    'phone', phone,
    'photo_url', photo_url,
    'vehicle_type', vehicle_type,
    'vehicle_brand', vehicle_brand,
    'vehicle_model', vehicle_model,
    'vehicle_color', vehicle_color,
    'vehicle_year', vehicle_year,
    'license_plate', license_plate,
    'id_document_url', id_document_url,
    'license_url', license_url,
    'vehicle_registration_url', vehicle_registration_url,
    'insurance_url', insurance_url,
    'status', status,
    'is_online', is_online,
    'is_on_delivery', is_on_delivery,
    'current_latitude', current_latitude,
    'current_longitude', current_longitude,
    'last_location_update', last_location_update,
    'notifications_enabled', notifications_enabled,
    'email_notifications_enabled', email_notifications_enabled,
    'preferred_language', preferred_language,
    'fcm_token', fcm_token,
    'max_concurrent_orders', max_concurrent_orders,
    'total_deliveries', total_deliveries,
    'total_earnings_cents', total_earnings_cents,
    'rating_sum', rating_sum,
    'rating_count', rating_count,
    'average_rating', average_rating,
    'average_delivery_minutes', average_delivery_minutes,
    'created_at', created_at,
    'updated_at', updated_at,
    'approved_at', approved_at,
    'last_delivery_at', last_delivery_at
  )
  INTO v_driver;
  
  IF v_driver IS NULL THEN
    RAISE EXCEPTION 'Repartidor no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Driver updated';
  
  RETURN v_driver;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in update_admin_driver: %', SQLERRM;
    RAISE EXCEPTION 'Error al actualizar repartidor: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 3. DELETE DRIVER
-- ============================================================================
CREATE OR REPLACE FUNCTION delete_admin_driver(
  p_driver_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔍 DEBUG - delete_admin_driver called';
  RAISE NOTICE '📦 DATA - driver_id: %', p_driver_id;
  
  DELETE FROM drivers
  WHERE id = p_driver_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Repartidor no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Driver deleted';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in delete_admin_driver: %', SQLERRM;
    RAISE EXCEPTION 'Error al eliminar repartidor: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 4. TOGGLE DRIVER STATUS
-- ============================================================================
CREATE OR REPLACE FUNCTION toggle_driver_status(
  p_driver_id UUID,
  p_status VARCHAR
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_driver JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - toggle_driver_status called';
  RAISE NOTICE '📦 DATA - driver_id: %, status: %', p_driver_id, p_status;
  
  UPDATE drivers
  SET
    status = p_status::driver_status,
    updated_at = NOW()
  WHERE id = p_driver_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'email', email,
    'phone', phone,
    'photo_url', photo_url,
    'vehicle_type', vehicle_type,
    'vehicle_brand', vehicle_brand,
    'vehicle_model', vehicle_model,
    'vehicle_color', vehicle_color,
    'vehicle_year', vehicle_year,
    'license_plate', license_plate,
    'id_document_url', id_document_url,
    'license_url', license_url,
    'vehicle_registration_url', vehicle_registration_url,
    'insurance_url', insurance_url,
    'status', status,
    'is_online', is_online,
    'is_on_delivery', is_on_delivery,
    'current_latitude', current_latitude,
    'current_longitude', current_longitude,
    'last_location_update', last_location_update,
    'notifications_enabled', notifications_enabled,
    'email_notifications_enabled', email_notifications_enabled,
    'preferred_language', preferred_language,
    'fcm_token', fcm_token,
    'max_concurrent_orders', max_concurrent_orders,
    'total_deliveries', total_deliveries,
    'total_earnings_cents', total_earnings_cents,
    'rating_sum', rating_sum,
    'rating_count', rating_count,
    'average_rating', average_rating,
    'average_delivery_minutes', average_delivery_minutes,
    'created_at', created_at,
    'updated_at', updated_at,
    'approved_at', approved_at,
    'last_delivery_at', last_delivery_at
  )
  INTO v_driver;
  
  IF v_driver IS NULL THEN
    RAISE EXCEPTION 'Repartidor no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Driver status toggled';
  
  RETURN v_driver;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in toggle_driver_status: %', SQLERRM;
    RAISE EXCEPTION 'Error al cambiar estado del repartidor: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 5. APPROVE DRIVER
-- ============================================================================
CREATE OR REPLACE FUNCTION approve_driver(
  p_driver_id UUID,
  p_approved_by UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_driver JSON;
BEGIN
  RAISE NOTICE '🔍 DEBUG - approve_driver called';
  RAISE NOTICE '📦 DATA - driver_id: %, approved_by: %', p_driver_id, p_approved_by;
  
  UPDATE drivers
  SET
    status = 'approved'::driver_status,
    approved_at = NOW(),
    updated_at = NOW()
  WHERE id = p_driver_id
  RETURNING json_build_object(
    'id', id,
    'restaurant_id', restaurant_id,
    'name', name,
    'email', email,
    'phone', phone,
    'photo_url', photo_url,
    'vehicle_type', vehicle_type,
    'vehicle_brand', vehicle_brand,
    'vehicle_model', vehicle_model,
    'vehicle_color', vehicle_color,
    'vehicle_year', vehicle_year,
    'license_plate', license_plate,
    'id_document_url', id_document_url,
    'license_url', license_url,
    'vehicle_registration_url', vehicle_registration_url,
    'insurance_url', insurance_url,
    'status', status,
    'is_online', is_online,
    'is_on_delivery', is_on_delivery,
    'current_latitude', current_latitude,
    'current_longitude', current_longitude,
    'last_location_update', last_location_update,
    'notifications_enabled', notifications_enabled,
    'email_notifications_enabled', email_notifications_enabled,
    'preferred_language', preferred_language,
    'fcm_token', fcm_token,
    'max_concurrent_orders', max_concurrent_orders,
    'total_deliveries', total_deliveries,
    'total_earnings_cents', total_earnings_cents,
    'rating_sum', rating_sum,
    'rating_count', rating_count,
    'average_rating', average_rating,
    'average_delivery_minutes', average_delivery_minutes,
    'created_at', created_at,
    'updated_at', updated_at,
    'approved_at', approved_at,
    'last_delivery_at', last_delivery_at
  )
  INTO v_driver;
  
  IF v_driver IS NULL THEN
    RAISE EXCEPTION 'Repartidor no encontrado';
  END IF;
  
  RAISE NOTICE '✅ SUCCESS - Driver approved';
  
  RETURN v_driver;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERROR - Exception in approve_driver: %', SQLERRM;
    RAISE EXCEPTION 'Error al aprobar repartidor: %', SQLERRM;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION create_admin_driver IS 'Crea un nuevo repartidor';
COMMENT ON FUNCTION update_admin_driver IS 'Actualiza un repartidor existente';
COMMENT ON FUNCTION delete_admin_driver IS 'Elimina un repartidor';
COMMENT ON FUNCTION toggle_driver_status IS 'Cambia el estado de un repartidor';
COMMENT ON FUNCTION approve_driver IS 'Aprueba un repartidor';
