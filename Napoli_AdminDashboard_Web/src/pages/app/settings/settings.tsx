import { Helmet } from "react-helmet-async";

import { BillingSettings } from "./billing-settings";
import { OperatingHoursSettings } from "./operating-hours-settings";
import { ShippingSettings } from "./shipping-settings";

export function Settings() {
  return (
    <>
      <Helmet title="Configuración" />
      <div className="flex flex-col gap-4">
        <h1 className="text-3xl font-bold tracking-tight">Configuración</h1>

        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          <ShippingSettings />
          <BillingSettings />
          <OperatingHoursSettings />
        </div>
      </div>
    </>
  );
}
