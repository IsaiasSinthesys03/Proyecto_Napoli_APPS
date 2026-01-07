// src/core/services/delivery.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  AssignDeliveryManParams,
  CreateDriverPayload,
  Driver,
  DriverStatusType,
  GetDeliveryMenResponse,
  UpdateDriverPayload,
} from "@/core/models/delivery.model";
import { toCamelCase } from "@/core/utils/utils";

export const getDeliveryMen = async (): Promise<GetDeliveryMenResponse> => {
  console.log('🔍 DEBUG - Starting getDeliveryMen');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase.rpc('get_admin_drivers', {
    p_restaurant_id: restaurantId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Drivers retrieved');

  const drivers = (data || []).map((d: any) => toCamelCase<Driver>(d));
  return { deliveryMen: drivers };
};

export const createDeliveryMan = async (
  payload: CreateDriverPayload,
): Promise<Driver> => {
  console.log('🔍 DEBUG - Starting createDeliveryMan');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  // 1. Save current admin session
  const { data: { session: adminSession } } = await supabase.auth.getSession();
  if (!adminSession) throw new Error("No admin session found");

  console.log('💾 Admin session saved');

  try {
    // 2. Create driver auth account (this will auto-login as driver)
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: payload.email,
      password: payload.password,
      options: {
        data: {
          name: payload.name,
          role: 'driver',
          restaurant_id: restaurantId,
        },
        emailRedirectTo: undefined,
      },
    });

    if (authError) {
      const msg = authError.message || '';
      if ((authError as any).status === 422 || msg.includes('User already registered')) {
        if (adminSession) {
          await supabase.auth.setSession({
            access_token: adminSession.access_token,
            refresh_token: adminSession.refresh_token,
          });
          console.log('🔄 Admin session restored after auth conflict');
        }
        throw new Error('User already registered');
      }
      throw new Error(`Error creating auth user: ${authError.message}`);
    }
    if (!authData.user) throw new Error("No user returned from auth");

    console.log('✅ Driver auth user created:', authData.user.id);

    // 3. Immediately restore admin session (sign out driver, sign in admin)
    await supabase.auth.setSession({
      access_token: adminSession.access_token,
      refresh_token: adminSession.refresh_token,
    });

    console.log('🔄 Admin session restored');

    // 4. Create driver record in database
    const { data, error } = await supabase.rpc('create_admin_driver', {
      p_restaurant_id: restaurantId,
      p_name: payload.name,
      p_email: payload.email,
      p_phone: payload.phone,
      p_photo_url: payload.photoUrl || null,
      p_vehicle_type: payload.vehicleType || 'moto',
      p_vehicle_brand: payload.vehicleBrand || null,
      p_vehicle_model: payload.vehicleModel || null,
      p_vehicle_color: payload.vehicleColor || null,
      p_vehicle_year: payload.vehicleYear || null,
      p_license_plate: payload.licensePlate || null,
    });

    if (error) {
      console.error('Failed to create driver record:', error);
      throw new Error(error.message);
    }

    console.log('✅ SUCCESS - Driver created');

    return toCamelCase<Driver>(data);
  } catch (error) {
    // Ensure admin session is restored even if there's an error
    if (adminSession) {
      await supabase.auth.setSession({
        access_token: adminSession.access_token,
        refresh_token: adminSession.refresh_token,
      });
      console.log('🔄 Admin session restored after error');
    }
    throw error;
  }
};

export const updateDeliveryMan = async (
  id: string,
  payload: UpdateDriverPayload,
): Promise<Driver> => {
  console.log('🔍 DEBUG - Starting updateDeliveryMan for id:', id);

  const { data, error } = await supabase.rpc('update_admin_driver', {
    p_driver_id: id,
    p_name: payload.name || null,
    p_email: payload.email || null,
    p_phone: payload.phone || null,
    p_photo_url: payload.photoUrl || null,
    p_vehicle_type: payload.vehicleType || null,
    p_vehicle_brand: payload.vehicleBrand || null,
    p_vehicle_model: payload.vehicleModel || null,
    p_vehicle_color: payload.vehicleColor || null,
    p_vehicle_year: payload.vehicleYear || null,
    p_license_plate: payload.licensePlate || null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Driver updated');

  return toCamelCase<Driver>(data);
};

export const deleteDeliveryMan = async (id: string): Promise<void> => {
  console.log('🔍 DEBUG - Starting deleteDeliveryMan for id:', id);

  const { error } = await supabase.rpc('delete_admin_driver', {
    p_driver_id: id,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Driver deleted');
};

export const toggleDeliveryManStatus = async (
  id: string,
  status: DriverStatusType,
): Promise<Driver> => {
  console.log('🔍 DEBUG - Starting toggleDeliveryManStatus for id:', id);

  const { data, error } = await supabase.rpc('toggle_driver_status', {
    p_driver_id: id,
    p_status: status,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Driver status toggled');

  return toCamelCase<Driver>(data);
};

export const approveDriver = async (id: string): Promise<Driver> => {
  console.log('🔍 DEBUG - Starting approveDriver for id:', id);

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data, error } = await supabase.rpc('approve_driver', {
    p_driver_id: id,
    p_approved_by: user?.id || null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Driver approved');

  return toCamelCase<Driver>(data);
};

export const assignDeliveryMan = async (
  params: AssignDeliveryManParams,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting assignDeliveryMan');

  // This uses the assign_driver_to_order SP from order_status_management.sql
  const { error } = await supabase.rpc('assign_driver_to_order', {
    p_order_id: params.orderId,
    p_driver_id: params.deliveryManId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Driver assigned to order');
};

export interface ActiveDelivery {
  orderId: string;
  driverId: string;
  driverName: string;
  driverPhone: string | null;
  driverVehicleType: string;
  deliveryAddress: string;
  customerName: string;
  currentLatitude?: number | null;
  currentLongitude?: number | null;
}

export const getActiveDeliveries = async (): Promise<ActiveDelivery[]> => {
  console.log('🔍 DEBUG - Starting getActiveDeliveries');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) return [];

  const { data, error } = await supabase.rpc('get_active_deliveries', {
    p_restaurant_id: restaurantId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Active deliveries retrieved');

  return (data || []).map((d: any) => {
    const c = toCamelCase<ActiveDelivery>(d);
    // Ensure numeric conversion if values are strings or null
    return {
      ...c,
      currentLatitude: d.current_latitude !== null ? Number(d.current_latitude) : null,
      currentLongitude: d.current_longitude !== null ? Number(d.current_longitude) : null,
    } as ActiveDelivery;
  });
};


export interface DriverLocation {
  id: string;
  name: string;
  lat: number | null;
  lng: number | null;
  vehicle?: string | null;
  busy?: boolean | null;
  last_upd?: string | null;
}


export const getActiveDriversLocations = async (): Promise<DriverLocation[]> => {
  console.log('🔍 DEBUG - Starting getActiveDriversLocations');

  const { data, error } = await supabase.rpc('get_active_drivers_locations');

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Active drivers locations retrieved');

  return (data || []).map((d: any) => ({
    id: d.id,
    name: d.name || 'Conductor',
    lat: d.lat !== null && d.lat !== undefined ? Number(d.lat) : null,
    lng: d.lng !== null && d.lng !== undefined ? Number(d.lng) : null,
    vehicle: d.vehicle ?? null,
    busy: d.busy === true || d.busy === 't' ? true : false,
    last_upd: d.last_upd ?? null,
  }));
};
