// src/core/hooks/useAddons.ts
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import {
  CreateAddonPayload,
  UpdateAddonPayload,
} from "@/core/models/addon.model";
import {
  createAddon,
  deleteAddon,
  getAddons,
  updateAddon,
} from "@/core/services/addon.service";

export const useAddons = () => {
  return useQuery({
    queryKey: ["addons"],
    queryFn: getAddons,
  });
};

export const useCreateAddon = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: CreateAddonPayload) => createAddon(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["addons"] });
    },
  });
};

export const useUpdateAddon = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: UpdateAddonPayload) => updateAddon(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["addons"] });
    },
  });
};

export const useDeleteAddon = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (addonId: string) => deleteAddon(addonId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["addons"] });
    },
  });
};
