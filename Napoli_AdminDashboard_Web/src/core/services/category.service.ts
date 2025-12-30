// src/core/services/category.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  Category,
  CreateCategoryPayload,
  UpdateCategoryPayload,
} from "@/core/models/category.model";
import { toCamelCase } from "@/core/utils/utils";

async function uploadCategoryImage(
  file: File,
  restaurantId: string,
): Promise<string> {
  const fileExt = file.name.split(".").pop();
  const fileName = `categories/${restaurantId}/${Date.now()}.${fileExt}`;

  const { data, error } = await supabase.storage
    .from("category-images")
    .upload(fileName, file);

  if (error) throw new Error(error.message);

  const {
    data: { publicUrl },
  } = supabase.storage.from("category-images").getPublicUrl(data.path);

  return publicUrl;
}

export const getCategories = async (): Promise<Category[]> => {
  console.log('🔍 DEBUG - Starting getCategories');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase.rpc('get_admin_categories', {
    p_restaurant_id: restaurantId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Categories retrieved');

  return (data || []).map((c: any) => toCamelCase<Category>(c));
};

export const getCategory = async (id: string): Promise<Category> => {
  console.log('🔍 DEBUG - Starting getCategory for id:', id);

  const { data, error } = await supabase.rpc('get_admin_category', {
    p_category_id: id,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Category retrieved');

  return toCamelCase<Category>(data);
};

export const createCategory = async (
  payload: CreateCategoryPayload,
): Promise<Category> => {
  console.log('🔍 DEBUG - Starting createCategory');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl = payload.imageUrl;
  if (payload.image) {
    imageUrl = await uploadCategoryImage(payload.image, restaurantId);
  }

  const { data, error } = await supabase.rpc('create_admin_category', {
    p_restaurant_id: restaurantId,
    p_name: payload.name,
    p_description: payload.description || null,
    p_image_url: imageUrl || null,
    p_display_order: payload.displayOrder ?? 0,
    p_is_active: payload.isActive ?? true,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Category created');

  return toCamelCase<Category>(data);
};

export const updateCategory = async (
  payload: UpdateCategoryPayload,
): Promise<Category> => {
  console.log('🔍 DEBUG - Starting updateCategory for id:', payload.id);

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl = payload.imageUrl;
  if (payload.image) {
    imageUrl = await uploadCategoryImage(payload.image, restaurantId);
  }

  const { data, error } = await supabase.rpc('update_admin_category', {
    p_category_id: payload.id,
    p_name: payload.name || null,
    p_description: payload.description || null,
    p_image_url: imageUrl || null,
    p_display_order: payload.displayOrder ?? null,
    p_is_active: payload.isActive ?? null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Category updated');

  return toCamelCase<Category>(data);
};

export const deleteCategory = async (categoryId: string): Promise<void> => {
  console.log('🔍 DEBUG - Starting deleteCategory for id:', categoryId);

  const { error } = await supabase.rpc('delete_admin_category', {
    p_category_id: categoryId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Category deleted');
};
