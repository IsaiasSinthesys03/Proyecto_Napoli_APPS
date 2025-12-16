// src/core/models/delivery.model.ts

// DriverStatus enum matching schema.sql
export type DriverStatusType =
  | "pending"
  | "approved"
  | "active"
  | "inactive"
  | "suspended";

// VehicleType enum matching schema.sql
export type VehicleType = "moto" | "bici" | "auto" | "camioneta" | "otro";

export interface Driver {
  id: string;
  restaurantId: string;
  name: string;
  email: string;
  phone: string | null;
  photoUrl: string | null;
  vehicleType: VehicleType;
  licensePlate: string | null;
  status: DriverStatusType;
  isOnline: boolean;
  isOnDelivery: boolean;
  currentLatitude: number | null;
  currentLongitude: number | null;
  lastLocationAt: string | null;
  totalDeliveries: number;
  totalEarningsCents: number;
  averageRating: number;
  approvedAt: string | null;
  approvedBy: string | null;
  createdAt: string;
  updatedAt: string;
  // CourierApp settings
  emailNotificationsEnabled: boolean;
  preferredLanguage: string;
  fcmToken: string | null;
}

// Legacy compatibility alias
export type DeliveryMan = Driver;

export interface CreateDriverPayload {
  name: string;
  email: string;
  phone: string;
  vehicleType: VehicleType;
  licensePlate?: string;
  photoUrl?: string;
}

export interface UpdateDriverPayload {
  name?: string;
  email?: string;
  phone?: string;
  vehicleType?: VehicleType;
  licensePlate?: string;
  photoUrl?: string;
}

export interface GetDriversResponse {
  drivers: Driver[];
}

// Legacy compatibility alias
export interface GetDeliveryMenResponse {
  deliveryMen: Driver[];
}

export interface AssignDriverParams {
  orderId: string;
  driverId: string;
}

// Legacy compatibility alias
export interface AssignDeliveryManParams {
  orderId: string;
  deliveryManId: string;
}

// For live map display (deferred)
export interface DeliveryPerson {
  id: string;
  name: string;
  vehicle: string;
  orderId: string;
  address: string;
  latitude?: number;
  longitude?: number;
}
