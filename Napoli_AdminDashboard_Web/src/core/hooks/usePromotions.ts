// src/core/hooks/usePromotions.ts
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import {
  CreateCouponPayload,
  CreatePromotionPayload,
  MarketingItem,
  UpdateCouponPayload,
  UpdatePromotionPayload,
} from "@/core/models/promotion.model";
import * as PromotionService from "@/core/services/promotion.service";

export function useMarketingData() {
  return useQuery({
    queryKey: ["marketing-data"],
    queryFn: async (): Promise<MarketingItem[]> => {
      const [promotions, coupons] = await Promise.all([
        PromotionService.getPromotions(),
        PromotionService.getCoupons(),
      ]);

      const marketingPromotions: MarketingItem[] = promotions.map((p) => ({
        id: p.id,
        kind: "promotion",
        name: p.name,
        description: p.description,
        type: p.type,
        startDate: p.startDate,
        endDate: p.endDate,
        isActive: p.isActive,
        imageUrl: p.imageUrl,
        original: p,
      }));

      const marketingCoupons: MarketingItem[] = coupons.map((c) => ({
        id: c.id,
        kind: "coupon",
        name: c.code, // Use code as primary identifier/name for coupons
        description: c.description,
        type: "Cupón", // Fixed type name for UI consistency with simplified view
        startDate: c.validFrom,
        endDate: c.validUntil,
        isActive: c.isActive,
        original: c,
      }));

      return [...marketingPromotions, ...marketingCoupons];
    },
  });
}

// --- Promotion Mutations ---

export function useCreatePromotion() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { payload: CreatePromotionPayload; image?: File }) =>
      PromotionService.createPromotion(data.payload, data.image),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["marketing-data"] });
    },
  });
}

export function useUpdatePromotion() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { payload: UpdatePromotionPayload; image?: File }) =>
      PromotionService.updatePromotion(data.payload, data.image),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["marketing-data"] });
    },
  });
}

export function useDeletePromotion() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: PromotionService.deletePromotion,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["marketing-data"] });
    },
  });
}

export function useTogglePromotionStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { id: string; isActive: boolean }) =>
      PromotionService.togglePromotionStatus(data.id, data.isActive),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["marketing-data"] });
    },
  });
}

// --- Coupon Mutations ---

export function useCreateCoupon() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: CreateCouponPayload) =>
      PromotionService.createCoupon(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["marketing-data"] });
    },
  });
}

export function useUpdateCoupon() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: UpdateCouponPayload) =>
      PromotionService.updateCoupon(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["marketing-data"] });
    },
  });
}

export function useDeleteCoupon() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: PromotionService.deleteCoupon,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["marketing-data"] });
    },
  });
}

export function useToggleCouponStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { id: string; isActive: boolean }) =>
      PromotionService.toggleCouponStatus(data.id, data.isActive),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["marketing-data"] });
    },
  });
}
