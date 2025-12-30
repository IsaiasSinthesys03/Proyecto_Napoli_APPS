import { Helmet } from "react-helmet-async";

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

import { BillingSettings } from "./billing-settings";
import { OperatingHoursSettings } from "./operating-hours-settings";
import { RegionalSettings } from "./regional-settings";
import { RestaurantBrandingSettings } from "./restaurant-branding-settings";
import { RestaurantLocationSettings } from "./restaurant-location-settings";
import { RestaurantProfileSettings } from "./restaurant-profile-settings";
import { ShippingSettings } from "./shipping-settings";

export function Settings() {
  return (
    <>
      <Helmet title="Configuración" />
      <div className="flex flex-col gap-4">
        <h1 className="text-3xl font-bold tracking-tight">Configuración</h1>

        <Tabs defaultValue="profile" className="w-full">
          <TabsList className="grid w-full grid-cols-7">
            <TabsTrigger value="profile">Perfil</TabsTrigger>
            <TabsTrigger value="branding">Marca</TabsTrigger>
            <TabsTrigger value="location">Ubicación</TabsTrigger>
            <TabsTrigger value="regional">Regional</TabsTrigger>
            <TabsTrigger value="shipping">Logística</TabsTrigger>
            <TabsTrigger value="billing">Pagos</TabsTrigger>
            <TabsTrigger value="hours">Horarios</TabsTrigger>
          </TabsList>

          <TabsContent value="profile" className="mt-4">
            <RestaurantProfileSettings />
          </TabsContent>

          <TabsContent value="branding" className="mt-4">
            <RestaurantBrandingSettings />
          </TabsContent>

          <TabsContent value="location" className="mt-4">
            <RestaurantLocationSettings />
          </TabsContent>

          <TabsContent value="regional" className="mt-4">
            <RegionalSettings />
          </TabsContent>

          <TabsContent value="shipping" className="mt-4">
            <ShippingSettings />
          </TabsContent>

          <TabsContent value="billing" className="mt-4">
            <BillingSettings />
          </TabsContent>

          <TabsContent value="hours" className="mt-4">
            <OperatingHoursSettings />
          </TabsContent>
        </Tabs>
      </div>
    </>
  );
}
