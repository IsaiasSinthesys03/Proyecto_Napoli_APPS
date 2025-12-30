// src/core/services/product.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  CreateProductPayload,
  Product,
  UpdateProductPayload,
} from "@/core/models/product.model";
import { toCamelCase, toSnakeCase } from "@/core/utils/utils";

async function uploadProductImage(
  file: File,
  restaurantId: string,
): Promise<string> {
  const fileExt = file.name.split(".").pop();
  const fileName = `products/${restaurantId}/${Date.now()}.${fileExt}`;

  const { data, error } = await supabase.storage
    .from("product-images")
    .upload(fileName, file);

  if (error) throw new Error(error.message);

  const {
    data: { publicUrl },
  } = supabase.storage.from("product-images").getPublicUrl(data.path);

  return publicUrl;
}

export const getProducts = async (): Promise<Product[]> => {
  console.log('🔍 DEBUG - Starting getProducts');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase.rpc('get_admin_products', {
    p_restaurant_id: restaurantId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Products retrieved');

  return (data || []).map((p: any) => toCamelCase<Product>(p));
};

export const getProduct = async (id: string): Promise<Product> => {
  console.log('🔍 DEBUG - Starting getProduct for id:', id);

  const { data, error } = await supabase.rpc('get_admin_product', {
    p_product_id: id,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Product retrieved');

  return toCamelCase<Product>(data);
};

export const createProduct = async (
  payload: CreateProductPayload,
  image?: File,
): Promise<Product> => {
  console.log('🔍 DEBUG - Starting createProduct');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl = payload.imageUrl;
  if (image) {
    imageUrl = await uploadProductImage(image, restaurantId);
  }

  const { data, error } = await supabase.rpc('create_admin_product', {
    p_restaurant_id: restaurantId,
    p_name: payload.name,
    p_description: payload.description || null,
    p_short_description: payload.shortDescription || null,
    p_price_cents: payload.priceCents,
    p_compare_at_price_cents: payload.compareAtPriceCents || null,
    p_category_id: payload.categoryId || null,
    p_image_url: imageUrl || null,
    p_is_available: payload.isAvailable ?? true,
    p_is_featured: payload.isFeatured ?? false,
    p_tags: payload.tags || [],
    p_allergens: payload.allergens || [],
    p_preparation_time_minutes: payload.preparationTimeMinutes || null,
    p_calories: payload.calories || null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Product created');

  return toCamelCase<Product>(data);
};

export const updateProduct = async (
  payload: UpdateProductPayload,
  image?: File,
): Promise<Product> => {
  console.log('🔍 DEBUG - Starting updateProduct for id:', payload.id);

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl = payload.imageUrl;
  if (image) {
    imageUrl = await uploadProductImage(image, restaurantId);
  }

  const { data, error } = await supabase.rpc('update_admin_product', {
    p_product_id: payload.id,
    p_name: payload.name || null,
    p_description: payload.description || null,
    p_short_description: payload.shortDescription || null,
    p_price_cents: payload.priceCents || null,
    p_compare_at_price_cents: payload.compareAtPriceCents || null,
    p_category_id: payload.categoryId || null,
    p_image_url: imageUrl || null,
    p_is_available: payload.isAvailable ?? null,
    p_is_featured: payload.isFeatured ?? null,
    p_is_new: payload.isNew ?? null,
    p_is_bestseller: payload.isBestseller ?? null,
    p_tags: payload.tags || null,
    p_allergens: payload.allergens || null,
    p_preparation_time_minutes: payload.preparationTimeMinutes || null,
    p_calories: payload.calories || null,
    p_display_order: payload.displayOrder || null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Product updated');

  return toCamelCase<Product>(data);
};

export const deleteProduct = async (productId: string): Promise<void> => {
  console.log('🔍 DEBUG - Starting deleteProduct for id:', productId);

  const { error } = await supabase.rpc('delete_admin_product', {
    p_product_id: productId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Product deleted');
};

export const toggleProductAvailability = async (
  id: string,
  isAvailable: boolean,
): Promise<Product> => {
  console.log('🔍 DEBUG - Starting toggleProductAvailability for id:', id);

  const { data, error } = await supabase.rpc('toggle_admin_product_availability', {
    p_product_id: id,
    p_is_available: isAvailable,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Product availability toggled');

  return toCamelCase<Product>(data);
};

export const assignAddonsToProduct = async (
  productId: string,
  addonIds: string[],
): Promise<void> => {
  console.log('🔍 DEBUG - Starting assignAddonsToProduct for product:', productId);
  console.log('📦 DATA - addon_ids:', addonIds);

  const { error } = await supabase.rpc('assign_addons_to_product', {
    p_product_id: productId,
    p_addon_ids: addonIds,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Addons assigned to product');
};
