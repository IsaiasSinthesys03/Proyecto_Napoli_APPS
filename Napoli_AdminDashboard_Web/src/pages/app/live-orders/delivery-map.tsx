import { Bike, Loader2, MapPin } from "lucide-react";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useActiveDeliveries } from "@/core/hooks/useDelivery";
import { DeliveryPerson } from "@/core/models";

interface DeliveryMapProps {
  onSelectDeliveryPerson: (person: DeliveryPerson) => void;
}

export function DeliveryMap({ onSelectDeliveryPerson }: DeliveryMapProps) {
  const { data: activeDeliveries, isLoading } = useActiveDeliveries();

  if (isLoading) {
    return (
      <Card className="col-span-3">
        <CardHeader>
          <CardTitle>Mapa de Repartidores Activos</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex h-[400px] items-center justify-center">
            <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
          </div>
        </CardContent>
      </Card>
    );
  }

  const deliveries = activeDeliveries || [];

  // Agrupar entregas por repartidor (driver_id)
  const driverMap = new Map<string, typeof deliveries>();
  deliveries.forEach((delivery) => {
    const existing = driverMap.get(delivery.driverId) || [];
    driverMap.set(delivery.driverId, [...existing, delivery]);
  });

  // Convertir a array de repartidores únicos con sus entregas
  const uniqueDrivers = Array.from(driverMap.entries()).map(([driverId, driverDeliveries]) => ({
    driverId,
    driverName: driverDeliveries[0].driverName,
    driverVehicleType: driverDeliveries[0].driverVehicleType,
    driverPhone: driverDeliveries[0].driverPhone,
    deliveries: driverDeliveries,
    deliveryCount: driverDeliveries.length,
  }));

  return (
    <Card className="col-span-3">
      <CardHeader>
        <CardTitle>Mapa de Repartidores Activos</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="relative h-[400px] w-full rounded-md bg-muted">
          <img
            src="/maps.png"
            alt="Mapa de la ciudad"
            className="h-full w-full object-cover"
          />

          {uniqueDrivers.length === 0 ? (
            <div className="absolute inset-0 flex items-center justify-center bg-black/30">
              <p className="text-lg font-medium text-white">
                No hay repartidores activos en este momento
              </p>
            </div>
          ) : (
            uniqueDrivers.map((driver, index) => {
              // Distribute icons across the map based on index
              const positions = [
                { top: "15%", left: "25%" },
                { top: "45%", left: "60%" },
                { top: "70%", left: "35%" },
                { top: "30%", left: "75%" },
                { top: "60%", left: "20%" },
              ];
              const pos = positions[index % positions.length];

              return (
                <div
                  key={driver.driverId}
                  className="absolute cursor-pointer transition-transform hover:scale-125"
                  style={{ top: pos.top, left: pos.left }}
                  onClick={() =>
                    onSelectDeliveryPerson({
                      id: driver.driverId,
                      name: driver.driverName,
                      vehicle: driver.driverVehicleType,
                      orderId: driver.deliveries[0].orderId,
                      address: driver.deliveries[0].addressLabel,
                      phone: driver.driverPhone,
                      deliveryCount: driver.deliveryCount,
                      deliveries: driver.deliveries,
                    })
                  }
                  title={`${driver.driverName} - ${driver.deliveryCount} entrega${driver.deliveryCount > 1 ? 's' : ''}`}
                >
                  <div className="relative">
                    <Bike className="h-6 w-6 text-primary" />
                    <MapPin className="absolute -bottom-1 -right-1 h-3 w-3 text-destructive" />
                    {driver.deliveryCount > 1 && (
                      <div className="absolute -top-2 -right-2 flex h-5 w-5 items-center justify-center rounded-full bg-primary text-xs font-bold text-primary-foreground">
                        {driver.deliveryCount}
                      </div>
                    )}
                  </div>
                </div>
              );
            })
          )}
        </div>

        {uniqueDrivers.length > 0 && (
          <div className="mt-4 text-sm text-muted-foreground">
            {uniqueDrivers.length} repartidor{uniqueDrivers.length > 1 ? "es" : ""} activo{uniqueDrivers.length > 1 ? "s" : ""} · {deliveries.length} entrega{deliveries.length > 1 ? "s" : ""} en curso
          </div>
        )}
      </CardContent>
    </Card>
  );
}
