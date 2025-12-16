// src/core/models/product.model.ts

export interface Product {
  id: string;
  restaurantId: string;
  categoryId: string | null;
  name: string;
  description: string | null;
  shortDescription: string | null;
  priceCents: number;
  compareAtPriceCents: number | null;
  costCents: number | null;
  imageUrl: string | null;
  images: string[];
  isAvailable: boolean;
  trackInventory: boolean;
  inventoryCount: number | null;
  lowStockThreshold: number;
  isFeatured: boolean;
  isNew: boolean;
  isBestseller: boolean;
  calories: number | null;
  preparationTimeMinutes: number | null;
  tags: string[];
  allergens: string[];
  displayOrder: number;
  totalSold: number;
  totalRevenueCents: number;
  createdAt: string;
  updatedAt: string;
  // Relation from join query
  category?: { id: string; name: string } | null;
}

export interface CreateProductPayload {
  name: string;
  description?: string;
  shortDescription?: string;
  priceCents: number;
  compareAtPriceCents?: number;
  categoryId?: string;
  imageUrl?: string;
  isAvailable?: boolean;
  isFeatured?: boolean;
  tags?: string[];
  allergens?: string[];
  preparationTimeMinutes?: number;
  calories?: number;
}

export interface UpdateProductPayload {
  id: string;
  name?: string;
  description?: string;
  shortDescription?: string;
  priceCents?: number;
  compareAtPriceCents?: number;
  categoryId?: string;
  imageUrl?: string;
  isAvailable?: boolean;
  isFeatured?: boolean;
  isNew?: boolean;
  isBestseller?: boolean;
  tags?: string[];
  allergens?: string[];
  preparationTimeMinutes?: number;
  calories?: number;
  displayOrder?: number;
}
