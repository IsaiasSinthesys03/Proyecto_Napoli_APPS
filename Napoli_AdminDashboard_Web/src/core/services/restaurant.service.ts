// src/core/services/restaurant.service.ts
import { getCurrentRestaurantId, supabase } from "@/core/lib/supabaseClient";
import {
  RegisterRestaurantParams,
  Restaurant,
  UpdateRestaurantProfileParams,
  UpdateRestaurantSettingsParams,
} from "@/core/models/restaurant.model";
import { toCamelCase, toSnakeCase } from "@/core/utils/utils";

export const getManagedRestaurant = async (): Promise<Restaurant | null> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) return null;

  const { data, error } = await supabase
    .from("restaurants")
    .select("*")
    .eq("id", restaurantId)
    .single();

  if (error) throw new Error(error.message);
  return toCamelCase<Restaurant>(data);
};

export const updateRestaurantProfile = async (
  params: UpdateRestaurantProfileParams,
): Promise<void> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { error } = await supabase
    .from("restaurants")
    .update(toSnakeCase(params as unknown as Record<string, unknown>))
    .eq("id", restaurantId);

  if (error) throw new Error(error.message);
};

export const updateRestaurantSettings = async (
  params: UpdateRestaurantSettingsParams,
): Promise<void> => {
  const restaurantId = await getCurrentRestaurantId();
  if (!restaurantId) throw new Error("No restaurant found");

  const { error } = await supabase
    .from("restaurants")
    .update(toSnakeCase(params as unknown as Record<string, unknown>))
    .eq("id", restaurantId);

  if (error) throw new Error(error.message);
};

export const registerRestaurant = async (
  params: RegisterRestaurantParams,
): Promise<void> => {
  // 1. Create auth user in Supabase
  const { data: authData, error: authError } = await supabase.auth.signUp({
    email: params.email,
    password: params.password,
  });

  if (authError) throw new Error(authError.message);
  if (!authData.user) throw new Error("No se pudo crear el usuario");

  // 2. Generate slug from restaurant name
  const slug = params.restaurantName
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");

  // 3. Create restaurant
  const { data: restaurantData, error: restaurantError } = await supabase
    .from("restaurants")
    .insert({
      name: params.restaurantName,
      slug: slug + "-" + Date.now(), // Ensure uniqueness
      email: params.email,
      phone: params.phone,
    })
    .select()
    .single();

  if (restaurantError) throw new Error(restaurantError.message);

  // 4. Create restaurant_admin linking user to restaurant (by email, not by id)
  const { error: adminError } = await supabase
    .from("restaurant_admins")
    .insert({
      restaurant_id: restaurantData.id,
      name: params.managerName,
      email: params.email,
      phone: params.phone,
      role: "owner",
      is_primary: true,
    });

  if (adminError) throw new Error(adminError.message);
};
