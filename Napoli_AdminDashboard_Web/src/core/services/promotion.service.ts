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
  console.log('🔍 DEBUG - Starting getPromotions');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase.rpc('get_admin_promotions', {
    p_restaurant_id: restaurantId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Promotions retrieved');

  return (data || []).map((p: any) => toCamelCase<Promotion>(p));
};

export const createPromotion = async (
  payload: CreatePromotionPayload,
  image?: File,
): Promise<Promotion> => {
  console.log('🔍 DEBUG - Starting createPromotion');

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

  const { data, error } = await supabase.rpc('create_admin_promotion', {
    p_restaurant_id: restaurantId,
    p_name: payload.name,
    p_type: payload.type,
    p_start_date: payload.startDate ? payload.startDate.toISOString() : new Date().toISOString(),
    p_end_date: payload.endDate ? payload.endDate.toISOString() : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
    p_description: payload.description || null,
    p_discount_percentage: payload.discountPercentage || null,
    p_discount_amount_cents: payload.discountAmountCents || null,
    p_minimum_order_cents: payload.minimumOrderCents || 0,
    p_maximum_discount_cents: payload.maximumDiscountCents || null,
    p_max_uses: payload.maxUses || null,
    p_max_uses_per_customer: payload.maxUsesPerCustomer || 1,
    p_image_url: imageUrl || null,
    p_banner_url: null,
    p_is_active: payload.isActive ?? true,
    p_is_featured: payload.isFeatured ?? false,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Promotion created');

  return toCamelCase<Promotion>(data);
};

export const updatePromotion = async (
  payload: UpdatePromotionPayload,
  image?: File,
): Promise<Promotion> => {
  console.log('🔍 DEBUG - Starting updatePromotion for id:', payload.id);

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

  const { data, error } = await supabase.rpc('update_admin_promotion', {
    p_promotion_id: payload.id,
    p_name: payload.name || null,
    p_description: payload.description || null,
    p_type: payload.type || null,
    p_discount_percentage: payload.discountPercentage || null,
    p_discount_amount_cents: payload.discountAmountCents || null,
    p_minimum_order_cents: payload.minimumOrderCents || null,
    p_maximum_discount_cents: payload.maximumDiscountCents || null,
    p_start_date: payload.startDate?.toISOString() || null,
    p_end_date: payload.endDate?.toISOString() || null,
    p_max_uses: payload.maxUses || null,
    p_max_uses_per_customer: payload.maxUsesPerCustomer || null,
    p_image_url: imageUrl || null,
    p_banner_url: null,
    p_is_active: payload.isActive ?? null,
    p_is_featured: payload.isFeatured ?? null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Promotion updated');

  return toCamelCase<Promotion>(data);
};

export const deletePromotion = async (id: string): Promise<void> => {
  console.log('🔍 DEBUG - Starting deletePromotion for id:', id);

  const { error } = await supabase.rpc('delete_admin_promotion', {
    p_promotion_id: id,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Promotion deleted');
};

export const togglePromotionStatus = async (
  id: string,
  isActive: boolean,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting togglePromotionStatus for id:', id);

  const { error } = await supabase.rpc('toggle_promotion_status', {
    p_promotion_id: id,
    p_is_active: isActive,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Promotion status toggled');
};

// --- Coupons ---

export const getCoupons = async (): Promise<Coupon[]> => {
  console.log('🔍 DEBUG - Starting getCoupons');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase.rpc('get_admin_coupons', {
    p_restaurant_id: restaurantId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Coupons retrieved');

  return (data || []).map((c: any) => toCamelCase<Coupon>(c));
};

export const createCoupon = async (
  payload: CreateCouponPayload,
): Promise<Coupon> => {
  console.log('🔍 DEBUG - Starting createCoupon');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase.rpc('create_admin_coupon', {
    p_restaurant_id: restaurantId,
    p_code: payload.code,
    p_type: payload.type,
    p_description: payload.description || null,
    p_discount_percentage: payload.discountPercentage || null,
    p_discount_amount_cents: payload.discountAmountCents || null,
    p_minimum_order_cents: payload.minimumOrderCents || 0,
    p_maximum_discount_cents: payload.maximumDiscountCents || null,
    p_valid_from: payload.validFrom?.toISOString() || null,
    p_valid_until: payload.validUntil?.toISOString() || null,
    p_max_uses: payload.maxUses || null,
    p_max_uses_per_customer: payload.maxUsesPerCustomer || 1,
    p_is_active: payload.isActive ?? true,
    p_first_order_only: false,
    p_specific_customer_ids: null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Coupon created');

  return toCamelCase<Coupon>(data);
};

export const updateCoupon = async (
  payload: UpdateCouponPayload,
): Promise<Coupon> => {
  console.log('🔍 DEBUG - Starting updateCoupon for id:', payload.id);

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase.rpc('update_admin_coupon', {
    p_coupon_id: payload.id,
    p_code: payload.code || null,
    p_description: payload.description || null,
    p_type: payload.type || null,
    p_discount_percentage: payload.discountPercentage || null,
    p_discount_amount_cents: payload.discountAmountCents || null,
    p_minimum_order_cents: payload.minimumOrderCents || null,
    p_maximum_discount_cents: payload.maximumDiscountCents || null,
    p_valid_from: payload.validFrom?.toISOString() || null,
    p_valid_until: payload.validUntil?.toISOString() || null,
    p_max_uses: payload.maxUses || null,
    p_max_uses_per_customer: payload.maxUsesPerCustomer || null,
    p_is_active: payload.isActive ?? null,
    p_first_order_only: null,
    p_specific_customer_ids: null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Coupon updated');

  return toCamelCase<Coupon>(data);
};

export const deleteCoupon = async (id: string): Promise<void> => {
  console.log('🔍 DEBUG - Starting deleteCoupon for id:', id);

  const { error } = await supabase.rpc('delete_admin_coupon', {
    p_coupon_id: id,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Coupon deleted');
};

export const toggleCouponStatus = async (
  id: string,
  isActive: boolean,
): Promise<void> => {
  console.log('🔍 DEBUG - Starting toggleCouponStatus for id:', id);

  const { error } = await supabase.rpc('toggle_coupon_status', {
    p_coupon_id: id,
    p_is_active: isActive,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Coupon status toggled');
};
