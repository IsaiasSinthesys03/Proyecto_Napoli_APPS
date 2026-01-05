import { Bike, MapPin, Phone, User } from "lucide-react";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { DeliveryPerson } from "@/core/models";

interface DeliveryPersonInfoProps {
  person: DeliveryPerson;
  phone?: string | null;
  deliveryCount?: number;
  onOrderClick?: (orderId: string) => void;
}

export function DeliveryPersonInfo({
  person,
  phone,
  deliveryCount = 1,
  onOrderClick,
}: DeliveryPersonInfoProps) {
  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">Información del Repartidor</CardTitle>
          <div className="rounded-full bg-green-500 px-3 py-1 text-xs font-semibold text-white">
            En Reparto
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Nombre */}
        <div className="flex items-start gap-3">
          <User className="mt-0.5 h-4 w-4 text-muted-foreground" />
          <div className="flex-1 space-y-1">
            <p className="text-sm font-medium text-muted-foreground">Nombre</p>
            <p className="text-base font-semibold">{person.name}</p>
          </div>
        </div>

        <Separator />

        {/* Vehículo */}
        <div className="flex items-start gap-3">
          <Bike className="mt-0.5 h-4 w-4 text-muted-foreground" />
          <div className="flex-1 space-y-1">
            <p className="text-sm font-medium text-muted-foreground">Vehículo</p>
            <p className="text-base capitalize">{person.vehicle}</p>
          </div>
        </div>

        {/* Teléfono */}
        {phone && (
          <>
            <Separator />
            <div className="flex items-start gap-3">
              <Phone className="mt-0.5 h-4 w-4 text-muted-foreground" />
              <div className="flex-1 space-y-1">
                <p className="text-sm font-medium text-muted-foreground">
                  Teléfono
                </p>
                <a
                  href={`tel:${phone}`}
                  className="text-base font-medium text-primary hover:underline"
                >
                  {phone}
                </a>
              </div>
            </div>
          </>
        )}

        <Separator />

        {/* Lista de Entregas Activas */}
        <div className="space-y-2">
          <p className="text-sm font-medium text-muted-foreground">
            {deliveryCount === 1 ? "Entrega Activa" : "Entregas Activas"}
          </p>
          <div className="space-y-3">
            {person.deliveries?.map((delivery) => (
              <div
                key={delivery.orderId}
                onClick={() => onOrderClick?.(delivery.orderId)}
                className="rounded-lg border bg-muted/50 p-3 space-y-2 cursor-pointer hover:bg-muted transition-colors"
              >
                <div className="flex items-center justify-between">
                  <span className="font-semibold text-sm">
                    Pedido {delivery.orderNumber}
                  </span>
                  <span className="text-xs text-muted-foreground">
                    {delivery.customerName}
                  </span>
                </div>
                <div className="flex items-start gap-2">
                  <MapPin className="mt-0.5 h-3 w-3 text-muted-foreground flex-shrink-0" />
                  <p className="text-sm text-muted-foreground leading-relaxed flex-1">
                    {delivery.fullAddress}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Teléfono */}
        {phone && (
          <>
            <Separator />
            <div className="flex items-start gap-3">
              <Phone className="mt-0.5 h-4 w-4 text-muted-foreground" />
              <div className="flex-1 space-y-1">
                <p className="text-sm font-medium text-muted-foreground">
                  Teléfono
                </p>
                <a
                  href={`tel:${phone}`}
                  className="text-base font-medium text-primary hover:underline"
                >
                  {phone}
                </a>
              </div>
            </div>
          </>
        )}
      </CardContent>
    </Card>
  );
}
