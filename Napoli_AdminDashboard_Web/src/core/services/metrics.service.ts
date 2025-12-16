// src/core/services/metrics.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  DayOrdersAmount,
  GetDailyRevenueInPeriodParams,
  GetDailyRevenueInPeriodResponse,
  GetPopularProductsParams,
  GetPopularProductsResponse,
  GetSalesTransactionsParams,
  GetSalesTransactionsResponse,
  MonthCanceledOrdersAmount,
  MonthOrdersAmount,
  MonthRevenue,
} from "@/core/models/metrics.model";

interface OrderWithTotal {
  total_cents: number | null;
}

interface OrderWithCreatedAt extends OrderWithTotal {
  created_at: string;
}

interface OrderItem {
  quantity: number;
  product_name: string;
}

interface OrderWithItems {
  id: string;
  created_at: string;
  total_cents: number | null;
  customer_snapshot: { name?: string } | null;
  order_items: Array<{
    product_name: string;
    quantity: number;
    unit_price_cents: number | null;
  }>;
}

export const getDayOrdersAmount = async (): Promise<DayOrdersAmount> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  // Get today's orders
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  const { count: todayCount } = await supabase
    .from("orders")
    .select("*", { count: "exact", head: true })
    .eq("restaurant_id", restaurantId)
    .gte("created_at", today.toISOString());

  const { count: yesterdayCount } = await supabase
    .from("orders")
    .select("*", { count: "exact", head: true })
    .eq("restaurant_id", restaurantId)
    .gte("created_at", yesterday.toISOString())
    .lt("created_at", today.toISOString());

  return {
    amount: todayCount || 0,
    diffFromYesterday: (todayCount || 0) - (yesterdayCount || 0),
  };
};

export const getMonthOrdersAmount = async (): Promise<MonthOrdersAmount> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0);

  const { count: thisMonth } = await supabase
    .from("orders")
    .select("*", { count: "exact", head: true })
    .eq("restaurant_id", restaurantId)
    .gte("created_at", monthStart.toISOString());

  const { count: lastMonth } = await supabase
    .from("orders")
    .select("*", { count: "exact", head: true })
    .eq("restaurant_id", restaurantId)
    .gte("created_at", lastMonthStart.toISOString())
    .lte("created_at", lastMonthEnd.toISOString());

  return {
    amount: thisMonth || 0,
    diffFromLastMonth: (thisMonth || 0) - (lastMonth || 0),
  };
};

export const getMonthCanceledOrdersAmount =
  async (): Promise<MonthCanceledOrdersAmount> => {
    const restaurantId = await getCurrentRestaurantId();
    if (!restaurantId) throw new Error("No restaurant found");

    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0);

    const { count: thisMonth } = await supabase
      .from("orders")
      .select("*", { count: "exact", head: true })
      .eq("restaurant_id", restaurantId)
      .eq("status", "cancelled")
      .gte("created_at", monthStart.toISOString());

    const { count: lastMonth } = await supabase
      .from("orders")
      .select("*", { count: "exact", head: true })
      .eq("restaurant_id", restaurantId)
      .eq("status", "cancelled")
      .gte("created_at", lastMonthStart.toISOString())
      .lte("created_at", lastMonthEnd.toISOString());

    return {
      amount: thisMonth || 0,
      diffFromLastMonth: (thisMonth || 0) - (lastMonth || 0),
    };
  };

export const getMonthRevenue = async (): Promise<MonthRevenue> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0);

  const { data: thisMonthData } = await supabase
    .from("orders")
    .select("total_cents")
    .eq("restaurant_id", restaurantId)
    .eq("status", "delivered")
    .gte("created_at", monthStart.toISOString());

  const { data: lastMonthData } = await supabase
    .from("orders")
    .select("total_cents")
    .eq("restaurant_id", restaurantId)
    .eq("status", "delivered")
    .gte("created_at", lastMonthStart.toISOString())
    .lte("created_at", lastMonthEnd.toISOString());

  const thisMonthTotal = (
    (thisMonthData as OrderWithTotal[] | null) || []
  ).reduce((sum, o) => sum + (o.total_cents || 0), 0);
  const lastMonthTotal = (
    (lastMonthData as OrderWithTotal[] | null) || []
  ).reduce((sum, o) => sum + (o.total_cents || 0), 0);

  return {
    receipt: thisMonthTotal / 100,
    diffFromLastMonth: (thisMonthTotal - lastMonthTotal) / 100,
  };
};

export const getPopularProducts = async (
  _params: GetPopularProductsParams,
): Promise<GetPopularProductsResponse> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  // Query order_items joined with products, grouped by product
  const { data, error } = await supabase
    .from("order_items")
    .select(
      `
      quantity,
      product_name,
      order:orders!inner(restaurant_id, created_at, status)
    `,
    )
    .eq("order.restaurant_id", restaurantId)
    .eq("order.status", "delivered");

  if (error) throw new Error(error.message);

  // Aggregate by product name
  const productCounts: Record<string, number> = {};
  ((data as OrderItem[] | null) || []).forEach((item) => {
    const name = item.product_name;
    productCounts[name] = (productCounts[name] || 0) + item.quantity;
  });

  return Object.entries(productCounts)
    .map(([product, amount]) => ({ product, amount }))
    .sort((a, b) => b.amount - a.amount)
    .slice(0, 10);
};

export const getDailyRevenueInPeriod = async (
  params: GetDailyRevenueInPeriodParams,
): Promise<GetDailyRevenueInPeriodResponse> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let query = supabase
    .from("orders")
    .select("created_at, total_cents")
    .eq("restaurant_id", restaurantId)
    .eq("status", "delivered");

  if (params.from) {
    query = query.gte("created_at", params.from.toISOString());
  }
  if (params.to) {
    query = query.lte("created_at", params.to.toISOString());
  }

  const { data, error } = await query;
  if (error) throw new Error(error.message);

  // Group by date
  const dailyTotals: Record<string, number> = {};
  ((data as OrderWithCreatedAt[] | null) || []).forEach((order) => {
    const date = order.created_at.split("T")[0];
    dailyTotals[date] = (dailyTotals[date] || 0) + (order.total_cents || 0);
  });

  return Object.entries(dailyTotals)
    .map(([date, cents]) => ({ date, receipt: cents / 100 }))
    .sort((a, b) => a.date.localeCompare(b.date));
};

export const getSalesTransactions = async (
  params: GetSalesTransactionsParams,
): Promise<GetSalesTransactionsResponse> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let query = supabase
    .from("orders")
    .select(
      `
      id,
      created_at,
      total_cents,
      customer_snapshot,
      order_items(product_name, quantity, unit_price_cents)
    `,
    )
    .eq("restaurant_id", restaurantId)
    .eq("status", "delivered")
    .order("created_at", { ascending: false })
    .limit(50);

  if (params.from) {
    query = query.gte("created_at", params.from.toISOString());
  }
  if (params.to) {
    query = query.lte("created_at", params.to.toISOString());
  }

  const { data, error } = await query;
  if (error) throw new Error(error.message);

  return ((data as OrderWithItems[] | null) || []).map((order) => ({
    id: order.id,
    date: order.created_at,
    customerName: order.customer_snapshot?.name || "Cliente",
    total: (order.total_cents || 0) / 100,
    items: (order.order_items || []).map((item) => ({
      product: item.product_name,
      quantity: item.quantity,
      price: (item.unit_price_cents || 0) / 100,
    })),
  }));
};
