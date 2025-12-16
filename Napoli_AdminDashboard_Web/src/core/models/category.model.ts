// src/core/models/category.model.ts
export interface Category {
  id: string;
  name: string;
  imageUrl?: string;
  restaurantId: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateCategoryPayload {
  name: string;
  image?: File;
}

export interface UpdateCategoryPayload extends Partial<CreateCategoryPayload> {
  id: string;
}
