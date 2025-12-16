// src/core/hooks/useProducts.ts
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";

import {
  CreateProductPayload,
  UpdateProductPayload,
} from "@/core/models/product.model";
import * as ProductService from "@/core/services/product.service";

export const useProducts = () => {
  return useQuery({
    queryKey: ["products"],
    queryFn: ProductService.getProducts,
  });
};

export const useProduct = (id: string) => {
  return useQuery({
    queryKey: ["product", id],
    queryFn: () => ProductService.getProduct(id),
    enabled: !!id,
  });
};

export const useCreateProduct = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      payload,
      image,
    }: {
      payload: CreateProductPayload;
      image?: File;
    }) => ProductService.createProduct(payload, image),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      toast.success("Producto creado con éxito.");
    },
    onError: () => {
      toast.error("Error al crear el producto, por favor intente de nuevo.");
    },
  });
};

export const useUpdateProduct = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      payload,
      image,
    }: {
      payload: UpdateProductPayload;
      image?: File;
    }) => ProductService.updateProduct(payload, image),
    onSuccess: (_, { payload }) => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      queryClient.invalidateQueries({ queryKey: ["product", payload.id] });
      toast.success("Producto actualizado con éxito.");
    },
    onError: () => {
      toast.error(
        "Error al actualizar el producto, por favor intente de nuevo.",
      );
    },
  });
};

export const useDeleteProduct = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ProductService.deleteProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      toast.success("Producto eliminado con éxito.");
    },
    onError: () => {
      toast.error("Error al eliminar el producto, por favor intente de nuevo.");
    },
  });
};

export const useToggleProductAvailability = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, isAvailable }: { id: string; isAvailable: boolean }) =>
      ProductService.toggleProductAvailability(id, isAvailable),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      toast.success("Disponibilidad actualizada.");
    },
    onError: () => {
      toast.error("Error al actualizar la disponibilidad.");
    },
  });
};
