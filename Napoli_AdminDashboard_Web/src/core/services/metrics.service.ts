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

/**
 * Get today's order count vs yesterday
 */
export const getDayOrdersAmount = async (): Promise<DayOrdersAmount> => {
  console.log("🔍 DEBUG - Starting getDayOrdersAmount");

  try {
    const restaurantId = await getCurrentRestaurantId();
    if (!restaurantId) throw new Error("No restaurant found");

    console.log("📦 DATA - restaurant_id:", restaurantId);

    const { data, error } = await supabase.rpc("get_day_orders_amount", {
      p_restaurant_id: restaurantId,
    });

    if (error) {
      console.error("❌ ERROR - RPC error:", error);
      throw new Error(`Error getting day orders amount: ${error.message}`);
    }

    console.log("✅ SUCCESS - Day orders amount retrieved:", data);
    return data as DayOrdersAmount;
  } catch (error) {
    console.error("❌ ERROR - Failed to get day orders amount:", error);
    throw error;
  }
};

/**
 * Get this month's order count vs last month
 */
export const getMonthOrdersAmount = async (): Promise<MonthOrdersAmount> => {
  console.log("🔍 DEBUG - Starting getMonthOrdersAmount");

  try {
    const restaurantId = await getCurrentRestaurantId();
    if (!restaurantId) throw new Error("No restaurant found");

    console.log("📦 DATA - restaurant_id:", restaurantId);

    const { data, error } = await supabase.rpc("get_month_orders_amount", {
      p_restaurant_id: restaurantId,
    });

    if (error) {
      console.error("❌ ERROR - RPC error:", error);
      throw new Error(`Error getting month orders amount: ${error.message}`);
    }

    console.log("✅ SUCCESS - Month orders amount retrieved:", data);
    return data as MonthOrdersAmount;
  } catch (error) {
    console.error("❌ ERROR - Failed to get month orders amount:", error);
    throw error;
  }
};

/**
 * Get this month's canceled orders vs last month
 */
export const getMonthCanceledOrdersAmount =
  async (): Promise<MonthCanceledOrdersAmount> => {
    console.log("🔍 DEBUG - Starting getMonthCanceledOrdersAmount");

    try {
      const restaurantId = await getCurrentRestaurantId();
      if (!restaurantId) throw new Error("No restaurant found");

      console.log("📦 DATA - restaurant_id:", restaurantId);

      const { data, error } = await supabase.rpc(
        "get_month_canceled_orders_amount",
        {
          p_restaurant_id: restaurantId,
        },
      );

      if (error) {
        console.error("❌ ERROR - RPC error:", error);
        throw new Error(
          `Error getting month canceled orders amount: ${error.message}`,
        );
      }

      console.log("✅ SUCCESS - Month canceled orders amount retrieved:", data);
      return data as MonthCanceledOrdersAmount;
    } catch (error) {
      console.error(
        "❌ ERROR - Failed to get month canceled orders amount:",
        error,
      );
      throw error;
    }
  };

/**
 * Get this month's revenue vs last month
 */
export const getMonthRevenue = async (): Promise<MonthRevenue> => {
  console.log("🔍 DEBUG - Starting getMonthRevenue");

  try {
    const restaurantId = await getCurrentRestaurantId();
    if (!restaurantId) throw new Error("No restaurant found");

    console.log("📦 DATA - restaurant_id:", restaurantId);

    const { data, error } = await supabase.rpc("get_month_revenue", {
      p_restaurant_id: restaurantId,
    });

    if (error) {
      console.error("❌ ERROR - RPC error:", error);
      throw new Error(`Error getting month revenue: ${error.message}`);
    }

    console.log("✅ SUCCESS - Month revenue retrieved:", data);
    return data as MonthRevenue;
  } catch (error) {
    console.error("❌ ERROR - Failed to get month revenue:", error);
    throw error;
  }
};

/**
 * Get top 10 most ordered products
 */
export const getPopularProducts = async (
  params: GetPopularProductsParams,
): Promise<GetPopularProductsResponse> => {
  console.log("🔍 DEBUG - Starting getPopularProducts");

  try {
    const restaurantId = await getCurrentRestaurantId();
    if (!restaurantId) throw new Error("No restaurant found");

    console.log("📦 DATA - restaurant_id:", restaurantId, "params:", params);

    const { data, error } = await supabase.rpc("get_popular_products", {
      p_restaurant_id: restaurantId,
      p_from: params.from?.toISOString() || null,
      p_to: params.to?.toISOString() || null,
    });

    if (error) {
      console.error("❌ ERROR - RPC error:", error);
      throw new Error(`Error getting popular products: ${error.message}`);
    }

    console.log("✅ SUCCESS - Popular products retrieved:", data);
    return (data as GetPopularProductsResponse) || [];
  } catch (error) {
    console.error("❌ ERROR - Failed to get popular products:", error);
    throw error;
  }
};

/**
 * Get daily revenue breakdown for a date range
 */
export const getDailyRevenueInPeriod = async (
  params: GetDailyRevenueInPeriodParams,
): Promise<GetDailyRevenueInPeriodResponse> => {
  console.log("🔍 DEBUG - Starting getDailyRevenueInPeriod");

  try {
    const restaurantId = await getCurrentRestaurantId();
    if (!restaurantId) throw new Error("No restaurant found");

    console.log("📦 DATA - restaurant_id:", restaurantId, "params:", params);

    const { data, error } = await supabase.rpc("get_daily_revenue_in_period", {
      p_restaurant_id: restaurantId,
      p_from: params.from?.toISOString() || null,
      p_to: params.to?.toISOString() || null,
    });

    if (error) {
      console.error("❌ ERROR - RPC error:", error);
      throw new Error(`Error getting daily revenue in period: ${error.message}`);
    }

    console.log("✅ SUCCESS - Daily revenue in period retrieved:", data);
    return (data as GetDailyRevenueInPeriodResponse) || [];
  } catch (error) {
    console.error("❌ ERROR - Failed to get daily revenue in period:", error);
    throw error;
  }
};

/**
 * Get detailed sales transactions with items
 */
export const getSalesTransactions = async (
  params: GetSalesTransactionsParams,
): Promise<GetSalesTransactionsResponse> => {
  console.log("🔍 DEBUG - Starting getSalesTransactions");

  try {
    const restaurantId = await getCurrentRestaurantId();
    if (!restaurantId) throw new Error("No restaurant found");

    console.log("📦 DATA - restaurant_id:", restaurantId, "params:", params);

    const { data, error } = await supabase.rpc("get_sales_transactions", {
      p_restaurant_id: restaurantId,
      p_from: params.from?.toISOString() || null,
      p_to: params.to?.toISOString() || null,
    });

    if (error) {
      console.error("❌ ERROR - RPC error:", error);
      throw new Error(`Error getting sales transactions: ${error.message}`);
    }

    console.log("✅ SUCCESS - Sales transactions retrieved:", data);
    return (data as GetSalesTransactionsResponse) || [];
  } catch (error) {
    console.error("❌ ERROR - Failed to get sales transactions:", error);
    throw error;
  }
};
