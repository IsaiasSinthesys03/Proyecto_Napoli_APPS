// src/core/models/addon.model.ts
export interface Addon {
  id: string;
  restaurantId: string;
  name: string;
  description: string | null;
  priceCents: number;
  imageUrl: string | null;
  isAvailable: boolean;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
}

export interface CreateAddonPayload {
  name: string;
  description?: string;
  priceCents: number;
  categoryIds?: string[];
  image?: File;
}

export interface UpdateAddonPayload {
  id: string;
  name?: string;
  description?: string;
  priceCents?: number;
  isAvailable?: boolean;
  categoryIds?: string[];
  image?: File;
}
