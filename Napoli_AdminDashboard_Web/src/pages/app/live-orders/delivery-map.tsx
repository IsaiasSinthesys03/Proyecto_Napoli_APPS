import { Loader2 } from "lucide-react";
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useActiveDeliveries, useActiveDriverLocations } from "@/core/hooks/useDelivery";
import { DeliveryPerson } from "@/core/models";
import type { ActiveDelivery, DriverLocation } from "@/core/services/delivery.service";

interface DeliveryMapProps {
  onSelectDeliveryPerson: (person: DeliveryPerson) => void;
}

export function DeliveryMap({ onSelectDeliveryPerson }: DeliveryMapProps) {
  const { data: activeDeliveries, isLoading } = useActiveDeliveries();
  const { data: activeDriverLocations } = useActiveDriverLocations();

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

  const deliveries: ActiveDelivery[] = (activeDeliveries || []) as ActiveDelivery[];
  const driverLocations: DriverLocation[] = (activeDriverLocations || []) as DriverLocation[];

  // Choose center: first available coordinate from deliveries or drivers (with type guards)
  const firstDeliveryWithCoords = deliveries.find(
    (d) => {
      const lat = Number(d.currentLatitude);
      const lng = Number(d.currentLongitude);
      return Number.isFinite(lat) && Number.isFinite(lng);
    }
  );
  const firstDriverWithCoords = driverLocations.find(
    (d) => {
      const lat = Number(d.lat);
      const lng = Number(d.lng);
      return Number.isFinite(lat) && Number.isFinite(lng);
    }
  );

  // Default center (Mexico City coordinates)
  const defaultCenter: [number, number] = [19.432608, -99.133209];

  let center: [number, number] = defaultCenter;

  if (firstDeliveryWithCoords) {
    const lat = Number(firstDeliveryWithCoords.currentLatitude);
    const lng = Number(firstDeliveryWithCoords.currentLongitude);
    if (Number.isFinite(lat) && Number.isFinite(lng)) {
      center = [lat, lng];
    }
  } else if (firstDriverWithCoords) {
    const lat = Number(firstDriverWithCoords.lat);
    const lng = Number(firstDriverWithCoords.lng);
    if (Number.isFinite(lat) && Number.isFinite(lng)) {
      center = [lat, lng];
    }
  }

  return (
    <Card className="col-span-3">
      <CardHeader>
        <CardTitle>Mapa de Repartidores Activos</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-[400px] w-full rounded-md bg-muted">
          {deliveries.length === 0 && driverLocations.length === 0 ? (
            <div className="flex h-full items-center justify-center">
              <p className="text-lg font-medium text-muted-foreground">No hay repartidores activos en este momento</p>
            </div>
          ) : (
            <MapContainer center={center} zoom={13} style={{ height: '100%', width: '100%' }}>
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />

              {(() => {
                const icon = L.icon({
                  iconUrl: new URL('leaflet/dist/images/marker-icon.png', import.meta.url).href,
                  iconRetinaUrl: new URL('leaflet/dist/images/marker-icon-2x.png', import.meta.url).href,
                  shadowUrl: new URL('leaflet/dist/images/marker-shadow.png', import.meta.url).href,
                  iconAnchor: [12, 41],
                });

                // Custom driver icon from public/icons
                const driverIcon = L.icon({
                  iconUrl: '/icons/driver-pin.svg',
                  iconSize: [36, 36],
                  iconAnchor: [18, 36],
                  popupAnchor: [0, -36],
                });

                const deliveryMarkers = deliveries.map((delivery: ActiveDelivery) => {
                  const lat = Number(delivery.currentLatitude);
                  const lng = Number(delivery.currentLongitude);
                  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;

                  return (
                    <Marker
                      key={`delivery-${delivery.orderId}`}
                      position={[lat, lng]}
                      icon={icon}
                      eventHandlers={{
                        click: () =>
                          onSelectDeliveryPerson({
                            id: delivery.driverId,
                            name: delivery.driverName,
                            vehicle: delivery.driverVehicleType,
                            orderId: delivery.orderId,
                            address: delivery.deliveryAddress,
                          }),
                      }}
                    >
                      <Popup>
                        <div className="text-sm">
                          <div className="font-medium">{delivery.driverName}</div>
                          <div>{delivery.deliveryAddress}</div>
                          <div className="text-xs text-muted-foreground">{delivery.customerName}</div>
                        </div>
                      </Popup>
                    </Marker>
                  );
                });

                const driverMarkers = driverLocations.map((drv: DriverLocation) => {
                  const lat = Number(drv.lat);
                  const lng = Number(drv.lng);
                  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;

                  return (
                    <Marker key={`driver-${drv.id}`} position={[lat, lng]} icon={driverIcon}>
                      <Popup>
                        <div className="text-sm">
                          <div className="font-medium">{drv.name}</div>
                          <div>Vehículo: {drv.vehicle ?? 'N/A'}</div>
                          <div>Estado: {drv.busy ? 'En entrega' : 'Disponible'}</div>
                          <div className="text-xs text-muted-foreground">Última: {drv.last_upd ?? ''}</div>
                        </div>
                      </Popup>
                    </Marker>
                  );
                });

                return [...deliveryMarkers, ...driverMarkers];
              })()}
            </MapContainer>
          )}
        </div>
        {deliveries.length > 0 && (
          <div className="mt-4 text-sm text-muted-foreground">
            {deliveries.length} entrega{deliveries.length > 1 ? 's' : ''} en curso
          </div>
        )}
      </CardContent>
    </Card>
  );
}
