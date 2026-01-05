import { ArrowRight, Loader2, X } from "lucide-react";
import { useState } from "react";

import { OrderStatus } from "@/components/order-status";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  useApproveOrderMutation,
  useCancelOrderMutation,
  useDeliverOrderMutation,
  useDispatchOrderMutation,
  useReadyOrderMutation,
} from "@/core/hooks/useOrders";
import {
  useAssignDeliveryManMutation,
  useGetDeliveryMenQuery,
} from "@/core/hooks/useDelivery";

interface OrderActionsPanelProps {
  orderId: string;
  status: OrderStatus;
}

export function OrderActionsPanel({ orderId, status }: OrderActionsPanelProps) {
  const [selectedDeliveryManId, setSelectedDeliveryManId] = useState<
    string | null
  >(null);

  const { mutateAsync: cancelOrderFn, isPending: isCancellingOrder } =
    useCancelOrderMutation();

  const { mutateAsync: approveOrderFn, isPending: isApprovingOrder } =
    useApproveOrderMutation();

  const { mutateAsync: dispatchOrderFn, isPending: isDispatchingOrder } =
    useDispatchOrderMutation();

  const { mutateAsync: readyOrderFn, isPending: isReadyingOrder } =
    useReadyOrderMutation();

  const { mutateAsync: deliverOrderFn, isPending: isDeliveringOrder } =
    useDeliverOrderMutation();

  const { mutateAsync: assignDeliveryManFn, isPending: isAssigningDriver } =
    useAssignDeliveryManMutation();

  const { data: deliveryMen } = useGetDeliveryMenQuery();

  const handleReadyOrder = async () => {
    // Si hay repartidor seleccionado, asignar y enviar a reparto
    if (selectedDeliveryManId) {
      await assignDeliveryManFn({
        orderId,
        deliveryManId: selectedDeliveryManId,
      });
      await dispatchOrderFn(orderId);
    } else {
      // Si NO hay repartidor, solo marcar como listo (ready)
      await readyOrderFn(orderId);
    }
  };

  const handleAssignAndDispatch = async () => {
    if (selectedDeliveryManId) {
      await assignDeliveryManFn({
        orderId,
        deliveryManId: selectedDeliveryManId,
      });
      await dispatchOrderFn(orderId);
    }
  };

  const isProcessing = isDispatchingOrder || isReadyingOrder || isAssigningDriver;

  return (
    <div className="flex flex-col gap-2">
      {status === "pending" && (
        <>
          <Button
            onClick={() => approveOrderFn(orderId)}
            disabled={isApprovingOrder}
            variant="outline"
            size="sm"
          >
            {isApprovingOrder ? (
              <Loader2 className="mr-2 h-3 w-3 animate-spin" />
            ) : (
              <ArrowRight className="mr-2 h-3 w-3" />
            )}
            Aceptar Pedido
          </Button>
          <Button
            disabled={isCancellingOrder}
            onClick={() => cancelOrderFn(orderId)}
            variant="ghost"
            size="sm"
          >
            <X className="mr-2 h-3 w-3" />
            Rechazar Pedido
          </Button>
        </>
      )}

      {(status === "accepted" || status === "ready") && (
        <div className="space-y-3">
          <div className="space-y-2">
            <label className="text-sm font-medium">
              {status === "ready" ? "Asignar Repartidor (Requerido)" : "Repartidor (Opcional)"}
            </label>
            <Select
              onValueChange={setSelectedDeliveryManId}
              value={selectedDeliveryManId ?? ""}
            >
              <SelectTrigger>
                <SelectValue placeholder="Seleccionar repartidor..." />
              </SelectTrigger>
              <SelectContent>
                {deliveryMen?.deliveryMen.map((deliveryMan) => (
                  <SelectItem key={deliveryMan.id} value={deliveryMan.id}>
                    {deliveryMan.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {status === "accepted" ? (
            <Button
              onClick={handleReadyOrder}
              disabled={isProcessing}
              variant="outline"
              size="sm"
              className="w-full"
            >
              {isProcessing ? (
                <Loader2 className="mr-2 h-3 w-3 animate-spin" />
              ) : (
                <ArrowRight className="mr-2 h-3 w-3" />
              )}
              Listo
            </Button>
          ) : (
            <Button
              onClick={handleAssignAndDispatch}
              disabled={isProcessing || !selectedDeliveryManId}
              variant="outline"
              size="sm"
              className="w-full"
            >
              {isProcessing ? (
                <Loader2 className="mr-2 h-3 w-3 animate-spin" />
              ) : (
                <ArrowRight className="mr-2 h-3 w-3" />
              )}
              En Reparto
            </Button>
          )}
        </div>
      )}

      {status === "processing" && (
        <Button
          onClick={() => deliverOrderFn(orderId)}
          disabled={isDeliveringOrder}
          variant="outline"
          size="sm"
        >
          {isDeliveringOrder ? (
            <Loader2 className="mr-2 h-3 w-3 animate-spin" />
          ) : (
            <ArrowRight className="mr-2 h-3 w-3" />
          )}
          En Reparto
        </Button>
      )}
    </div>
  );
}
