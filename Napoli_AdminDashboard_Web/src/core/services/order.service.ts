// src/core/services/order.service.ts

import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  GetOrdersParams,
  Order,
  OrderStatusType,
  PaginatedOrders,
} from "@/core/models";
import { toCamelCase } from "@/core/utils/utils";

export const getOrders = async (
  params: GetOrdersParams,
): Promise<PaginatedOrders> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const page = params.page || 1;
  const perPage = 10;
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;

  let query = supabase
    .from("orders")
    .select(
      `
      *,
      customer:customers(id, name, email, phone),
      driver:drivers(id, name),
      order_items(*)
    `,
      { count: "exact" },
    )
    .eq("restaurant_id", restaurantId)
    .order("created_at", { ascending: false })
    .range(from, to);

  // Apply filters
  if (params.status && params.status.length > 0) {
    query = query.in("status", params.status);
  }
  if (params.orderId) {
    query = query.ilike("order_number", `%${params.orderId}%`);
  }

  const { data, error, count } = await query;

  if (error) throw new Error(error.message);

  const orders = (data || []).map((order) => toCamelCase<Order>(order));

  return {
    results: orders,
    meta: {
      pageIndex: page - 1,
      perPage,
      totalCount: count || 0,
    },
  };
};

export const getOrderDetails = async (orderId: string): Promise<Order> => {
  const { data, error } = await supabase
    .from("orders")
    .select(
      `
      *,
      customer:customers(id, name, email, phone),
      driver:drivers(id, name),
      order_items(*)
    `,
    )
    .eq("id", orderId)
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Order>(data);
};

// Update order status with appropriate timestamp
async function updateOrderStatus(
  orderId: string,
  status: OrderStatusType,
  timestampField?: string,
): Promise<void> {
  const updateData: Record<string, unknown> = { status };

  if (timestampField) {
    updateData[timestampField] = new Date().toISOString();
  }

  const { error } = await supabase
    .from("orders")
    .update(updateData)
    .eq("id", orderId);

  if (error) throw new Error(error.message);
}

export const approveOrder = async (orderId: string): Promise<void> => {
  await updateOrderStatus(orderId, "accepted", "accepted_at");
};

export const processOrder = async (orderId: string): Promise<void> => {
  await updateOrderStatus(orderId, "processing", "processing_at");
};

export const readyOrder = async (orderId: string): Promise<void> => {
  await updateOrderStatus(orderId, "ready", "ready_at");
};

export const dispatchOrder = async (orderId: string): Promise<void> => {
  await updateOrderStatus(orderId, "delivering", "picked_up_at");
};

export const deliverOrder = async (orderId: string): Promise<void> => {
  await updateOrderStatus(orderId, "delivered", "delivered_at");
};

export const cancelOrder = async (
  orderId: string,
  reason?: string,
): Promise<void> => {
  const { error } = await supabase
    .from("orders")
    .update({
      status: "cancelled",
      cancelled_at: new Date().toISOString(),
      cancellation_reason: reason || null,
      cancelled_by: "restaurant",
    })
    .eq("id", orderId);

  if (error) throw new Error(error.message);
};

export const finishOrder = async (orderId: string): Promise<void> => {
  await deliverOrder(orderId);
};

export const assignDriver = async (
  orderId: string,
  driverId: string,
): Promise<void> => {
  const { error } = await supabase
    .from("orders")
    .update({ driver_id: driverId })
    .eq("id", orderId);

  if (error) throw new Error(error.message);
};
