import { OrderStatus } from "@/components/order-status";
import { Timer } from "@/components/timer";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { PaginatedOrders } from "@/core/models";

interface IncomingOrdersListProps {
  orders: PaginatedOrders | undefined;
  onSelectOrder: (orderId: string) => void;
}

export function IncomingOrdersList({
  orders,
  onSelectOrder,
}: IncomingOrdersListProps) {
  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-[64px]"></TableHead>
            <TableHead className="w-[140px]">N.º de orden</TableHead>
            <TableHead className="w-[180px]">Cliente</TableHead>
            <TableHead className="w-[110px]">Tiempo</TableHead>
            <TableHead className="w-[140px]">Estado</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {!orders?.results && (
            <TableRow>
              <TableCell colSpan={5} className="text-center">
                Cargando pedidos...
              </TableCell>
            </TableRow>
          )}
          {orders?.results &&
            orders.results.map((order) => (
              <TableRow
                key={order.id}
                onClick={() => onSelectOrder(order.id)}
                className="cursor-pointer"
              >
                <TableCell></TableCell>
                <TableCell className="font-mono text-xs font-medium">
                  {order.orderNumber || order.id.slice(0, 8)}
                </TableCell>
                <TableCell className="text-muted-foreground">
                  {order.customer?.name ||
                    order.customerSnapshot?.name ||
                    "Cliente"}
                </TableCell>
                <TableCell>
                  <Timer startTime={order.createdAt} />
                </TableCell>
                <TableCell>
                  <OrderStatus status={order.status} />
                </TableCell>
              </TableRow>
            ))}
          {orders?.results && orders.results.length === 0 && (
            <TableRow>
              <TableCell colSpan={5} className="text-center">
                No hay pedidos entrantes.
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
}
