import { X } from "lucide-react";
import { useEffect, useState } from "react";
import { Helmet } from "react-helmet-async";

import { Button } from "@/components/ui/button";
import { useGetOrdersQuery } from "@/core/hooks/useOrders";
import { DeliveryPerson, OrderStatusType } from "@/core/models";
import { DeliveryPersonInfo } from "@/pages/app/live-orders/delivery-person-info";
import { OrderDetails } from "@/pages/app/orders/order-details";

import { DeliveryMap } from "../live-orders/delivery-map";
import { IncomingOrdersList } from "../live-orders/incoming-orders-list";
import { OrderActionsPanel } from "../live-orders/order-actions-panel";

export function Dashboard() {
  const [selectedOrderId, setSelectedOrderId] = useState<string | null>(null);
  const [selectedDeliveryPerson, setSelectedDeliveryPerson] =
    useState<DeliveryPerson | null>(null);
  const [previousDeliveryPerson, setPreviousDeliveryPerson] =
    useState<DeliveryPerson | null>(null);

  const { data: orders } = useGetOrdersQuery({
    page: 1,
    status: ["pending", "accepted", "processing", "ready", "delivering"] as OrderStatusType[],
  });

  useEffect(() => {
    if (
      orders &&
      orders?.results?.length > 0 &&
      !selectedOrderId &&
      !selectedDeliveryPerson
    ) {
      setSelectedOrderId(orders.results[0].id);
    }
  }, [orders, selectedOrderId, selectedDeliveryPerson]);

  function handleSelectOrder(orderId: string) {
    setSelectedOrderId(orderId);
    setSelectedDeliveryPerson(null); // Close delivery person info
    setPreviousDeliveryPerson(null); // Clear previous
  }

  function handleSelectDeliveryPerson(person: DeliveryPerson) {
    setSelectedDeliveryPerson(person);
    setSelectedOrderId(null); // Close order details
    setPreviousDeliveryPerson(null); // Clear previous
  }

  function handleCloseOrderDetails() {
    setSelectedOrderId(null);
    // Restore previous delivery person if it exists
    if (previousDeliveryPerson) {
      setSelectedDeliveryPerson(previousDeliveryPerson);
      setPreviousDeliveryPerson(null);
    }
  }

  return (
    <>
      <Helmet title="Panel de control" />
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold tracking-tight">
            Panel de control
          </h1>
        </div>

        <div className="grid grid-cols-12 gap-4">
          <div className="col-span-3">
            <IncomingOrdersList
              orders={orders}
              onSelectOrder={handleSelectOrder}
            />
          </div>
          <div className="col-span-6">
            <DeliveryMap onSelectDeliveryPerson={handleSelectDeliveryPerson} />
          </div>
          <div className="col-span-3 flex flex-col gap-4">
            {selectedOrderId && (
              <div className="relative rounded-lg border bg-card p-4">
                <Button
                  variant="ghost"
                  size="icon"
                  className="absolute right-2 top-2 h-8 w-8 text-muted-foreground hover:text-foreground"
                  onClick={handleCloseOrderDetails}
                  title="Cerrar detalles del pedido"
                >
                  <X className="h-4 w-4" />
                </Button>
                <div className="space-y-4 pt-8">
                  <OrderActionsPanel
                    orderId={selectedOrderId}
                    status={
                      orders?.results.find((o) => o.id === selectedOrderId)
                        ?.status ?? "pending"
                    }
                  />
                  <OrderDetails orderId={selectedOrderId} />
                </div>
              </div>
            )}
            {selectedDeliveryPerson && (
              <DeliveryPersonInfo
                person={selectedDeliveryPerson}
                phone={selectedDeliveryPerson.phone}
                deliveryCount={selectedDeliveryPerson.deliveryCount}
                onOrderClick={(orderId) => {
                  setPreviousDeliveryPerson(selectedDeliveryPerson);
                  setSelectedOrderId(orderId);
                  setSelectedDeliveryPerson(null);
                }}
              />
            )}
          </div>
        </div>
      </div>
    </>
  );
}
