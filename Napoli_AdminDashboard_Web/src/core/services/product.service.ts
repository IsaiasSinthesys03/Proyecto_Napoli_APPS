// src/core/services/product.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  CreateProductPayload,
  Product,
  UpdateProductPayload,
} from "@/core/models/product.model";
import { toCamelCase } from "@/core/utils/utils";

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
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase
    .from("products")
    .select(
      `
      *,
      category:categories(id, name)
    `,
    )
    .eq("restaurant_id", restaurantId)
    .order("display_order", { ascending: true });

  if (error) throw new Error(error.message);
  return (data || []).map((p) => toCamelCase<Product>(p));
};

export const getProduct = async (id: string): Promise<Product> => {
  const { data, error } = await supabase
    .from("products")
    .select(
      `
      *,
      category:categories(id, name)
    `,
    )
    .eq("id", id)
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Product>(data);
};

export const createProduct = async (
  payload: CreateProductPayload,
  image?: File,
): Promise<Product> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl = payload.imageUrl;
  if (image) {
    imageUrl = await uploadProductImage(image, restaurantId);
  }

  const { data, error } = await supabase
    .from("products")
    .insert({
      restaurant_id: restaurantId,
      name: payload.name,
      description: payload.description || null,
      short_description: payload.shortDescription || null,
      price_cents: payload.priceCents,
      compare_at_price_cents: payload.compareAtPriceCents || null,
      category_id: payload.categoryId || null,
      image_url: imageUrl || null,
      is_available: payload.isAvailable ?? true,
      is_featured: payload.isFeatured ?? false,
      tags: payload.tags || [],
      allergens: payload.allergens || [],
      preparation_time_minutes: payload.preparationTimeMinutes || null,
      calories: payload.calories || null,
    })
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Product>(data);
};

export const updateProduct = async (
  payload: UpdateProductPayload,
  image?: File,
): Promise<Product> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const updateData: Record<string, unknown> = {};

  if (payload.name !== undefined) updateData.name = payload.name;
  if (payload.description !== undefined)
    updateData.description = payload.description;
  if (payload.shortDescription !== undefined)
    updateData.short_description = payload.shortDescription;
  if (payload.priceCents !== undefined)
    updateData.price_cents = payload.priceCents;
  if (payload.compareAtPriceCents !== undefined)
    updateData.compare_at_price_cents = payload.compareAtPriceCents;
  if (payload.categoryId !== undefined)
    updateData.category_id = payload.categoryId || null;
  if (payload.isAvailable !== undefined)
    updateData.is_available = payload.isAvailable;
  if (payload.isFeatured !== undefined)
    updateData.is_featured = payload.isFeatured;
  if (payload.isNew !== undefined) updateData.is_new = payload.isNew;
  if (payload.isBestseller !== undefined)
    updateData.is_bestseller = payload.isBestseller;
  if (payload.tags !== undefined) updateData.tags = payload.tags;
  if (payload.allergens !== undefined) updateData.allergens = payload.allergens;
  if (payload.preparationTimeMinutes !== undefined)
    updateData.preparation_time_minutes = payload.preparationTimeMinutes;
  if (payload.calories !== undefined) updateData.calories = payload.calories;
  if (payload.displayOrder !== undefined)
    updateData.display_order = payload.displayOrder;

  if (image) {
    updateData.image_url = await uploadProductImage(image, restaurantId);
  } else if (payload.imageUrl !== undefined) {
    updateData.image_url = payload.imageUrl;
  }

  const { data, error } = await supabase
    .from("products")
    .update(updateData)
    .eq("id", payload.id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Product>(data);
};

export const deleteProduct = async (productId: string): Promise<void> => {
  const { error } = await supabase
    .from("products")
    .delete()
    .eq("id", productId);

  if (error) throw new Error(error.message);
};

export const toggleProductAvailability = async (
  id: string,
  isAvailable: boolean,
): Promise<Product> => {
  const { data, error } = await supabase
    .from("products")
    .update({ is_available: isAvailable })
    .eq("id", id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Product>(data);
};
