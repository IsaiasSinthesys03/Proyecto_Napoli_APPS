import {
  AlertCircle,
  Bike,
  ChefHat,
  CheckCircle2,
  Clock,
  PackageCheck,
  XCircle
} from "lucide-react";

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
  accepted: "Aceptado por un repartidor",
  processing: "En preparación",
  ready: "Listo para recoger",
  delivering: "En reparto",
  delivered: "Entregado",
  cancelled: "Cancelado",
};

// Map of status to Lucide Icon
const orderStatusIconMap: Record<OrderStatus, React.ElementType> = {
  pending: AlertCircle,
  processing: ChefHat,
  ready: CheckCircle2,
  accepted: PackageCheck,
  delivering: Bike,
  delivered: CheckCircle2, // Or a different check icon if preferred
  cancelled: XCircle,
};

// Map of status to CSS classes for colors (text and bg)
const orderStatusStyleMap: Record<OrderStatus, string> = {
  pending: "text-purple-600 bg-purple-100",
  processing: "text-yellow-600 bg-yellow-100",
  ready: "text-cyan-600 bg-cyan-100",
  accepted: "text-blue-600 bg-blue-100",
  delivering: "text-orange-600 bg-orange-100",
  delivered: "text-green-600 bg-green-100",
  cancelled: "text-red-600 bg-red-100",
};

export function OrderStatus({ status }: OrderStatusProps) {
  const Icon = orderStatusIconMap[status] || Clock;
  const styles = orderStatusStyleMap[status] || "text-slate-600 bg-slate-100";

  return (
    <div className={`flex items-center gap-2 px-2.5 py-0.5 rounded-full w-fit ${styles}`}>
      <Icon className="h-4 w-4" />
      <span className="font-medium text-sm">
        {orderStatusMap[status] || status}
      </span>
    </div>
  );
}
