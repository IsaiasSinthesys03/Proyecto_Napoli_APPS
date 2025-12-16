import { formatDistanceToNow } from "date-fns";
import { es } from "date-fns/locale";
import { ArrowRight, Loader2, Search, X } from "lucide-react";
import { useState } from "react";

import { OrderStatus } from "@/components/order-status";
import { Button } from "@/components/ui/button";
import { Dialog, DialogTrigger } from "@/components/ui/dialog";
import { TableCell, TableRow } from "@/components/ui/table";
import {
  useApproveOrderMutation,
  useCancelOrderMutation,
  useDeliverOrderMutation,
  useDispatchOrderMutation,
} from "@/core/hooks/useOrders";
import { Order } from "@/core/models";

import { OrderDetails } from "./order-details";

interface OrderTableRowProps {
  order: Order;
}

export function OrderTableRow({ order }: OrderTableRowProps) {
  const [isDetailsOpen, setIsDetailsOpen] = useState(false);

  const { mutateAsync: cancelOrderFn, isPending: isCancellingOrder } =
    useCancelOrderMutation();

  const { mutateAsync: approveOrderFn, isPending: isApprovingOrder } =
    useApproveOrderMutation();

  const { mutateAsync: dispatchOrderFn, isPending: isDispatchingOrder } =
    useDispatchOrderMutation();

  const { mutateAsync: deliverOrderFn, isPending: isDeliveringOrder } =
    useDeliverOrderMutation();

  return (
    <TableRow>
      <TableCell>
        <Dialog open={isDetailsOpen} onOpenChange={setIsDetailsOpen}>
          <DialogTrigger asChild>
            <Button variant="outline" size="sm">
              <Search className="h-3 w-3" />
              <span className="sr-only">Detalles del pedido</span>
            </Button>
          </DialogTrigger>
          <OrderDetails orderId={order.id} />
        </Dialog>
      </TableCell>
      <TableCell className="font-mono text-xs font-medium">
        {order.orderNumber || order.id.slice(0, 8)}
      </TableCell>
      <TableCell className="text-muted-foreground">
        {formatDistanceToNow(order.createdAt, {
          locale: es,
          addSuffix: true,
        })}
      </TableCell>
      <TableCell>
        <OrderStatus status={order.status} />
      </TableCell>
      <TableCell className="font-medium">
        {order.customer?.name || "Cliente"}
      </TableCell>
      <TableCell className="font-medium">
        {(order.totalCents / 100).toLocaleString("es-MX", {
          style: "currency",
          currency: "MXN",
        })}
      </TableCell>
      <TableCell>
        {order.status === "pending" && (
          <Button
            onClick={() => approveOrderFn(order.id)}
            disabled={isApprovingOrder}
            variant="outline"
            size="sm"
          >
            {isApprovingOrder ? (
              <Loader2 className="mr-2 h-3 w-3 animate-spin" />
            ) : (
              <ArrowRight className="mr-2 h-3 w-3" />
            )}
            Aceptar
          </Button>
        )}

        {order.status === "accepted" && (
          <Button
            onClick={() => dispatchOrderFn(order.id)}
            disabled={isDispatchingOrder}
            variant="outline"
            size="sm"
          >
            <ArrowRight className="mr-2 h-3 w-3" />
            En preparación
          </Button>
        )}

        {order.status === "processing" && (
          <Button
            onClick={() => dispatchOrderFn(order.id)}
            disabled={isDispatchingOrder}
            variant="outline"
            size="sm"
          >
            <ArrowRight className="mr-2 h-3 w-3" />
            En reparto
          </Button>
        )}

        {order.status === "delivering" && (
          <Button
            onClick={() => deliverOrderFn(order.id)}
            disabled={isDeliveringOrder}
            variant="outline"
            size="sm"
          >
            <ArrowRight className="mr-2 h-3 w-3" />
            Entregado
          </Button>
        )}
      </TableCell>
      <TableCell>
        <Button
          disabled={
            !["pending", "processing", "accepted"].includes(order.status) ||
            isCancellingOrder
          }
          onClick={() => cancelOrderFn(order.id)}
          variant="ghost"
          size="sm"
        >
          <X className="mr-2 h-3 w-3" />
          Cancelar
        </Button>
      </TableCell>
    </TableRow>
  );
}
