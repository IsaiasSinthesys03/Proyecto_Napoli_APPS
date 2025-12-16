// src/core/models/metrics.model.ts
export interface DayOrdersAmount {
  amount: number;
  diffFromYesterday: number;
}

export interface MonthOrdersAmount {
  amount: number;
  diffFromLastMonth: number;
}

export interface MonthCanceledOrdersAmount {
  amount: number;
  diffFromLastMonth: number;
}

export interface MonthRevenue {
  receipt: number;
  diffFromLastMonth: number;
}

export interface PopularProduct {
  product: string;
  amount: number;
}

export type GetPopularProductsResponse = PopularProduct[];

export interface DailyRevenue {
  date: string;
  receipt: number;
}

export type GetDailyRevenueInPeriodResponse = DailyRevenue[];

export interface SalesTransaction {
  id: string;
  date: string;
  customerName: string;
  total: number;
  items: {
    product: string;
    quantity: number;
    price: number;
  }[];
}

export type GetSalesTransactionsResponse = SalesTransaction[];

export interface GetDailyRevenueInPeriodParams {
  from?: Date;
  to?: Date;
}

export interface GetSalesTransactionsParams {
  from?: Date;
  to?: Date;
}

export interface GetPopularProductsParams {
  from?: Date;
  to?: Date;
}
