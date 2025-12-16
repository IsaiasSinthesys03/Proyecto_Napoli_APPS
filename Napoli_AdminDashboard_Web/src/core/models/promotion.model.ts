// src/core/models/promotion.model.ts

export type PromotionType = "percentage" | "fixed" | "bogo" | "bundle";
export type CouponType = "percentage" | "fixed";

export interface Promotion {
  id: string;
  restaurantId: string;
  name: string;
  description: string | null;
  type: PromotionType;
  discountPercentage: number | null;
  discountAmountCents: number | null;
  minimumOrderCents: number | null;
  maximumDiscountCents: number | null;
  startDate: string; // ISO string
  endDate: string; // ISO string
  maxUses: number | null;
  maxUsesPerCustomer: number | null;
  currentUses: number;
  imageUrl: string | null;
  bannerUrl: string | null;
  isActive: boolean;
  isFeatured: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Coupon {
  id: string;
  restaurantId: string;
  code: string;
  description: string | null;
  type: CouponType;
  discountPercentage: number | null;
  discountAmountCents: number | null;
  minimumOrderCents: number | null;
  maximumDiscountCents: number | null;
  validFrom: string | null; // ISO string
  validUntil: string | null; // ISO string
  maxUses: number | null;
  maxUsesPerCustomer: number | null;
  currentUses: number;
  isActive: boolean;
}

// Unified interface for UI display
export interface MarketingItem {
  id: string;
  kind: "promotion" | "coupon";
  name: string; // name for promotion, code for coupon
  description: string | null;
  type: string;
  startDate: string | null;
  endDate: string | null;
  isActive: boolean;
  imageUrl?: string | null; // Only for promotions
  original: Promotion | Coupon;
}

export interface CreatePromotionPayload {
  name: string;
  description?: string;
  type: PromotionType;
  discountPercentage?: number;
  discountAmountCents?: number;
  minimumOrderCents?: number;
  maximumDiscountCents?: number;
  startDate: Date;
  endDate: Date;
  maxUses?: number;
  maxUsesPerCustomer?: number;
  imageUrl?: string;
  isActive?: boolean;
  isFeatured?: boolean;
}

export interface UpdatePromotionPayload
  extends Partial<CreatePromotionPayload> {
  id: string;
}

export interface CreateCouponPayload {
  code: string;
  description?: string;
  type: CouponType;
  discountPercentage?: number;
  discountAmountCents?: number;
  minimumOrderCents?: number;
  maximumDiscountCents?: number;
  validFrom?: Date;
  validUntil?: Date;
  maxUses?: number;
  maxUsesPerCustomer?: number;
  isActive?: boolean;
}

export interface UpdateCouponPayload extends Partial<CreateCouponPayload> {
  id: string;
}
