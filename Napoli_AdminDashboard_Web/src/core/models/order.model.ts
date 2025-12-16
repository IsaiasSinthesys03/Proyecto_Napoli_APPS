// src/core/models/order.model.ts

import { z } from "zod";

// OrderStatus enum matching schema.sql exactly
export const orderStatus = z.enum([
  "pending",
  "accepted",
  "processing",
  "ready",
  "delivering",
  "delivered",
  "cancelled",
]);

export type OrderStatusType = z.infer<typeof orderStatus>;

export const orderFiltersSchema = z.object({
  orderId: z.string().optional(),
  customerName: z.string().optional(),
  status: z.array(orderStatus).optional(),
});

export type GetOrdersParams = z.infer<typeof orderFiltersSchema> & {
  page?: number;
};

export interface OrderItem {
  id: string;
  productId: string | null;
  variantId: string | null;
  productName: string;
  variantName: string | null;
  productImageUrl: string | null;
  quantity: number;
  unitPriceCents: number;
  totalPriceCents: number;
  notes: string | null;
}

export interface Order {
  id: string;
  restaurantId: string;
  orderNumber: string;
  subtotalCents: number;
  taxCents: number;
  deliveryFeeCents: number;
  tipCents: number;
  discountCents: number;
  totalCents: number;
  driverId: string | null;
  driverEarningsCents: number;
  customerId: string | null;
  deliveryAddressId: string | null;
  couponId: string | null;
  customerSnapshot: { name: string; email: string; phone: string } | null;
  addressSnapshot: {
    street: string;
    city: string;
    lat: number;
    lng: number;
  } | null;
  orderType: "delivery" | "pickup" | "dine_in";
  distanceKm: number | null;
  estimatedPrepMinutes: number | null;
  estimatedDeliveryMinutes: number | null;
  status: OrderStatusType;
  paymentMethod: string | null;
  paymentStatus: string;
  paymentReference: string | null;
  customerNotes: string | null;
  kitchenNotes: string | null;
  driverNotes: string | null;
  cancellationReason: string | null;
  cancelledBy: "customer" | "restaurant" | "driver" | "system" | null;
  customerRating: number | null;
  customerReview: string | null;
  driverRating: number | null;
  foodRating: number | null;
  createdAt: string;
  confirmedAt: string | null;
  acceptedAt: string | null;
  processingAt: string | null;
  readyAt: string | null;
  pickedUpAt: string | null;
  deliveredAt: string | null;
  cancelledAt: string | null;
  updatedAt: string;
  // Joined data
  customer?: {
    name: string;
    phone?: string | null;
    email: string;
  };
  driver?: {
    id: string;
    name: string;
  } | null;
  orderItems?: OrderItem[];
}

export interface PaginatedOrders {
  results: Order[];
  meta: {
    pageIndex: number;
    perPage: number;
    totalCount: number;
  };
}
