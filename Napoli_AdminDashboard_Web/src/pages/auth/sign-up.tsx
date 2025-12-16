import { zodResolver } from "@hookform/resolvers/zod";
import { Helmet } from "react-helmet-async";
import { useForm } from "react-hook-form";
import { Link } from "react-router-dom";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useRegisterRestaurantMutation } from "@/core/hooks/useRestaurant";

const signUpForm = z
  .object({
    restaurantName: z
      .string()
      .min(1, "El nombre del restaurante es obligatorio"),
    managerName: z.string().min(1, "Tu nombre es obligatorio"),
    phone: z.string().min(1, "El teléfono es obligatorio"),
    email: z.string().email("E-mail inválido"),
    password: z
      .string()
      .min(6, "La contraseña debe tener al menos 6 caracteres"),
    confirmPassword: z.string().min(6, "Confirma tu contraseña"),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Las contraseñas no coinciden",
    path: ["confirmPassword"],
  });

type SignUpForm = z.infer<typeof signUpForm>;

export function SignUp() {
  const {
    register,
    handleSubmit,
    formState: { isSubmitting, errors },
  } = useForm<SignUpForm>({
    resolver: zodResolver(signUpForm),
  });

  const { mutateAsync: registerRestaurantFn } = useRegisterRestaurantMutation();

  async function handleSignUp(data: SignUpForm) {
    await registerRestaurantFn({
      restaurantName: data.restaurantName,
      managerName: data.managerName,
      email: data.email,
      phone: data.phone,
      password: data.password,
    });
  }

  return (
    <>
      <Helmet title="Registro" />
      <div className="p-8">
        <Button variant="ghost" asChild>
          <Link to="/sign-in" className="absolute right-8 top-8">
            Iniciar sesión
          </Link>
        </Button>

        <div className="flex w-[350px] flex-col justify-center gap-6">
          <div className="flex flex-col gap-2 text-center">
            <h1 className="text-2xl font-semibold tracking-tight">
              Crear cuenta
            </h1>
            <p className="text-sm text-muted-foreground">
              ¡Sé un socio y comienza tus ventas!
            </p>
          </div>

          <form onSubmit={handleSubmit(handleSignUp)} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="restaurantName">Nombre del establecimiento</Label>
              <Input
                id="restaurantName"
                type="text"
                {...register("restaurantName")}
              />
              {errors.restaurantName && (
                <p className="text-sm text-red-500">
                  {errors.restaurantName.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="managerName">Tu nombre</Label>
              <Input
                id="managerName"
                type="text"
                {...register("managerName")}
              />
              {errors.managerName && (
                <p className="text-sm text-red-500">
                  {errors.managerName.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="email">Tu correo electrónico</Label>
              <Input id="email" type="email" {...register("email")} />
              {errors.email && (
                <p className="text-sm text-red-500">{errors.email.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="phone">Tu teléfono móvil</Label>
              <Input id="phone" type="tel" {...register("phone")} />
              {errors.phone && (
                <p className="text-sm text-red-500">{errors.phone.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Contraseña</Label>
              <Input id="password" type="password" {...register("password")} />
              {errors.password && (
                <p className="text-sm text-red-500">
                  {errors.password.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="confirmPassword">Confirmar contraseña</Label>
              <Input
                id="confirmPassword"
                type="password"
                {...register("confirmPassword")}
              />
              {errors.confirmPassword && (
                <p className="text-sm text-red-500">
                  {errors.confirmPassword.message}
                </p>
              )}
            </div>

            <Button disabled={isSubmitting} className="w-full" type="submit">
              Finalizar registro
            </Button>

            <p className="px-6 text-center text-sm leading-relaxed text-muted-foreground">
              Al continuar, aceptas nuestros{" "}
              <a className="underline underline-offset-4" href="#">
                términos de servicio
              </a>{" "}
              y{" "}
              <a className="underline underline-offset-4" href="#">
                políticas de privacidad
              </a>
              .
            </p>
          </form>
        </div>
      </div>
    </>
  );
}
