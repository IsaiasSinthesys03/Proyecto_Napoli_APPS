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
import { Label } from "@/components/ui/label";
import {
  useGetManagedRestaurantQuery,
  useUpdateRestaurantSettingsMutation,
} from "@/core/hooks/useRestaurant";
import { UpdateRestaurantSettingsParams } from "@/core/models";

const billingSettingsSchema = z.object({
  acceptsCard: z.boolean().default(false),
  acceptsCash: z.boolean().default(false),
  acceptsTransfer: z.boolean().default(false),
  bankName: z.string().optional(),
  bankAccountName: z.string().optional(),
  bankAccountClabe: z
    .string()
    .min(18, "La CLABE debe tener 18 dígitos")
    .max(18, "La CLABE debe tener 18 dígitos")
    .optional()
    .or(z.literal("")),
});

type BillingFormValues = z.infer<typeof billingSettingsSchema>;

export function BillingSettings() {
  const { data: restaurant, isLoading } = useGetManagedRestaurantQuery();
  const { mutate: updateSettings, isPending: isSaving } =
    useUpdateRestaurantSettingsMutation();

  const form = useForm<BillingFormValues>({
    resolver: zodResolver(billingSettingsSchema),
    defaultValues: {
      acceptsCard: true,
      acceptsCash: true,
      acceptsTransfer: false,
      bankName: "",
      bankAccountName: "",
      bankAccountClabe: "",
    },
  });

  // Load existing data
  useEffect(() => {
    if (restaurant) {
      form.reset({
        acceptsCard: restaurant.acceptsCard,
        acceptsCash: restaurant.acceptsCash,
        acceptsTransfer: restaurant.acceptsTransfer,
        bankName: restaurant.bankName || "",
        bankAccountName: restaurant.bankAccountName || "",
        bankAccountClabe: restaurant.bankAccountClabe || "",
      });
    }
  }, [restaurant, form]);

  function onSubmit(data: BillingFormValues) {
    const payload: UpdateRestaurantSettingsParams = {
      acceptsCard: data.acceptsCard,
      acceptsCash: data.acceptsCash,
      acceptsTransfer: data.acceptsTransfer,
      bankName: data.bankName || null,
      bankAccountName: data.bankAccountName || null,
      bankAccountClabe: data.bankAccountClabe || null,
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
        <CardTitle>Configuración de Cobro y Pagos</CardTitle>
        <CardDescription>
          Active o desactive métodos de pago para sus clientes y configure su
          cuenta bancaria para recibir depósitos.
        </CardDescription>
      </CardHeader>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)}>
          <CardContent className="space-y-6">
            <div className="space-y-4">
              <Label className="text-base">Métodos de Pago Aceptados</Label>
              <div className="grid gap-4 sm:grid-cols-3">
                <FormField
                  control={form.control}
                  name="acceptsCash"
                  render={({ field }) => (
                    <FormItem className="flex flex-row items-center space-x-3 space-y-0 rounded-md border p-4">
                      <FormControl>
                        <Checkbox
                          checked={field.value}
                          onCheckedChange={field.onChange}
                        />
                      </FormControl>
                      <div className="space-y-1 leading-none">
                        <FormLabel>Efectivo</FormLabel>
                        <FormDescription>Pago contra entrega</FormDescription>
                      </div>
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="acceptsCard"
                  render={({ field }) => (
                    <FormItem className="flex flex-row items-center space-x-3 space-y-0 rounded-md border p-4">
                      <FormControl>
                        <Checkbox
                          checked={field.value}
                          onCheckedChange={field.onChange}
                        />
                      </FormControl>
                      <div className="space-y-1 leading-none">
                        <FormLabel>Tarjeta</FormLabel>
                        <FormDescription>Crédito o Débito</FormDescription>
                      </div>
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="acceptsTransfer"
                  render={({ field }) => (
                    <FormItem className="flex flex-row items-center space-x-3 space-y-0 rounded-md border p-4">
                      <FormControl>
                        <Checkbox
                          checked={field.value}
                          onCheckedChange={field.onChange}
                        />
                      </FormControl>
                      <div className="space-y-1 leading-none">
                        <FormLabel>Transferencia</FormLabel>
                        <FormDescription>SPEI / Transferencia</FormDescription>
                      </div>
                    </FormItem>
                  )}
                />
              </div>
            </div>

            <div className="space-y-4">
              <Label className="text-base">
                Datos Bancarios para Depósitos
              </Label>
              <div className="grid gap-4 sm:grid-cols-2">
                <FormField
                  control={form.control}
                  name="bankName"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Banco</FormLabel>
                      <FormControl>
                        <Input placeholder="Ej. BBVA" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="bankAccountName"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Nombre del Titular</FormLabel>
                      <FormControl>
                        <Input placeholder="Nombre completo" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
              <FormField
                control={form.control}
                name="bankAccountClabe"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>CLABE Interbancaria</FormLabel>
                    <FormControl>
                      <Input
                        placeholder="18 dígitos"
                        maxLength={18}
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>
                      Para recibir sus ganancias semanalmente.
                    </FormDescription>
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
