import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  useGetManagedRestaurantQuery,
  useUpdateRestaurantSettingsMutation,
} from "@/core/hooks/useRestaurant";
import { UpdateRestaurantSettingsParams } from "@/core/models";

const shippingSettingsSchema = z.object({
  acceptsDelivery: z.boolean().default(false),
  acceptsPickup: z.boolean().default(false),
  acceptsDineIn: z.boolean().default(false),
  deliveryRadiusKm: z.coerce.number().min(0, "Debe ser positivo"),
  deliveryFeeCents: z.coerce.number().min(0, "Debe ser positivo"),
  deliveryFeePerKmCents: z.coerce.number().min(0, "Debe ser positivo"),
  minimumOrderCents: z.coerce.number().min(0, "Debe ser positivo"),
  freeDeliveryThresholdCents: z.coerce
    .number()
    .min(0, "Debe ser positivo")
    .optional(),
  estimatedDeliveryMinutes: z.coerce.number().min(1, "Mínimo 1 minuto"),
  estimatedPrepMinutes: z.coerce.number().min(1, "Mínimo 1 minuto"),
});

type ShippingFormValues = z.infer<typeof shippingSettingsSchema>;

export function ShippingSettings() {
  const { data: restaurant, isLoading } = useGetManagedRestaurantQuery();
  const { mutate: updateSettings, isPending: isSaving } =
    useUpdateRestaurantSettingsMutation();

  const form = useForm<ShippingFormValues>({
    resolver: zodResolver(shippingSettingsSchema),
    defaultValues: {
      acceptsDelivery: true,
      acceptsPickup: true,
      acceptsDineIn: false,
      deliveryRadiusKm: 5,
      deliveryFeeCents: 0,
      deliveryFeePerKmCents: 0,
      minimumOrderCents: 0,
      freeDeliveryThresholdCents: undefined,
      estimatedDeliveryMinutes: 30,
      estimatedPrepMinutes: 30,
    },
  });

  // Load existing data
  useEffect(() => {
    if (restaurant) {
      form.reset({
        acceptsDelivery: restaurant.acceptsDelivery,
        acceptsPickup: restaurant.acceptsPickup,
        acceptsDineIn: restaurant.acceptsDineIn,
        deliveryRadiusKm: restaurant.deliveryRadiusKm || 0,
        deliveryFeeCents: (restaurant.deliveryFeeCents || 0) / 100,
        deliveryFeePerKmCents: (restaurant.deliveryFeePerKmCents || 0) / 100,
        minimumOrderCents: (restaurant.minimumOrderCents || 0) / 100,
        freeDeliveryThresholdCents: restaurant.freeDeliveryThresholdCents
          ? restaurant.freeDeliveryThresholdCents / 100
          : undefined,

        estimatedDeliveryMinutes: restaurant.estimatedDeliveryMinutes || 30,
        estimatedPrepMinutes: restaurant.estimatedPrepMinutes || 30,
      });
    }
  }, [restaurant, form]);

  function onSubmit(data: ShippingFormValues) {
    const payload: UpdateRestaurantSettingsParams = {
      acceptsDelivery: data.acceptsDelivery,
      acceptsPickup: data.acceptsPickup,
      acceptsDineIn: data.acceptsDineIn,
      deliveryRadiusKm: data.deliveryRadiusKm,

      // Convert back to cents
      deliveryFeeCents: Math.round(data.deliveryFeeCents * 100),
      deliveryFeePerKmCents: Math.round(data.deliveryFeePerKmCents * 100),
      minimumOrderCents: Math.round(data.minimumOrderCents * 100),
      freeDeliveryThresholdCents: data.freeDeliveryThresholdCents
        ? Math.round(data.freeDeliveryThresholdCents * 100)
        : null,

      estimatedDeliveryMinutes: data.estimatedDeliveryMinutes,
      estimatedPrepMinutes: data.estimatedPrepMinutes,
    };

    updateSettings(payload);
  }

  if (isLoading) {
    return (
      <div className="flex h-40 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Configuración de Logística y Envío</CardTitle>
        <CardDescription>
          Administra las opciones de entrega, tarifas y tiempos estimados.
        </CardDescription>
      </CardHeader>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)}>
          <CardContent className="space-y-6">
            {/* Modalidades */}
            <div className="grid gap-4 sm:grid-cols-3">
              <FormField
                control={form.control}
                name="acceptsDelivery"
                render={({ field }) => (
                  <FormItem className="flex flex-row items-center space-x-3 space-y-0 rounded-md border p-4">
                    <FormControl>
                      <Checkbox
                        checked={field.value}
                        onCheckedChange={field.onChange}
                      />
                    </FormControl>
                    <div className="space-y-1 leading-none">
                      <FormLabel>Delivery</FormLabel>
                      <FormDescription>Habilitar entregas</FormDescription>
                    </div>
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="acceptsPickup"
                render={({ field }) => (
                  <FormItem className="flex flex-row items-center space-x-3 space-y-0 rounded-md border p-4">
                    <FormControl>
                      <Checkbox
                        checked={field.value}
                        onCheckedChange={field.onChange}
                      />
                    </FormControl>
                    <div className="space-y-1 leading-none">
                      <FormLabel>Pickup</FormLabel>
                      <FormDescription>
                        Habilitar recojo en tienda
                      </FormDescription>
                    </div>
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="acceptsDineIn"
                render={({ field }) => (
                  <FormItem className="flex flex-row items-center space-x-3 space-y-0 rounded-md border p-4">
                    <FormControl>
                      <Checkbox
                        checked={field.value}
                        onCheckedChange={field.onChange}
                      />
                    </FormControl>
                    <div className="space-y-1 leading-none">
                      <FormLabel>En Mesa</FormLabel>
                      <FormDescription>
                        Habilitar pedidos en mesa
                      </FormDescription>
                    </div>
                  </FormItem>
                )}
              />
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <FormField
                control={form.control}
                name="deliveryRadiusKm"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Radio de Cobertura (KM)</FormLabel>
                    <FormControl>
                      <Input type="number" step="0.1" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="minimumOrderCents"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Pedido Mínimo ($)</FormLabel>
                    <FormControl>
                      <Input type="number" step="0.01" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <FormField
                control={form.control}
                name="deliveryFeeCents"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Tarifa Base ($)</FormLabel>
                    <FormControl>
                      <Input type="number" step="0.01" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="deliveryFeePerKmCents"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Tarifa por KM Adicional ($)</FormLabel>
                    <FormControl>
                      <Input type="number" step="0.01" {...field} />
                    </FormControl>
                    <FormDescription>Se suma a la tarifa base</FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="freeDeliveryThresholdCents"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Envío Gratis a partir de ($)</FormLabel>
                  <FormControl>
                    <Input
                      type="number"
                      step="0.01"
                      {...field}
                      value={field.value || ""}
                    />
                  </FormControl>
                  <FormDescription>Dejar vacío si no aplica</FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid gap-4 sm:grid-cols-2">
              <FormField
                control={form.control}
                name="estimatedPrepMinutes"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Tiempo Preparación (min)</FormLabel>
                    <FormControl>
                      <Input type="number" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="estimatedDeliveryMinutes"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Tiempo Entrega (min)</FormLabel>
                    <FormControl>
                      <Input type="number" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>
          </CardContent>
          <CardFooter className="flex justify-end border-t px-6 py-4">
            <Button type="submit" disabled={isSaving}>
              {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Guardar Configuración
            </Button>
          </CardFooter>
        </form>
      </Form>
    </Card>
  );
}
