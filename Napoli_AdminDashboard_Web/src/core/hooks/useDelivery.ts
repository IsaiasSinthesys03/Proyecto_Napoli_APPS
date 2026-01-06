// src/core/hooks/useDelivery.ts
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";

import * as DeliveryService from "@/core/services/delivery.service";

export const useGetDeliveryMenQuery = () => {
  return useQuery({
    queryKey: ["delivery-men"],
    queryFn: DeliveryService.getDeliveryMen,
  });
};

export const useCreateDeliveryManMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: DeliveryService.createDeliveryMan,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["delivery-men"] });
      toast.success("Repartidor creado con éxito.");
    },
    onError: () => {
      toast.error("Error al crear el repartidor, por favor intente de nuevo.");
    },
  });
};

export const useUpdateDeliveryManMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      id,
      payload,
    }: {
      id: string;
      payload: { name: string; phone: string };
    }) => DeliveryService.updateDeliveryMan(id, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["delivery-men"] });
      toast.success("Repartidor actualizado con éxito.");
    },
    onError: () => {
      toast.error(
        "Error al actualizar el repartidor, por favor intente de nuevo.",
      );
    },
  });
};

export const useDeleteDeliveryManMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: DeliveryService.deleteDeliveryMan,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["delivery-men"] });
      toast.success("Repartidor eliminado con éxito.");
    },
    onError: () => {
      toast.error(
        "Error al eliminar el repartidor, por favor intente de nuevo.",
      );
    },
  });
};

export const useToggleDeliveryManStatusMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      id,
      status,
    }: {
      id: string;
      status: "pending" | "approved" | "active" | "inactive" | "suspended";
    }) => DeliveryService.toggleDeliveryManStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["delivery-men"] });
      toast.success("Estado del repartidor actualizado con éxito.");
    },
    onError: () => {
      toast.error(
        "Error al actualizar el estado del repartidor, por favor intente de nuevo.",
      );
    },
  });
};

export const useAssignDeliveryManMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: DeliveryService.assignDeliveryMan,
    onSuccess: (_, { orderId }) => {
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      queryClient.invalidateQueries({ queryKey: ["order-details", orderId] });
      toast.success("Repartidor asignado con éxito.");
    },
    onError: (error: Error) => {
      toast.error(error.message || "Error al asignar el repartidor.");
    },
  });
};

export const useActiveDeliveries = () => {
  return useQuery({
    queryKey: ["active-deliveries"],
    queryFn: DeliveryService.getActiveDeliveries,
    refetchInterval: 10000, // Refresh every 10 seconds for near real-time
    refetchIntervalInBackground: true,
    refetchOnWindowFocus: true,
  });
};

export const useActiveDriverLocations = () => {
  return useQuery({
    queryKey: ["active-driver-locations"],
    queryFn: DeliveryService.getActiveDriversLocations,
    refetchInterval: 60000, // 60 seconds (render location every minute)
    refetchIntervalInBackground: true,
    refetchOnWindowFocus: true,
  });
};
