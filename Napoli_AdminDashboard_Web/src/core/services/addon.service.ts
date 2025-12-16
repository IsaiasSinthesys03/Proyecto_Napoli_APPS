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
    .from("addon-images")
    .upload(fileName, file);

  if (error) throw new Error(error.message);

  const {
    data: { publicUrl },
  } = supabase.storage.from("addon-images").getPublicUrl(data.path);

  return publicUrl;
}

export const getAddons = async (): Promise<Addon[]> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { data, error } = await supabase
    .from("addons")
    .select("*")
    .eq("restaurant_id", restaurantId)
    .order("name", { ascending: true });

  if (error) throw new Error(error.message);
  return (data || []).map((a) => toCamelCase<Addon>(a));
};

export const createAddon = async (
  payload: CreateAddonPayload,
): Promise<Addon> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  let imageUrl: string | null = null;
  if (payload.image) {
    imageUrl = await uploadImage(payload.image, restaurantId);
  }

  const { data, error } = await supabase
    .from("addons")
    .insert({
      restaurant_id: restaurantId,
      name: payload.name,
      description: payload.description || null,
      price_cents: payload.priceCents,
      image_url: imageUrl,
    })
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Addon>(data);
};

export const updateAddon = async (
  payload: UpdateAddonPayload,
): Promise<Addon> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const updateData: Record<string, unknown> = {};

  if (payload.name !== undefined) updateData.name = payload.name;
  if (payload.description !== undefined)
    updateData.description = payload.description;
  if (payload.priceCents !== undefined)
    updateData.price_cents = payload.priceCents;
  if (payload.isAvailable !== undefined)
    updateData.is_available = payload.isAvailable;

  if (payload.image) {
    updateData.image_url = await uploadImage(payload.image, restaurantId);
  }

  const { data, error } = await supabase
    .from("addons")
    .update(updateData)
    .eq("id", payload.id)
    .select()
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Addon>(data);
};

export const deleteAddon = async (addonId: string): Promise<void> => {
  const { error } = await supabase.from("addons").delete().eq("id", addonId);

  if (error) throw new Error(error.message);
};
