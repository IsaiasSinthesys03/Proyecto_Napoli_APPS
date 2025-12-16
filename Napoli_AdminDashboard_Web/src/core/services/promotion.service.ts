// src/core/services/promotion.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  Coupon,
  CreateCouponPayload,
  CreatePromotionPayload,
  Promotion,
  UpdateCouponPayload,
  UpdatePromotionPayload,
} from "@/core/models/promotion.model";
import { toCamelCase } from "@/core/utils/utils";

// --- Promotions ---

export const getPromotions = async (): Promise<Promotion[]> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase
    .from("promotions")
    .select("*")
    .eq("restaurant_id", restaurantId)
    .order("created_at", { ascending: false });

  if (error) throw new Error(error.message);
  return (data || []).map((p) => toCamelCase<Promotion>(p));
};

export const createPromotion = async (
  payload: CreatePromotionPayload,
  image?: File,
): Promise<Promotion> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl = payload.imageUrl;
  if (image) {
    const fileExt = image.name.split(".").pop();
    const fileName = `promotions/${restaurantId}/${Date.now()}.${fileExt}`;
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from("product-images")
      .upload(fileName, image);

    if (uploadError) throw new Error(uploadError.message);

    const {
      data: { publicUrl },
    } = supabase.storage.from("product-images").getPublicUrl(uploadData.path);

    imageUrl = publicUrl;
  }

  const { data, error } = await supabase
    .from("promotions")
    .insert({
      restaurant_id: restaurantId,
      name: payload.name,
      description: payload.description,
      type: payload.type,
      discount_percentage: payload.discountPercentage,
      discount_amount_cents: payload.discountAmountCents,
      minimum_order_cents: payload.minimumOrderCents,
      maximum_discount_cents: payload.maximumDiscountCents,
      start_date: payload.startDate.toISOString(),
      end_date: payload.endDate.toISOString(),
      max_uses: payload.maxUses,
      max_uses_per_customer: payload.maxUsesPerCustomer,
      image_url: imageUrl,
      is_active: payload.isActive ?? true,
      is_featured: payload.isFeatured ?? false,
    })
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Promotion>(data);
};

export const updatePromotion = async (
  payload: UpdatePromotionPayload,
  image?: File,
): Promise<Promotion> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const updateData: Record<string, unknown> = {};
  if (payload.name !== undefined) updateData.name = payload.name;
  if (payload.description !== undefined)
    updateData.description = payload.description;
  if (payload.type !== undefined) updateData.type = payload.type;
  if (payload.discountPercentage !== undefined)
    updateData.discount_percentage = payload.discountPercentage;
  if (payload.discountAmountCents !== undefined)
    updateData.discount_amount_cents = payload.discountAmountCents;
  if (payload.minimumOrderCents !== undefined)
    updateData.minimum_order_cents = payload.minimumOrderCents;
  if (payload.maximumDiscountCents !== undefined)
    updateData.maximum_discount_cents = payload.maximumDiscountCents;
  if (payload.startDate)
    updateData.start_date = payload.startDate.toISOString();
  if (payload.endDate) updateData.end_date = payload.endDate.toISOString();
  if (payload.maxUses !== undefined) updateData.max_uses = payload.maxUses;
  if (payload.maxUsesPerCustomer !== undefined)
    updateData.max_uses_per_customer = payload.maxUsesPerCustomer;
  if (payload.isActive !== undefined) updateData.is_active = payload.isActive;
  if (payload.isFeatured !== undefined)
    updateData.is_featured = payload.isFeatured;

  if (image) {
    const fileExt = image.name.split(".").pop();
    const fileName = `promotions/${restaurantId}/${Date.now()}.${fileExt}`;
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from("product-images")
      .upload(fileName, image);

    if (uploadError) throw new Error(uploadError.message);
    const {
      data: { publicUrl },
    } = supabase.storage.from("product-images").getPublicUrl(uploadData.path);
    updateData.image_url = publicUrl;
  }

  const { data, error } = await supabase
    .from("promotions")
    .update(updateData)
    .eq("id", payload.id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Promotion>(data);
};

export const deletePromotion = async (id: string): Promise<void> => {
  const { error } = await supabase.from("promotions").delete().eq("id", id);
  if (error) throw new Error(error.message);
};

export const togglePromotionStatus = async (
  id: string,
  isActive: boolean,
): Promise<void> => {
  const { error } = await supabase
    .from("promotions")
    .update({ is_active: isActive })
    .eq("id", id);
  if (error) throw new Error(error.message);
};

// --- Coupons ---

export const getCoupons = async (): Promise<Coupon[]> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase
    .from("coupons")
    .select("*")
    .eq("restaurant_id", restaurantId)
    .order("created_at", { ascending: false });

  if (error) throw new Error(error.message);
  return (data || []).map((c) => toCamelCase<Coupon>(c));
};

export const createCoupon = async (
  payload: CreateCouponPayload,
): Promise<Coupon> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase
    .from("coupons")
    .insert({
      restaurant_id: restaurantId,
      code: payload.code,
      description: payload.description,
      type: payload.type,
      discount_percentage: payload.discountPercentage,
      discount_amount_cents: payload.discountAmountCents,
      minimum_order_cents: payload.minimumOrderCents,
      maximum_discount_cents: payload.maximumDiscountCents,
      valid_from: payload.validFrom?.toISOString(),
      valid_until: payload.validUntil?.toISOString(),
      max_uses: payload.maxUses,
      max_uses_per_customer: payload.maxUsesPerCustomer,
      is_active: payload.isActive ?? true,
    })
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Coupon>(data);
};

export const updateCoupon = async (
  payload: UpdateCouponPayload,
): Promise<Coupon> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const updateData: Record<string, unknown> = {};
  if (payload.code !== undefined) updateData.code = payload.code;
  if (payload.description !== undefined)
    updateData.description = payload.description;
  if (payload.type !== undefined) updateData.type = payload.type;
  if (payload.discountPercentage !== undefined)
    updateData.discount_percentage = payload.discountPercentage;
  if (payload.discountAmountCents !== undefined)
    updateData.discount_amount_cents = payload.discountAmountCents;
  if (payload.minimumOrderCents !== undefined)
    updateData.minimum_order_cents = payload.minimumOrderCents;
  if (payload.maximumDiscountCents !== undefined)
    updateData.maximum_discount_cents = payload.maximumDiscountCents;
  if (payload.validFrom)
    updateData.valid_from = payload.validFrom.toISOString();
  if (payload.validUntil)
    updateData.valid_until = payload.validUntil.toISOString();
  if (payload.maxUses !== undefined) updateData.max_uses = payload.maxUses;
  if (payload.maxUsesPerCustomer !== undefined)
    updateData.max_uses_per_customer = payload.maxUsesPerCustomer;
  if (payload.isActive !== undefined) updateData.is_active = payload.isActive;

  const { data, error } = await supabase
    .from("coupons")
    .update(updateData)
    .eq("id", payload.id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Coupon>(data);
};

export const deleteCoupon = async (id: string): Promise<void> => {
  const { error } = await supabase.from("coupons").delete().eq("id", id);
  if (error) throw new Error(error.message);
};

export const toggleCouponStatus = async (
  id: string,
  isActive: boolean,
): Promise<void> => {
  const { error } = await supabase
    .from("coupons")
    .update({ is_active: isActive })
    .eq("id", id);
  if (error) throw new Error(error.message);
};
