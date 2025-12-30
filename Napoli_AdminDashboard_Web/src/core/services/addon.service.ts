// src/core/services/addon.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  Addon,
  CreateAddonPayload,
  UpdateAddonPayload,
} from "@/core/models/addon.model";
import { toCamelCase } from "@/core/utils/utils";

async function uploadImage(file: File, restaurantId: string): Promise<string> {
  const fileExt = file.name.split(".").pop();
  const fileName = `addons/${restaurantId}/${Date.now()}.${fileExt}`;

  const { data, error } = await supabase.storage
    .from("product-images")
    .upload(fileName, file);

  if (error) throw new Error(error.message);

  const {
    data: { publicUrl },
  } = supabase.storage.from("product-images").getPublicUrl(data.path);

  return publicUrl;
}

export const getAddons = async (): Promise<Addon[]> => {
  console.log('🔍 DEBUG - Starting getAddons');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase.rpc('get_admin_addons', {
    p_restaurant_id: restaurantId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Addons retrieved');

  return (data || []).map((a: any) => toCamelCase<Addon>(a));
};

export const createAddon = async (
  payload: CreateAddonPayload,
): Promise<Addon> => {
  console.log('🔍 DEBUG - Starting createAddon');

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl: string | null = null;
  if (payload.image) {
    imageUrl = await uploadImage(payload.image, restaurantId);
  }

  const { data, error } = await supabase.rpc('create_admin_addon', {
    p_restaurant_id: restaurantId,
    p_name: payload.name,
    p_price_cents: payload.priceCents,
    p_description: payload.description || null,
    p_image_url: imageUrl,
    p_is_available: true,
    p_max_quantity: 10,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Addon created');

  return toCamelCase<Addon>(data);
};

export const updateAddon = async (
  payload: UpdateAddonPayload,
): Promise<Addon> => {
  console.log('🔍 DEBUG - Starting updateAddon for id:', payload.id);

  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl: string | undefined = undefined;
  if (payload.image) {
    imageUrl = await uploadImage(payload.image, restaurantId);
  }

  const { data, error } = await supabase.rpc('update_admin_addon', {
    p_addon_id: payload.id,
    p_name: payload.name || null,
    p_description: payload.description || null,
    p_price_cents: payload.priceCents || null,
    p_image_url: imageUrl || null,
    p_is_available: payload.isAvailable ?? null,
    p_max_quantity: null,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Addon updated');

  return toCamelCase<Addon>(data);
};

export const deleteAddon = async (addonId: string): Promise<void> => {
  console.log('🔍 DEBUG - Starting deleteAddon for id:', addonId);

  const { error } = await supabase.rpc('delete_admin_addon', {
    p_addon_id: addonId,
  });

  if (error) throw new Error(error.message);

  console.log('✅ SUCCESS - Addon deleted');
};
