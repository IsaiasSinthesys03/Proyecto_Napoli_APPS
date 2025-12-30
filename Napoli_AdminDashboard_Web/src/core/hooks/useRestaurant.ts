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
          email: variables.email ?? old.email,
          phone: variables.phone ?? old.phone,
          whatsapp: variables.whatsapp ?? old.whatsapp,
          website: variables.website ?? old.website,
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

export const useUpdateRestaurantBrandingMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: RestaurantService.updateRestaurantBranding,
    onMutate: async (variables) => {
      await queryClient.cancelQueries({ queryKey: ["managed-restaurant"] });

      const previousRestaurant = queryClient.getQueryData<Restaurant>([
        "managed-restaurant",
      ]);

      queryClient.setQueryData<Restaurant>(["managed-restaurant"], (old) => {
        if (!old) return undefined;
        return {
          ...old,
          logoUrl: variables.logoUrl ?? old.logoUrl,
          bannerUrl: variables.bannerUrl ?? old.bannerUrl,
          primaryColor: variables.primaryColor ?? old.primaryColor,
          secondaryColor: variables.secondaryColor ?? old.secondaryColor,
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
      toast.error("Error al actualizar la marca.");
    },
    onSuccess: () => {
      toast.success("¡Marca actualizada con éxito!");
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["managed-restaurant"] });
    },
  });
};

export const useUpdateRestaurantLocationMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: RestaurantService.updateRestaurantLocation,
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
      toast.error("Error al actualizar la ubicación.");
    },
    onSuccess: () => {
      toast.success("¡Ubicación actualizada con éxito!");
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["managed-restaurant"] });
    },
  });
};

export const useUpdateRestaurantRegionalSettingsMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: RestaurantService.updateRestaurantRegionalSettings,
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
      toast.error("Error al actualizar la configuración regional.");
    },
    onSuccess: () => {
      toast.success("¡Configuración regional actualizada con éxito!");
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

export const useUploadRestaurantLogoMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: RestaurantService.uploadRestaurantLogo,
    onSuccess: (logoUrl) => {
      // Update branding with new logo URL
      queryClient.setQueryData<Restaurant>(["managed-restaurant"], (old) => {
        if (!old) return undefined;
        return { ...old, logoUrl };
      });
      toast.success("¡Logo subido con éxito!");
    },
    onError: () => {
      toast.error("Error al subir el logo.");
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["managed-restaurant"] });
    },
  });
};

export const useUploadRestaurantBannerMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: RestaurantService.uploadRestaurantBanner,
    onSuccess: (bannerUrl) => {
      // Update branding with new banner URL
      queryClient.setQueryData<Restaurant>(["managed-restaurant"], (old) => {
        if (!old) return undefined;
        return { ...old, bannerUrl };
      });
      toast.success("¡Banner subido con éxito!");
    },
    onError: () => {
      toast.error("Error al subir el banner.");
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
