// src/core/hooks/useUser.ts
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";

import { User } from "@/core/models";
import * as UserService from "@/core/services/user.service";

export const useGetProfileQuery = () => {
  return useQuery({
    queryKey: ["profile"],
    queryFn: UserService.getProfile,
    staleTime: Infinity,
  });
};

export const useUpdateProfileMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: UserService.updateProfile,
    onMutate: async (variables) => {
      await queryClient.cancelQueries({ queryKey: ["profile"] });

      const previousProfile = queryClient.getQueryData<User>(["profile"]);

      queryClient.setQueryData<User>(["profile"], (old) => {
        if (!old) return undefined;
        return { ...old, name: variables.name };
      });

      return { previousProfile };
    },
    onError: (_, __, context) => {
      if (context?.previousProfile) {
        queryClient.setQueryData(["profile"], context.previousProfile);
      }
      toast.error("Error al actualizar el perfil, por favor intente de nuevo.");
    },
    onSuccess: () => {
      toast.success("¡Perfil actualizado con éxito!");
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["profile"] });
    },
  });
};
