// src/core/hooks/useAuth.ts
import { useMutation } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

import * as AuthService from "@/core/services/auth.service";

export const useSignInMutation = () => {
  const navigate = useNavigate();

  return useMutation({
    mutationFn: AuthService.signIn,
    onSuccess: () => {
      navigate("/");
    },
    onError: () => {
      toast.error("Credenciales inválidas.");
    },
  });
};

export const useSignOutMutation = () => {
  const navigate = useNavigate();

  return useMutation({
    mutationFn: AuthService.signOut,
    onSuccess: () => {
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
