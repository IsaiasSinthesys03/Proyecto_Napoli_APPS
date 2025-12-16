import { z } from "zod";

const envSchema = z.object({
  MODE: z.enum(["production", "development", "test"]),
  VITE_SUPABASE_URL: z.string().url(),
  VITE_SUPABASE_ANON_KEY: z.string().min(1),
  VITE_ENABLE_API_DELAY: z
    .string()
    .transform((value) => value === "true")
    .optional(),
});

export const env = envSchema.parse(import.meta.env);
