// src/core/hooks/useAuth.ts
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

import * as AuthService from "@/core/services/auth.service";

export const useSignInMutation = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: AuthService.signIn,
    onSuccess: () => {
      // Invalidate all queries to refresh user data
      queryClient.invalidateQueries({ queryKey: ["profile"] });
      queryClient.invalidateQueries({ queryKey: ["managedRestaurant"] });
      navigate("/");
    },
    onError: () => {
      toast.error("Credenciales inválidas.");
    },
  });
};

export const useSignOutMutation = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: AuthService.signOut,
    onSuccess: () => {
      // Clear all queries on sign out
      queryClient.clear();
      navigate("/sign-in");
    },
  });
};

export const useChangePasswordMutation = () => {
  return useMutation({
    mutationFn: AuthService.changePassword,
    onSuccess: () => {
      toast.success("Contraseña actualizada con éxito.");
    },
    onError: () => {
      toast.error(
        "Error al actualizar la contraseña, por favor intente de nuevo.",
      );
    },
  });
};
