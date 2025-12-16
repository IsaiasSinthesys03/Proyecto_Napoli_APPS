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

          {deliveries.length === 0 ? (
            <div className="absolute inset-0 flex items-center justify-center bg-black/30">
              <p className="text-lg font-medium text-white">
                No hay repartidores activos en este momento
              </p>
            </div>
          ) : (
            deliveries.map((delivery, index) => {
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
                  key={delivery.orderId}
                  className="absolute cursor-pointer transition-transform hover:scale-125"
                  style={{ top: pos.top, left: pos.left }}
                  onClick={() =>
                    onSelectDeliveryPerson({
                      id: delivery.driverId,
                      name: delivery.driverName,
                      vehicle: delivery.driverVehicleType,
                      orderId: delivery.orderId,
                      address: delivery.deliveryAddress,
                    })
                  }
                  title={`${delivery.driverName} - ${delivery.customerName}`}
                >
                  <div className="relative">
                    <Bike className="h-6 w-6 text-primary" />
                    <MapPin className="absolute -bottom-1 -right-1 h-3 w-3 text-destructive" />
                  </div>
                </div>
              );
            })
          )}
        </div>

        {deliveries.length > 0 && (
          <div className="mt-4 text-sm text-muted-foreground">
            {deliveries.length} entrega{deliveries.length > 1 ? "s" : ""} en
            curso
          </div>
        )}
      </CardContent>
    </Card>
  );
}
