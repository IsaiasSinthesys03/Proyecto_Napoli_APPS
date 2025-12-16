// src/core/hooks/useMetrics.ts
import { useQuery } from "@tanstack/react-query";

import {
  GetDailyRevenueInPeriodParams,
  GetPopularProductsParams,
  GetSalesTransactionsParams,
} from "@/core/models";
import * as MetricsService from "@/core/services/metrics.service";

export const useGetDayOrdersAmountQuery = () => {
  return useQuery({
    queryKey: ["metrics", "day-orders-amount"],
    queryFn: MetricsService.getDayOrdersAmount,
  });
};

export const useGetMonthOrdersAmountQuery = () => {
  return useQuery({
    queryKey: ["metrics", "month-orders-amount"],
    queryFn: MetricsService.getMonthOrdersAmount,
  });
};

export const useGetMonthCanceledOrdersAmountQuery = () => {
  return useQuery({
    queryKey: ["metrics", "month-canceled-orders-amount"],
    queryFn: MetricsService.getMonthCanceledOrdersAmount,
  });
};

export const useGetMonthRevenueQuery = () => {
  return useQuery({
    queryKey: ["metrics", "month-revenue"],
    queryFn: MetricsService.getMonthRevenue,
  });
};

export const useGetPopularProductsQuery = (
  params: GetPopularProductsParams,
) => {
  return useQuery({
    queryKey: ["metrics", "popular-products", params],
    queryFn: () => MetricsService.getPopularProducts(params),
  });
};

export const useGetDailyRevenueInPeriodQuery = (
  params: GetDailyRevenueInPeriodParams,
) => {
  return useQuery({
    queryKey: ["metrics", "daily-revenue-in-period", params],
    queryFn: () => MetricsService.getDailyRevenueInPeriod(params),
    enabled: !!params.from && !!params.to,
  });
};

export const useGetSalesTransactionsQuery = (
  params: GetSalesTransactionsParams,
) => {
  return useQuery({
    queryKey: ["sales", "transactions", params],
    queryFn: () => MetricsService.getSalesTransactions(params),
  });
};
