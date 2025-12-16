import { useState } from "react";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  useAssignDeliveryManMutation,
  useGetDeliveryMenQuery,
} from "@/core/hooks/useDelivery";

export interface OrderAssignDialogProps {
  orderId: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function OrderAssignDialog({
  orderId,
  open,
  onOpenChange,
}: OrderAssignDialogProps) {
  const [deliveryManId, setDeliveryManId] = useState<string | null>(null);

  const { data: deliveryMen } = useGetDeliveryMenQuery();
  const { mutateAsync: assignDeliveryManFn, isPending } =
    useAssignDeliveryManMutation();

  async function handleAssignDeliveryMan() {
    if (!deliveryManId) {
      return;
    }

    await assignDeliveryManFn({ orderId, deliveryManId });

    onOpenChange(false);
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Asignar repartidor</DialogTitle>
          <DialogDescription>
            Seleccione el repartidor para el pedido <strong>{orderId}</strong>
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          <Select onValueChange={setDeliveryManId}>
            <SelectTrigger className="w-full">
              <SelectValue placeholder="Seleccione un repartidor" />
            </SelectTrigger>
            <SelectContent>
              {deliveryMen?.deliveryMen.map((deliveryMan) => {
                return (
                  <SelectItem key={deliveryMan.id} value={deliveryMan.id}>
                    {deliveryMan.name}
                  </SelectItem>
                );
              })}
            </SelectContent>
          </Select>

          <Button
            onClick={handleAssignDeliveryMan}
            disabled={!deliveryManId || isPending}
            className="w-full"
          >
            Asignar
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
