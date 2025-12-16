// src/core/services/category.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  Category,
  CreateCategoryPayload,
  UpdateCategoryPayload,
} from "@/core/models/category.model";
import { toCamelCase } from "@/core/utils/utils";

async function uploadImage(
  file: File,
  restaurantId: string,
  folder: string,
): Promise<string> {
  const fileExt = file.name.split(".").pop();
  const fileName = `${folder}/${restaurantId}/${Date.now()}.${fileExt}`;

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
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase
    .from("categories")
    .select("*")
    .eq("restaurant_id", restaurantId)
    .order("display_order", { ascending: true });

  if (error) throw new Error(error.message);
  return (data || []).map((c) => toCamelCase<Category>(c));
};

export const createCategory = async (
  payload: CreateCategoryPayload,
): Promise<Category> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl: string | null = null;
  if (payload.image) {
    imageUrl = await uploadImage(payload.image, restaurantId, "categories");
  }

  const { data, error } = await supabase
    .from("categories")
    .insert({
      restaurant_id: restaurantId,
      name: payload.name,
      image_url: imageUrl,
    })
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Category>(data);
};

export const updateCategory = async (
  payload: UpdateCategoryPayload,
): Promise<Category> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const updateData: Record<string, unknown> = {};

  if (payload.name) {
    updateData.name = payload.name;
  }

  if (payload.image) {
    updateData.image_url = await uploadImage(
      payload.image,
      restaurantId,
      "categories",
    );
  }

  const { data, error } = await supabase
    .from("categories")
    .update(updateData)
    .eq("id", payload.id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Category>(data);
};

export const deleteCategory = async (categoryId: string): Promise<void> => {
  const { error } = await supabase
    .from("categories")
    .delete()
    .eq("id", categoryId);

  if (error) throw new Error(error.message);
};
