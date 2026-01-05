import { formatDistanceToNow } from "date-fns";
import { es } from "date-fns/locale";

import { OrderStatus } from "@/components/order-status";
import { Timer } from "@/components/timer";
import {
  Table,
  TableBody,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useGetOrderDetailsQuery } from "@/core/hooks/useOrders";

import { OrderDetailsSkeleton } from "./order-details-skeleton";

export interface OrderDetailsProps {
  orderId: string;
}

export function OrderDetails({ orderId }: OrderDetailsProps) {
  const { data: order } = useGetOrderDetailsQuery(orderId);

  return (
    <div className="space-y-6">
      {order ? (
        <>
          <h2 className="text-lg font-semibold">
            Pedido: {order.orderNumber || order.id.slice(0, 8)}
          </h2>
          <div className="space-y-6">
            <Table>
              <TableBody>
                <TableRow>
                  <TableCell className="text-muted-foreground">
                    Estado
                  </TableCell>
                  <TableCell className="flex justify-end">
                    <OrderStatus status={order.status} />
                  </TableCell>
                </TableRow>
                {order.status === "processing" && order.processingAt && (
                  <TableRow>
                    <TableCell className="text-muted-foreground">
                      En preparación hace
                    </TableCell>
                    <TableCell className="flex justify-end">
                      <Timer startTime={order.processingAt} />
                    </TableCell>
                  </TableRow>
                )}
                {order.status === "delivering" && order.pickedUpAt && (
                  <TableRow>
                    <TableCell className="text-muted-foreground">
                      En reparto hace
                    </TableCell>
                    <TableCell className="flex justify-end">
                      <Timer startTime={order.pickedUpAt} />
                    </TableCell>
                  </TableRow>
                )}
                <TableRow>
                  <TableCell className="text-muted-foreground">
                    Cliente
                  </TableCell>
                  <TableCell className="flex justify-end">
                    {order.customer?.name ||
                      order.customerSnapshot?.name ||
                      "Cliente"}
                  </TableCell>
                </TableRow>
                <TableRow>
                  <TableCell className="text-muted-foreground">
                    Teléfono
                  </TableCell>
                  <TableCell className="flex justify-end">
                    {order.customer?.phone ||
                      order.customerSnapshot?.phone ||
                      "No informado"}
                  </TableCell>
                </TableRow>
                <TableRow>
                  <TableCell className="text-muted-foreground">
                    Correo electrónico
                  </TableCell>
                  <TableCell className="flex justify-end">
                    {order.customer?.email ||
                      order.customerSnapshot?.email ||
                      "No informado"}
                  </TableCell>
                </TableRow>
                {order.addressSnapshot && (
                  <TableRow>
                    <TableCell className="text-muted-foreground">
                      Dirección
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="text-sm">
                        {order.addressSnapshot.street}
                      </div>
                      <div className="text-xs text-muted-foreground">
                        {order.addressSnapshot.city}
                      </div>
                    </TableCell>
                  </TableRow>
                )}
                {order.customerNotes && (
                  <TableRow>
                    <TableCell className="text-muted-foreground">
                      Comentarios
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="text-sm">{order.customerNotes}</div>
                    </TableCell>
                  </TableRow>
                )}
                <TableRow>
                  <TableCell className="text-muted-foreground">
                    Realizado hace
                  </TableCell>
                  <TableCell className="flex justify-end">
                    {formatDistanceToNow(order.createdAt, {
                      locale: es,
                      addSuffix: true,
                    })}
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>

            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Producto</TableHead>
                  <TableHead className="text-right">Cant.</TableHead>
                  <TableHead className="text-right">Precio</TableHead>
                  <TableHead className="text-right">Subtotal</TableHead>
                </TableRow>
              </TableHeader>

              <TableBody>
                {(order.orderItems || []).map((item) => {
                  const itemTotal =
                    item.totalPriceCents || item.unitPriceCents * item.quantity;

                  return (
                    <TableRow key={item.id}>
                      <TableCell>
                        <div className="font-medium">{item.productName}</div>
                        {item.variantName && (
                          <div className="text-xs text-muted-foreground">
                            {item.variantName}
                          </div>
                        )}
                        {item.notes && (
                          <div className="mt-2 text-xs text-gray-500">
                            <span className="font-semibold">Nota:</span>{" "}
                            {item.notes}
                          </div>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        {item.quantity}
                      </TableCell>
                      <TableCell className="text-right">
                        {(item.unitPriceCents / 100).toLocaleString("es-MX", {
                          style: "currency",
                          currency: "MXN",
                        })}
                      </TableCell>
                      <TableCell className="text-right">
                        {(itemTotal / 100).toLocaleString("es-MX", {
                          style: "currency",
                          currency: "MXN",
                        })}
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell colSpan={3}>Total del pedido</TableCell>
                  <TableCell className="text-right font-medium">
                    {(order.totalCents / 100).toLocaleString("es-MX", {
                      style: "currency",
                      currency: "MXN",
                    })}
                  </TableCell>
                </TableRow>
                {order.driver && (
                  <TableRow>
                    <TableCell colSpan={3}>Repartidor asignado</TableCell>
                    <TableCell className="text-right font-medium">
                      {order.driver.name}
                    </TableCell>
                  </TableRow>
                )}
              </TableFooter>
            </Table>
          </div>
        </>
      ) : (
        <OrderDetailsSkeleton />
      )}
    </div>
  );
}
