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
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import {
    useGetManagedRestaurantQuery,
    useUpdateRestaurantRegionalSettingsMutation,
} from "@/core/hooks/useRestaurant";

const regionalSchema = z.object({
    currencyCode: z.string(),
    currencySymbol: z.string(),
    currencyPosition: z.enum(["before", "after"]),
    decimalSeparator: z.string().length(1),
    thousandsSeparator: z.string().length(1),
    decimalPlaces: z.coerce.number().min(0).max(4),
    taxRatePercentage: z.coerce.number().min(0).max(100),
    taxIncludedInPrices: z.boolean(),
});

type RegionalFormValues = z.infer<typeof regionalSchema>;

const CURRENCIES = [
    { code: "MXN", symbol: "$", name: "Peso Mexicano" },
    { code: "USD", symbol: "$", name: "Dólar Estadounidense" },
    { code: "EUR", symbol: "€", name: "Euro" },
    { code: "GBP", symbol: "£", name: "Libra Esterlina" },
    { code: "CAD", symbol: "$", name: "Dólar Canadiense" },
    { code: "COP", symbol: "$", name: "Peso Colombiano" },
    { code: "ARS", symbol: "$", name: "Peso Argentino" },
    { code: "CLP", symbol: "$", name: "Peso Chileno" },
];

export function RegionalSettings() {
    const { data: restaurant, isLoading } = useGetManagedRestaurantQuery();
    const { mutate: updateRegional, isPending: isSaving } =
        useUpdateRestaurantRegionalSettingsMutation();

    const form = useForm<RegionalFormValues>({
        resolver: zodResolver(regionalSchema),
        defaultValues: {
            currencyCode: "MXN",
            currencySymbol: "$",
            currencyPosition: "before",
            decimalSeparator: ".",
            thousandsSeparator: ",",
            decimalPlaces: 2,
            taxRatePercentage: 0,
            taxIncludedInPrices: true,
        },
    });

    useEffect(() => {
        if (restaurant) {
            form.reset({
                currencyCode: restaurant.currencyCode,
                currencySymbol: restaurant.currencySymbol,
                currencyPosition: restaurant.currencyPosition,
                decimalSeparator: restaurant.decimalSeparator,
                thousandsSeparator: restaurant.thousandsSeparator,
                decimalPlaces: restaurant.decimalPlaces,
                taxRatePercentage: restaurant.taxRatePercentage,
                taxIncludedInPrices: restaurant.taxIncludedInPrices,
            });
        }
    }, [restaurant, form]);

    function onSubmit(data: RegionalFormValues) {
        updateRegional(data);
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
                <CardTitle>Configuración Regional</CardTitle>
                <CardDescription>
                    Moneda, impuestos y formato de números
                </CardDescription>
            </CardHeader>
            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)}>
                    <CardContent className="space-y-6">
                        {/* Currency */}
                        <div className="space-y-4">
                            <h3 className="text-base font-semibold">Moneda</h3>
                            <div className="grid gap-4 sm:grid-cols-2">
                                <FormField
                                    control={form.control}
                                    name="currencyCode"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Código de Moneda</FormLabel>
                                            <Select
                                                onValueChange={(value) => {
                                                    field.onChange(value);
                                                    const currency = CURRENCIES.find(
                                                        (c) => c.code === value,
                                                    );
                                                    if (currency) {
                                                        form.setValue("currencySymbol", currency.symbol);
                                                    }
                                                }}
                                                defaultValue={field.value}
                                            >
                                                <FormControl>
                                                    <SelectTrigger>
                                                        <SelectValue />
                                                    </SelectTrigger>
                                                </FormControl>
                                                <SelectContent>
                                                    {CURRENCIES.map((currency) => (
                                                        <SelectItem
                                                            key={currency.code}
                                                            value={currency.code}
                                                        >
                                                            {currency.code} - {currency.name}
                                                        </SelectItem>
                                                    ))}
                                                </SelectContent>
                                            </Select>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />

                                <FormField
                                    control={form.control}
                                    name="currencySymbol"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Símbolo</FormLabel>
                                            <FormControl>
                                                <Input placeholder="$" {...field} />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </div>

                            <FormField
                                control={form.control}
                                name="currencyPosition"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Posición del Símbolo</FormLabel>
                                        <Select
                                            onValueChange={field.onChange}
                                            defaultValue={field.value}
                                        >
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value="before">Antes ($100.00)</SelectItem>
                                                <SelectItem value="after">Después (100.00$)</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        {/* Number Formatting */}
                        <div className="space-y-4">
                            <h3 className="text-base font-semibold">Formato de Números</h3>
                            <div className="grid gap-4 sm:grid-cols-3">
                                <FormField
                                    control={form.control}
                                    name="decimalSeparator"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Separador Decimal</FormLabel>
                                            <FormControl>
                                                <Input placeholder="." maxLength={1} {...field} />
                                            </FormControl>
                                            <FormDescription>Ej: 100.50</FormDescription>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />

                                <FormField
                                    control={form.control}
                                    name="thousandsSeparator"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Separador de Miles</FormLabel>
                                            <FormControl>
                                                <Input placeholder="," maxLength={1} {...field} />
                                            </FormControl>
                                            <FormDescription>Ej: 1,000</FormDescription>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />

                                <FormField
                                    control={form.control}
                                    name="decimalPlaces"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Decimales</FormLabel>
                                            <FormControl>
                                                <Input type="number" min={0} max={4} {...field} />
                                            </FormControl>
                                            <FormDescription>0-4 decimales</FormDescription>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </div>
                        </div>

                        {/* Tax */}
                        <div className="space-y-4">
                            <h3 className="text-base font-semibold">Impuestos</h3>
                            <FormField
                                control={form.control}
                                name="taxRatePercentage"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Tasa de Impuesto (%)</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                step="0.01"
                                                min={0}
                                                max={100}
                                                placeholder="16.00"
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormDescription>
                                            IVA o impuesto aplicable (ej: 16% en México)
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="taxIncludedInPrices"
                                render={({ field }) => (
                                    <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                                        <div className="space-y-0.5">
                                            <FormLabel className="text-base">
                                                Impuesto Incluido en Precios
                                            </FormLabel>
                                            <FormDescription>
                                                Si está activado, los precios mostrados ya incluyen
                                                impuestos
                                            </FormDescription>
                                        </div>
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
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
