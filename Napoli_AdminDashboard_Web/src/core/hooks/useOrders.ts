import {
  QueryClient,
  useMutation,
  useQuery,
  useQueryClient,
} from "@tanstack/react-query";
import { toast } from "sonner";

import {
  GetOrdersParams,
  Order,
  OrderStatusType,
  PaginatedOrders,
} from "@/core/models";
import * as OrderService from "@/core/services/order.service";

function updateOrderStatusOnCache(
  queryClient: QueryClient,
  orderId: string,
  status: OrderStatusType,
) {
  const queryKey = [
    "orders",
    { page: 1, status: ["pending", "accepted", "processing", "ready", "delivering"] },
  ];
  const ordersListCache = queryClient.getQueryData<PaginatedOrders>(queryKey);

  if (ordersListCache) {
    queryClient.setQueryData<PaginatedOrders>(queryKey, {
      ...ordersListCache,
      results: ordersListCache.results.map((order: Order) => {
        if (order.id === orderId) {
          return { ...order, status };
        }
        return order;
      }),
    });
  }
}

// Query (para obtener datos)
export const useGetOrdersQuery = (params: GetOrdersParams) => {
  return useQuery({
    queryKey: ["orders", params], // La key de caché incluye los params
    queryFn: () => OrderService.getOrders(params),
  });
};

export const useGetOrderDetailsQuery = (orderId: string) => {
  return useQuery({
    queryKey: ["order-details", orderId],
    queryFn: () => OrderService.getOrderDetails(orderId),
    enabled: !!orderId, // Solo ejecuta la query si hay un orderId
  });
};

// Mutations (para cambiar datos)
export const useApproveOrderMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (orderId: string) => OrderService.approveOrder(orderId),
    onSuccess: (_, orderId) => {
      updateOrderStatusOnCache(queryClient, orderId, "processing");
      queryClient.invalidateQueries({ queryKey: ["order-details", orderId] });
      toast.success("¡Pedido aceptado con éxito!");
    },
    onError: (error: Error) => {
      toast.error("Error al aceptar el pedido: " + error.message);
    },
  });
};

export const useCancelOrderMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (orderId: string) => OrderService.cancelOrder(orderId),
    onSuccess: (_, orderId) => {
      updateOrderStatusOnCache(queryClient, orderId, "cancelled");
      queryClient.invalidateQueries({ queryKey: ["order-details", orderId] });
      toast.success("Pedido cancelado con éxito.");
    },
    onError: () => {
      toast.error("Error al cancelar el pedido, por favor intente de nuevo.");
    },
  });
};

export const useDispatchOrderMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (orderId: string) => OrderService.dispatchOrder(orderId),
    onSuccess: (_, orderId) => {
      updateOrderStatusOnCache(queryClient, orderId, "delivering");
      queryClient.invalidateQueries({ queryKey: ["order-details", orderId] });
      toast.success("Pedido enviado con éxito.");
    },
    onError: () => {
      toast.error("Error al enviar el pedido, por favor intente de nuevo.");
    },
  });
};

export const useReadyOrderMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (orderId: string) => OrderService.readyOrder(orderId),
    onSuccess: (_, orderId) => {
      updateOrderStatusOnCache(queryClient, orderId, "ready");
      queryClient.invalidateQueries({ queryKey: ["order-details", orderId] });
      toast.success("Pedido listo para entrega.");
    },
    onError: () => {
      toast.error("Error al cambiar estado, por favor intente de nuevo.");
    },
  });
};

export const useDeliverOrderMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (orderId: string) => OrderService.deliverOrder(orderId),
    onSuccess: (_, orderId) => {
      updateOrderStatusOnCache(queryClient, orderId, "delivered");
      queryClient.invalidateQueries({ queryKey: ["order-details", orderId] });
      toast.success("Pedido en reparto.");
    },
    onError: () => {
      toast.error("Error al entregar el pedido, por favor intente de nuevo.");
    },
  });
};

export const useFinishOrderMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (orderId: string) => OrderService.finishOrder(orderId),
    onSuccess: (_, orderId) => {
      updateOrderStatusOnCache(queryClient, orderId, "delivered");
      queryClient.invalidateQueries({ queryKey: ["order-details", orderId] });
      toast.success("Pedido finalizado con éxito.");
    },
    onError: () => {
      toast.error("Error al finalizar el pedido, por favor intente de nuevo.");
    },
  });
};
