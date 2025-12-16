import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import { DialogClose, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useChangePasswordMutation } from "@/core/hooks/useAuth";
import {
  useGetProfileQuery,
  useUpdateProfileMutation,
} from "@/core/hooks/useUser";

const profileSchema = z
  .object({
    name: z.string().min(1, "El nombre es obligatorio"),
    email: z.string().email("Correo electrónico inválido"),
    currentPassword: z.string().optional(),
    newPassword: z.string().optional(),
    confirmNewPassword: z.string().optional(),
  })
  .refine(
    (data) => {
      if (data.newPassword && !data.currentPassword) {
        return false;
      }
      return true;
    },
    {
      message:
        "La contraseña actual es obligatoria para cambiar la contraseña.",
      path: ["currentPassword"],
    },
  )
  .refine(
    (data) => {
      if (data.newPassword && data.newPassword !== data.confirmNewPassword) {
        return false;
      }
      return true;
    },
    {
      message: "Las nuevas contraseñas no coinciden.",
      path: ["confirmNewPassword"],
    },
  );

type ProfileSchema = z.infer<typeof profileSchema>;

export function ProfileSettings() {
  const { data: profile } = useGetProfileQuery();
  const { mutateAsync: updateProfileMutation } = useUpdateProfileMutation();
  const { mutateAsync: changePasswordMutation } = useChangePasswordMutation();

  const {
    register,
    handleSubmit,
    formState: { isSubmitting, errors },
  } = useForm<ProfileSchema>({
    resolver: zodResolver(profileSchema),
    values: {
      name: profile?.name ?? "",
      email: profile?.email ?? "",
      currentPassword: "",
      newPassword: "",
      confirmNewPassword: "",
    },
  });

  async function handleUpdateAdminProfile(data: ProfileSchema) {
    await updateProfileMutation({
      name: data.name,
      description: "",
    });

    if (data.newPassword) {
      await changePasswordMutation(data.newPassword);
    }
  }

  return (
    <form
      onSubmit={handleSubmit(handleUpdateAdminProfile)}
      className="space-y-4"
    >
      <div className="space-y-2">
        <Label htmlFor="name">Nombre del Administrador</Label>
        <Input id="name" type="text" {...register("name")} />
        {errors.name && (
          <p className="text-sm text-red-500">{errors.name.message}</p>
        )}
      </div>
      <div className="space-y-2">
        <Label htmlFor="email">Correo Electrónico</Label>
        <Input id="email" type="email" {...register("email")} disabled />
      </div>
      <div className="space-y-2">
        <Label htmlFor="currentPassword">Contraseña Actual</Label>
        <Input
          id="currentPassword"
          type="password"
          {...register("currentPassword")}
        />
        {errors.currentPassword && (
          <p className="text-sm text-red-500">
            {errors.currentPassword.message}
          </p>
        )}
      </div>
      <div className="space-y-2">
        <Label htmlFor="newPassword">Nueva Contraseña</Label>
        <Input id="newPassword" type="password" {...register("newPassword")} />
        {errors.newPassword && (
          <p className="text-sm text-red-500">{errors.newPassword.message}</p>
        )}
      </div>
      <div className="space-y-2">
        <Label htmlFor="confirmNewPassword">Confirmar Nueva Contraseña</Label>
        <Input
          id="confirmNewPassword"
          type="password"
          {...register("confirmNewPassword")}
        />
        {errors.confirmNewPassword && (
          <p className="text-sm text-red-500">
            {errors.confirmNewPassword.message}
          </p>
        )}
      </div>
      <DialogFooter>
        <DialogClose asChild>
          <Button type="button" variant="ghost">
            Cancelar
          </Button>
        </DialogClose>
        <Button type="submit" disabled={isSubmitting}>
          Guardar
        </Button>
      </DialogFooter>
    </form>
  );
}
