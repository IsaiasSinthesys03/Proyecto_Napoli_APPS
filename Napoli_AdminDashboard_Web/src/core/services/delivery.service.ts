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
import { toCamelCase, toSnakeCase } from "@/core/utils/utils";

export const getDeliveryMen = async (): Promise<GetDeliveryMenResponse> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase
    .from("drivers")
    .select("*")
    .eq("restaurant_id", restaurantId)
    .order("created_at", { ascending: false });

  if (error) throw new Error(error.message);

  const drivers = (data || []).map((d) => toCamelCase<Driver>(d));
  return { deliveryMen: drivers };
};

export const createDeliveryMan = async (
  payload: CreateDriverPayload,
): Promise<Driver> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase
    .from("drivers")
    .insert({
      restaurant_id: restaurantId,
      ...toSnakeCase(payload as unknown as Record<string, unknown>),
      status: "pending",
    })
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Driver>(data);
};

export const updateDeliveryMan = async (
  id: string,
  payload: UpdateDriverPayload,
): Promise<Driver> => {
  const { data, error } = await supabase
    .from("drivers")
    .update(toSnakeCase(payload as unknown as Record<string, unknown>))
    .eq("id", id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Driver>(data);
};

export const deleteDeliveryMan = async (id: string): Promise<void> => {
  const { error } = await supabase.from("drivers").delete().eq("id", id);

  if (error) throw new Error(error.message);
};

export const toggleDeliveryManStatus = async (
  id: string,
  status: DriverStatusType,
): Promise<Driver> => {
  const { data, error } = await supabase
    .from("drivers")
    .update({ status })
    .eq("id", id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Driver>(data);
};

export const approveDriver = async (id: string): Promise<Driver> => {
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data, error } = await supabase
    .from("drivers")
    .update({
      status: "approved",
      approved_at: new Date().toISOString(),
      approved_by: user?.id,
    })
    .eq("id", id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Driver>(data);
};

export const assignDeliveryMan = async (
  params: AssignDeliveryManParams,
): Promise<void> => {
  const { error } = await supabase
    .from("orders")
    .update({ driver_id: params.deliveryManId })
    .eq("id", params.orderId);

  if (error) throw new Error(error.message);
};

export interface ActiveDelivery {
  orderId: string;
  driverId: string;
  driverName: string;
  driverPhone: string | null;
  driverVehicleType: string;
  deliveryAddress: string;
  customerName: string;
}

interface OrderWithDriver {
  id: string;
  address_snapshot: { street_address?: string; label?: string } | null;
  customer_snapshot: { name?: string } | null;
  driver_id: string;
}

interface DriverInfo {
  id: string;
  name: string;
  phone: string | null;
  vehicle_type: string | null;
}

export const getActiveDeliveries = async (): Promise<ActiveDelivery[]> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) return [];

  const { data: orders, error: ordersError } = await supabase
    .from("orders")
    .select("id, address_snapshot, customer_snapshot, driver_id")
    .eq("restaurant_id", restaurantId)
    .eq("status", "delivering");

  if (ordersError) throw new Error(ordersError.message);

  const ordersWithDriver = (orders || []).filter(
    (o): o is OrderWithDriver => o.driver_id != null,
  );
  if (ordersWithDriver.length === 0) return [];

  const driverIds = [...new Set(ordersWithDriver.map((o) => o.driver_id))];

  const { data: drivers, error: driversError } = await supabase
    .from("drivers")
    .select("id, name, phone, vehicle_type")
    .in("id", driverIds);

  if (driversError) throw new Error(driversError.message);

  const driversMap = new Map((drivers || []).map((d: DriverInfo) => [d.id, d]));

  return ordersWithDriver.map((order) => {
    const driver = driversMap.get(order.driver_id) || {
      name: "Repartidor",
      phone: null,
      vehicle_type: "moto",
    };
    return {
      orderId: order.id,
      driverId: order.driver_id,
      driverName: driver.name,
      driverPhone: driver.phone,
      driverVehicleType: driver.vehicle_type || "moto",
      deliveryAddress:
        order.address_snapshot?.street_address ||
        order.address_snapshot?.label ||
        "Sin dirección",
      customerName: order.customer_snapshot?.name || "Cliente",
    };
  });
};
