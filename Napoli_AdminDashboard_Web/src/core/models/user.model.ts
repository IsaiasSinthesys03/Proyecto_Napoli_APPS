// src/core/models/user.model.ts
export interface User {
  id: string;
  name: string;
  email: string;
}

export interface UpdateProfileParams {
  name: string;
  description?: string;
}
