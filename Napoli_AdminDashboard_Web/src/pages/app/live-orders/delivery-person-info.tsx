import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DeliveryPerson } from "@/core/models";

interface DeliveryPersonInfoProps {
  person: DeliveryPerson;
}

export function DeliveryPersonInfo({ person }: DeliveryPersonInfoProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Información del Repartidor</CardTitle>
      </CardHeader>
      <CardContent className="space-y-2">
        <p>
          <span className="font-semibold">Nombre:</span> {person.name}
        </p>
        <p>
          <span className="font-semibold">Vehículo:</span> {person.vehicle}
        </p>
        <p>
          <span className="font-semibold">Pedido:</span> {person.orderId}
        </p>
        <p>
          <span className="font-semibold">Dirección:</span> {person.address}
        </p>
      </CardContent>
    </Card>
  );
}
