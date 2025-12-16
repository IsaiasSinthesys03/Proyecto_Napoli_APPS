// OrderStatus type matching schema.sql
export type OrderStatus =
  | "pending"
  | "accepted"
  | "processing"
  | "ready"
  | "delivering"
  | "delivered"
  | "cancelled";

interface OrderStatusProps {
  status: OrderStatus;
}

const orderStatusMap: Record<OrderStatus, string> = {
  pending: "Pendiente",
  accepted: "Aceptado",
  processing: "En preparación",
  ready: "Listo para recoger",
  delivering: "En reparto",
  delivered: "Entregado",
  cancelled: "Cancelado",
};

const orderStatusColorMap: Record<OrderStatus, string> = {
  pending: "bg-slate-400",
  accepted: "bg-blue-500",
  processing: "bg-amber-500",
  ready: "bg-green-400",
  delivering: "bg-amber-500",
  delivered: "bg-emerald-500",
  cancelled: "bg-rose-500",
};

export function OrderStatus({ status }: OrderStatusProps) {
  return (
    <div className="flex items-center gap-2">
      <span
        data-testid="badge"
        className={`h-2 w-2 rounded-full ${orderStatusColorMap[status] || "bg-slate-400"}`}
      />
      <span className="font-medium text-muted-foreground">
        {orderStatusMap[status] || status}
      </span>
    </div>
  );
}
