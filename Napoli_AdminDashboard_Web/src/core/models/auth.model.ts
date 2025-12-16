// src/core/models/auth.model.ts
import { z } from "zod";

export const signInSchema = z.object({
  email: z.string().email(),
  password: z.string(),
});

export type SignInParams = z.infer<typeof signInSchema>;

export const changePasswordSchema = z.object({
  currentPassword: z.string(),
  newPassword: z.string(),
});

export type ChangePasswordParams = z.infer<typeof changePasswordSchema>;
