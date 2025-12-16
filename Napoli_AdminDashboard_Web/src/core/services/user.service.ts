// src/core/services/user.service.ts
import { supabase } from "@/core/lib/supabaseClient";
import { UpdateProfileParams, User } from "@/core/models/user.model";

export const getProfile = async (): Promise<User | null> => {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  return {
    id: user.id,
    email: user.email || "",
    name: user.user_metadata?.name || "",
  };
};

export const updateProfile = async (
  params: UpdateProfileParams,
): Promise<void> => {
  const { error } = await supabase.auth.updateUser({
    data: {
      name: params.name,
    },
  });
  if (error) throw new Error(error.message);
};
