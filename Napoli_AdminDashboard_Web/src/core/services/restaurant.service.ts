// src/core/services/restaurant.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  RegisterRestaurantParams,
  Restaurant,
  UpdateRestaurantProfileParams,
  UpdateRestaurantSettingsParams,
  UpdateRestaurantBrandingParams,
  UpdateRestaurantLocationParams,
  UpdateRestaurantRegionalSettingsParams,
} from "@/core/models/restaurant.model";
import { toCamelCase, toSnakeCase } from "@/core/utils/utils";

// ============================================================================
// GET RESTAURANT
// ============================================================================

export const getManagedRestaurant = async (): Promise<Restaurant | null> => {
  console.log('🔍 DEBUG - Starting getManagedRestaurant');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) {
    console.log('⚠️ WARNING - No restaurant ID found');
    return null;
  }

  console.log('📦 DATA - restaurant_id:', restaurantId);

  const { data, error } = await supabase.rpc('get_admin_restaurant', {
    p_restaurant_id: restaurantId,
  });

  if (error) {
    console.error('❌ ERROR - Failed to get restaurant:', error.message);
    throw new Error(error.message);
  }

  console.log('✅ SUCCESS - Restaurant retrieved');
  return toCamelCase<Restaurant>(data);
};

// ============================================================================
// UPDATE PROFILE
// ============================================================================

export const updateRestaurantProfile = async (
  params: UpdateRestaurantProfileParams,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting updateRestaurantProfile');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  console.log('📦 DATA - restaurant_id:', restaurantId, 'params:', params);

  const snakeParams = toSnakeCase(params as unknown as Record<string, unknown>);

  const { error } = await supabase.rpc('update_admin_restaurant_profile', {
    p_restaurant_id: restaurantId,
    p_name: snakeParams.name,
    p_description: snakeParams.description,
    p_email: snakeParams.email,
    p_phone: snakeParams.phone,
    p_whatsapp: snakeParams.whatsapp,
    p_website: snakeParams.website,
  });

  if (error) {
    console.error('❌ ERROR - Failed to update profile:', error.message);
    throw new Error(error.message);
  }

  console.log('✅ SUCCESS - Restaurant profile updated');
};

// ============================================================================
// UPDATE BRANDING
// ============================================================================

export const updateRestaurantBranding = async (
  params: UpdateRestaurantBrandingParams,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting updateRestaurantBranding');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  console.log('📦 DATA - restaurant_id:', restaurantId);

  const snakeParams = toSnakeCase(params as unknown as Record<string, unknown>);

  const { error } = await supabase.rpc('update_admin_restaurant_branding', {
    p_restaurant_id: restaurantId,
    p_logo_url: snakeParams.logo_url,
    p_banner_url: snakeParams.banner_url,
    p_primary_color: snakeParams.primary_color,
    p_secondary_color: snakeParams.secondary_color,
  });

  if (error) {
    console.error('❌ ERROR - Failed to update branding:', error.message);
    throw new Error(error.message);
  }

  console.log('✅ SUCCESS - Restaurant branding updated');
};

// ============================================================================
// UPDATE LOCATION
// ============================================================================

export const updateRestaurantLocation = async (
  params: UpdateRestaurantLocationParams,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting updateRestaurantLocation');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  console.log('📦 DATA - restaurant_id:', restaurantId);

  const snakeParams = toSnakeCase(params as unknown as Record<string, unknown>);

  const { error } = await supabase.rpc('update_admin_restaurant_location', {
    p_restaurant_id: restaurantId,
    p_address: snakeParams.address,
    p_city: snakeParams.city,
    p_state: snakeParams.state,
    p_country: snakeParams.country,
    p_postal_code: snakeParams.postal_code,
    p_latitude: snakeParams.latitude,
    p_longitude: snakeParams.longitude,
    p_timezone: snakeParams.timezone,
  });

  if (error) {
    console.error('❌ ERROR - Failed to update location:', error.message);
    throw new Error(error.message);
  }

  console.log('✅ SUCCESS - Restaurant location updated');
};

// ============================================================================
// UPDATE REGIONAL SETTINGS
// ============================================================================

export const updateRestaurantRegionalSettings = async (
  params: UpdateRestaurantRegionalSettingsParams,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting updateRestaurantRegionalSettings');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  console.log('📦 DATA - restaurant_id:', restaurantId);

  const snakeParams = toSnakeCase(params as unknown as Record<string, unknown>);

  const { error } = await supabase.rpc('update_admin_restaurant_regional_settings', {
    p_restaurant_id: restaurantId,
    p_currency_code: snakeParams.currency_code,
    p_currency_symbol: snakeParams.currency_symbol,
    p_currency_position: snakeParams.currency_position,
    p_decimal_separator: snakeParams.decimal_separator,
    p_thousands_separator: snakeParams.thousands_separator,
    p_decimal_places: snakeParams.decimal_places,
    p_tax_rate_percentage: snakeParams.tax_rate_percentage,
    p_tax_included_in_prices: snakeParams.tax_included_in_prices,
  });

  if (error) {
    console.error('❌ ERROR - Failed to update regional settings:', error.message);
    throw new Error(error.message);
  }

  console.log('✅ SUCCESS - Restaurant regional settings updated');
};

// ============================================================================
// UPDATE SETTINGS
// ============================================================================

export const updateRestaurantSettings = async (
  params: UpdateRestaurantSettingsParams,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting updateRestaurantSettings');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  console.log('📦 DATA - restaurant_id:', restaurantId);

  const snakeParams = toSnakeCase(params as unknown as Record<string, unknown>);

  const { error } = await supabase.rpc('update_admin_restaurant_settings', {
    p_restaurant_id: restaurantId,
    p_is_open: snakeParams.is_open,
    p_accepts_delivery: snakeParams.accepts_delivery,
    p_accepts_pickup: snakeParams.accepts_pickup,
    p_accepts_dine_in: snakeParams.accepts_dine_in,
    p_delivery_radius_km: snakeParams.delivery_radius_km,
    p_minimum_order_cents: snakeParams.minimum_order_cents,
    p_delivery_fee_cents: snakeParams.delivery_fee_cents,
    p_delivery_fee_per_km_cents: snakeParams.delivery_fee_per_km_cents,
    p_free_delivery_threshold_cents: snakeParams.free_delivery_threshold_cents,
    p_estimated_prep_minutes: snakeParams.estimated_prep_minutes,
    p_estimated_delivery_minutes: snakeParams.estimated_delivery_minutes,
    p_accepts_card: snakeParams.accepts_card,
    p_accepts_cash: snakeParams.accepts_cash,
    p_accepts_transfer: snakeParams.accepts_transfer,
    p_bank_account_clabe: snakeParams.bank_account_clabe,
    p_bank_account_name: snakeParams.bank_account_name,
    p_bank_name: snakeParams.bank_name,
    p_business_hours: snakeParams.business_hours,
    p_driver_commission_type: snakeParams.driver_commission_type,
    p_driver_commission_value: snakeParams.driver_commission_value,
  });

  if (error) {
    console.error('❌ ERROR - Failed to update settings:', error.message);
    throw new Error(error.message);
  }

  console.log('✅ SUCCESS - Restaurant settings updated');
};

// ============================================================================
// IMAGE UPLOAD FUNCTIONS
// ============================================================================

export const uploadRestaurantLogo = async (file: File): Promise<string> => {
  console.log('🔍 DEBUG - Starting uploadRestaurantLogo');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const fileExt = file.name.split(".").pop();
  const fileName = `logos/${restaurantId}/${Date.now()}.${fileExt}`;

  console.log('📦 DATA - Uploading to:', fileName);

  const { data, error } = await supabase.storage
    .from("restaurant-assets")
    .upload(fileName, file);

  if (error) {
    console.error('❌ ERROR - Failed to upload logo:', error.message);
    throw new Error(error.message);
  }

  const { data: { publicUrl } } = supabase.storage
    .from("restaurant-assets")
    .getPublicUrl(data.path);

  console.log('✅ SUCCESS - Logo uploaded:', publicUrl);
  return publicUrl;
};

export const uploadRestaurantBanner = async (file: File): Promise<string> => {
  console.log('🔍 DEBUG - Starting uploadRestaurantBanner');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const fileExt = file.name.split(".").pop();
  const fileName = `banners/${restaurantId}/${Date.now()}.${fileExt}`;

  console.log('📦 DATA - Uploading to:', fileName);

  const { data, error } = await supabase.storage
    .from("restaurant-assets")
    .upload(fileName, file);

  if (error) {
    console.error('❌ ERROR - Failed to upload banner:', error.message);
    throw new Error(error.message);
  }

  const { data: { publicUrl } } = supabase.storage
    .from("restaurant-assets")
    .getPublicUrl(data.path);

  console.log('✅ SUCCESS - Banner uploaded:', publicUrl);
  return publicUrl;
};

// ============================================================================
// REGISTER RESTAURANT (Already uses RPC - no changes)
// ============================================================================

export const registerRestaurant = async (
  params: RegisterRestaurantParams,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting registerRestaurant');
  console.log('📦 DATA - email:', params.email, 'restaurant:', params.restaurantName);

  try {
    // 1. Create auth user in Supabase
    console.log('🔍 DEBUG - Creating Supabase Auth user');
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: params.email,
      password: params.password,
    });

    if (authError) throw new Error(authError.message);
    if (!authData.user) throw new Error("No se pudo crear el usuario");

    console.log('✅ SUCCESS - Auth user created:', authData.user.id);

    // 2. Call stored procedure to create restaurant and admin
    console.log('🔍 DEBUG - Calling register_admin stored procedure');
    const { data, error } = await supabase.rpc('register_admin', {
      p_email: params.email,
      p_restaurant_name: params.restaurantName,
      p_manager_name: params.managerName,
      p_phone: params.phone,
    });

    if (error) throw new Error(error.message);

    console.log('✅ SUCCESS - Stored procedure response:', data);
    console.log('✅ SUCCESS - Registration complete');

  } catch (error) {
    console.error('❌ ERROR - Exception in registerRestaurant:', error);
    throw error;
  }
};
