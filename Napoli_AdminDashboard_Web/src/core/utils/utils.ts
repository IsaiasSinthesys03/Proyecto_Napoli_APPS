import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Type for database records (snake_case from Supabase)
type DatabaseRecord = Record<string, unknown>;

// Helper to convert snake_case to camelCase
export function toCamelCase<T>(obj: DatabaseRecord): T {
  const result: DatabaseRecord = {};
  for (const key in obj) {
    const camelKey = key.replace(/_([a-z])/g, (_, letter: string) =>
      letter.toUpperCase(),
    );
    result[camelKey] = obj[key];
  }
  return result as T;
}

// Helper to convert camelCase to snake_case
export function toSnakeCase(
  obj: Record<string, unknown>,
): Record<string, unknown> {
  const result: Record<string, unknown> = {};
  for (const key in obj) {
    const snakeKey = key.replace(
      /[A-Z]/g,
      (letter) => `_${letter.toLowerCase()}`,
    );
    result[snakeKey] = obj[key];
  }
  return result;
}
