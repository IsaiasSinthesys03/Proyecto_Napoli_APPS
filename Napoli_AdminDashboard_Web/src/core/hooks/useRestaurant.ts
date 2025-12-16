// src/core/hooks/useRestaurant.ts
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

import { Restaurant } from "@/core/models";
import * as RestaurantService from "@/core/services/restaurant.service";

export const useGetManagedRestaurantQuery = () => {
  return useQuery({
    queryKey: ["managed-restaurant"],
    queryFn: RestaurantService.getManagedRestaurant,
    staleTime: Infinity,
  });
};

export const useUpdateRestaurantProfileMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: RestaurantService.updateRestaurantProfile,
    onMutate: async (variables) => {
      await queryClient.cancelQueries({ queryKey: ["managed-restaurant"] });

      const previousRestaurant = queryClient.getQueryData<Restaurant>([
        "managed-restaurant",
      ]);

      queryClient.setQueryData<Restaurant>(["managed-restaurant"], (old) => {
        if (!old) return undefined;
        return {
          ...old,
          name: variables.name ?? old.name,
          description: variables.description ?? old.description,
        };
      });

      return { previousRestaurant };
    },
    onError: (_, __, context) => {
      if (context?.previousRestaurant) {
        queryClient.setQueryData(
          ["managed-restaurant"],
          context.previousRestaurant,
        );
      }
      toast.error("Error al actualizar el perfil, por favor intente de nuevo.");
    },
    onSuccess: () => {
      toast.success("¡Perfil actualizado con éxito!");
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["managed-restaurant"] });
    },
  });
};

export const useUpdateRestaurantSettingsMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: RestaurantService.updateRestaurantSettings,
    onMutate: async (variables) => {
      await queryClient.cancelQueries({ queryKey: ["managed-restaurant"] });
      const previousRestaurant = queryClient.getQueryData<Restaurant>([
        "managed-restaurant",
      ]);

      queryClient.setQueryData<Restaurant>(["managed-restaurant"], (old) => {
        if (!old) return undefined;
        return { ...old, ...variables };
      });

      return { previousRestaurant };
    },
    onError: (_, __, context) => {
      if (context?.previousRestaurant) {
        queryClient.setQueryData(
          ["managed-restaurant"],
          context.previousRestaurant,
        );
      }
      toast.error("Error al actualizar la configuración.");
    },
    onSuccess: () => {
      toast.success("¡Configuración actualizada con éxito!");
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["managed-restaurant"] });
    },
  });
};

export const useRegisterRestaurantMutation = () => {
  const navigate = useNavigate();

  return useMutation({
    mutationFn: RestaurantService.registerRestaurant,
    onSuccess: (_, variables) => {
      toast.success("Restaurante registrado con éxito");
      navigate(`/sign-in?email=${variables.email}`);
    },
    onError: () => {
      toast.error("Error al registrar el restaurante");
    },
  });
};
