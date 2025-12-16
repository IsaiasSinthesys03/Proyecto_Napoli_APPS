import { createClient } from "@supabase/supabase-js";

import { env } from "./env";

export const supabase = createClient(
  env.VITE_SUPABASE_URL,
  env.VITE_SUPABASE_ANON_KEY,
);

// Helper to get current restaurant ID from session
export async function getCurrentRestaurantId(): Promise<string | null> {
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session?.user?.email) return null;

  // Get admin's restaurant_id from restaurant_admins table by email
  const { data: admin, error } = await supabase
    .from("restaurant_admins")
    .select("restaurant_id")
    .eq("email", session.user.email)
    .maybeSingle();

  if (error) {
    console.error("Error fetching restaurant admin:", error.message);
    return null;
  }

  return admin?.restaurant_id || null;
}

// Helper to get current user
export async function getCurrentUser() {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user;
}
