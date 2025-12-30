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
  vehicleBrand: string | null;
  vehicleModel: string | null;
  vehicleColor: string | null;
  vehicleYear: number | null;
  licensePlate: string | null;
  idDocumentUrl: string | null;
  licenseUrl: string | null;
  vehicleRegistrationUrl: string | null;
  insuranceUrl: string | null;
  status: DriverStatusType;
  isOnline: boolean;
  isOnDelivery: boolean;
  currentLatitude: number | null;
  currentLongitude: number | null;
  lastLocationUpdate: string | null;
  notificationsEnabled: boolean;
  emailNotificationsEnabled: boolean;
  preferredLanguage: string;
  fcmToken: string | null;
  maxConcurrentOrders: number;
  totalDeliveries: number;
  totalEarningsCents: number;
  ratingSum: number;
  ratingCount: number;
  averageRating: number | null;
  averageDeliveryMinutes: number | null;
  createdAt: string;
  updatedAt: string;
  approvedAt: string | null;
  lastDeliveryAt: string | null;
}

// Legacy compatibility alias
export type DeliveryMan = Driver;

export interface CreateDriverPayload {
  name: string;
  email: string;
  phone: string;
  password: string;
  photoUrl?: string;
  vehicleType?: VehicleType;
  vehicleBrand?: string;
  vehicleModel?: string;
  vehicleColor?: string;
  vehicleYear?: number;
  licensePlate?: string;
}

export interface UpdateDriverPayload {
  name?: string;
  email?: string;
  phone?: string;
  photoUrl?: string;
  vehicleType?: VehicleType;
  vehicleBrand?: string;
  vehicleModel?: string;
  vehicleColor?: string;
  vehicleYear?: number;
  licensePlate?: string;
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
