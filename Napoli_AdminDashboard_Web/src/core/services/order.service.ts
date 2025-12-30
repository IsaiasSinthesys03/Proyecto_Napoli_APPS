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
  console.log('🔍 DEBUG - Starting getOrders');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const page = params.page || 1;

  console.log('🔍 DEBUG - Calling get_admin_orders stored procedure');
  console.log('📦 DATA - page:', page, 'status:', params.status, 'orderId:', params.orderId);

  const { data, error } = await supabase.rpc('get_admin_orders', {
    p_restaurant_id: restaurantId,
    p_page: page,
    p_status_filter: params.status && params.status.length > 0 ? params.status : null,
    p_order_number_filter: params.orderId || null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Stored procedure response received');
  console.log('📦 RAW DATA:', JSON.stringify(data, null, 2));

  const response = data as { results: any[]; meta: any };

  console.log('📦 RESULTS COUNT:', response.results?.length);
  console.log('📦 FIRST ORDER (before toCamelCase):', JSON.stringify(response.results[0], null, 2));

  const orders = response.results.map((order) => toCamelCase<Order>(order));

  console.log('📦 FIRST ORDER (after toCamelCase):', JSON.stringify(orders[0], null, 2));

  return {
    results: orders,
    meta: {
      pageIndex: response.meta.page_index,
      perPage: response.meta.per_page,
      totalCount: response.meta.total_count,
    },
  };
};

export const getOrderDetails = async (orderId: string): Promise<Order> => {
  console.log('🔍 DEBUG - Starting getOrderDetails for order:', orderId);

  const { data, error } = await supabase.rpc('get_admin_order_details', {
    p_order_id: orderId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Order details retrieved');

  return toCamelCase<Order>(data);
};

// Update order status with appropriate timestamp
async function updateOrderStatus(
  orderId: string,
  status: OrderStatusType,
  timestampField?: string,
): Promise<void> {
  console.log('🔍 DEBUG - Calling update_admin_order_status');
  console.log('📦 DATA - orderId:', orderId, 'status:', status, 'timestampField:', timestampField);

  const { error } = await supabase.rpc('update_admin_order_status', {
    p_order_id: orderId,
    p_status: status,
    p_timestamp_field: timestampField || null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Order status updated');
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
  console.log('🔍 DEBUG - Calling cancel_admin_order');
  console.log('📦 DATA - orderId:', orderId, 'reason:', reason);

  const { error } = await supabase.rpc('cancel_admin_order', {
    p_order_id: orderId,
    p_reason: reason || null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Order cancelled');
};

export const finishOrder = async (orderId: string): Promise<void> => {
  await deliverOrder(orderId);
};

export const assignDriver = async (
  orderId: string,
  driverId: string,
): Promise<void> => {
  console.log('🔍 DEBUG - Calling assign_driver_to_order');
  console.log('📦 DATA - orderId:', orderId, 'driverId:', driverId);

  const { error } = await supabase.rpc('assign_driver_to_order', {
    p_order_id: orderId,
    p_driver_id: driverId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Driver assigned');
};
