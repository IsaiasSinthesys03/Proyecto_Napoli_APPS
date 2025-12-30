// src/core/models/restaurant.model.ts

export interface Restaurant {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  logoUrl: string | null;
  bannerUrl: string | null;
  primaryColor: string | null;
  secondaryColor: string | null;
  email: string;
  phone: string | null;
  whatsapp: string | null;
  website: string | null;
  address: string | null;
  city: string | null;
  state: string | null;
  country: string | null;
  postalCode: string | null;
  latitude: number | null;
  longitude: number | null;
  timezone: string;
  businessHours: Record<
    string,
    { enabled: boolean; open: string | null; close: string | null }
  >;
  currencyCode: string;
  currencySymbol: string;
  currencyPosition: "before" | "after";
  decimalSeparator: string;
  thousandsSeparator: string;
  decimalPlaces: number;
  taxRatePercentage: number;
  taxIncludedInPrices: boolean;
  isOpen: boolean;
  acceptsDelivery: boolean;
  acceptsPickup: boolean;
  acceptsDineIn: boolean;
  deliveryRadiusKm: number | null;
  minimumOrderCents: number;
  deliveryFeeCents: number;
  deliveryFeePerKmCents: number;
  freeDeliveryThresholdCents: number | null;
  estimatedPrepMinutes: number;
  estimatedDeliveryMinutes: number;
  acceptsCard: boolean;
  acceptsCash: boolean;
  acceptsTransfer: boolean;
  bankAccountClabe: string | null;
  bankAccountName: string | null;
  bankName: string | null;
  driverCommissionType: string | null;
  driverCommissionValue: number | null;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateRestaurantProfileParams {
  name?: string;
  description?: string | null;
  email?: string;
  phone?: string | null;
  whatsapp?: string | null;
  website?: string | null;
}

export interface UpdateRestaurantBrandingParams {
  logoUrl?: string | null;
  bannerUrl?: string | null;
  primaryColor?: string | null;
  secondaryColor?: string | null;
}

export interface UpdateRestaurantLocationParams {
  address?: string | null;
  city?: string | null;
  state?: string | null;
  country?: string | null;
  postalCode?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  timezone?: string;
}

export interface UpdateRestaurantRegionalSettingsParams {
  currencyCode?: string;
  currencySymbol?: string;
  currencyPosition?: "before" | "after";
  decimalSeparator?: string;
  thousandsSeparator?: string;
  decimalPlaces?: number;
  taxRatePercentage?: number;
  taxIncludedInPrices?: boolean;
}

export interface UpdateRestaurantSettingsParams {
  isOpen?: boolean;
  acceptsDelivery?: boolean;
  acceptsPickup?: boolean;
  acceptsDineIn?: boolean;
  deliveryRadiusKm?: number | null;
  minimumOrderCents?: number;
  deliveryFeeCents?: number;
  deliveryFeePerKmCents?: number;
  freeDeliveryThresholdCents?: number | null;
  estimatedPrepMinutes?: number;
  estimatedDeliveryMinutes?: number;
  acceptsCard?: boolean;
  acceptsCash?: boolean;
  acceptsTransfer?: boolean;
  bankAccountClabe?: string | null;
  bankAccountName?: string | null;
  bankName?: string | null;
  businessHours?: Record<
    string,
    { enabled: boolean; open: string | null; close: string | null }
  >;
  driverCommissionType?: string | null;
  driverCommissionValue?: number | null;
}

export interface RegisterRestaurantParams {
  restaurantName: string;
  managerName: string;
  email: string;
  phone: string;
  password: string;
}
