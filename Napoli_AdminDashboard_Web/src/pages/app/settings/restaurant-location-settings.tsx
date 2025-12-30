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
import {
    useGetManagedRestaurantQuery,
    useUpdateRestaurantLocationMutation,
} from "@/core/hooks/useRestaurant";

const locationSchema = z.object({
    address: z.string().optional(),
    city: z.string().optional(),
    state: z.string().optional(),
    country: z.string().optional(),
    postalCode: z.string().optional(),
    latitude: z.coerce.number().optional(),
    longitude: z.coerce.number().optional(),
    timezone: z.string().optional(),
});

type LocationFormValues = z.infer<typeof locationSchema>;

const TIMEZONES = [
    { value: "America/Mexico_City", label: "Ciudad de México (UTC-6)" },
    { value: "America/Cancun", label: "Cancún (UTC-5)" },
    { value: "America/Tijuana", label: "Tijuana (UTC-8)" },
    { value: "America/Monterrey", label: "Monterrey (UTC-6)" },
    { value: "America/Chihuahua", label: "Chihuahua (UTC-7)" },
    { value: "UTC", label: "UTC (Universal)" },
];

export function RestaurantLocationSettings() {
    const { data: restaurant, isLoading } = useGetManagedRestaurantQuery();
    const { mutate: updateLocation, isPending: isSaving } =
        useUpdateRestaurantLocationMutation();

    const form = useForm<LocationFormValues>({
        resolver: zodResolver(locationSchema),
        defaultValues: {
            address: "",
            city: "",
            state: "",
            country: "",
            postalCode: "",
            latitude: undefined,
            longitude: undefined,
            timezone: "America/Mexico_City",
        },
    });

    useEffect(() => {
        if (restaurant) {
            form.reset({
                address: restaurant.address || "",
                city: restaurant.city || "",
                state: restaurant.state || "",
                country: restaurant.country || "",
                postalCode: restaurant.postalCode || "",
                latitude: restaurant.latitude || undefined,
                longitude: restaurant.longitude || undefined,
                timezone: restaurant.timezone || "America/Mexico_City",
            });
        }
    }, [restaurant, form]);

    function onSubmit(data: LocationFormValues) {
        updateLocation({
            address: data.address || null,
            city: data.city || null,
            state: data.state || null,
            country: data.country || null,
            postalCode: data.postalCode || null,
            latitude: data.latitude || null,
            longitude: data.longitude || null,
            timezone: data.timezone || "UTC",
        });
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
                <CardTitle>Ubicación del Restaurante</CardTitle>
                <CardDescription>
                    Dirección física y coordenadas geográficas
                </CardDescription>
            </CardHeader>
            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)}>
                    <CardContent className="space-y-4">
                        <FormField
                            control={form.control}
                            name="address"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Dirección Completa</FormLabel>
                                    <FormControl>
                                        <Input placeholder="Av. Insurgentes Sur 123" {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="city"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Ciudad</FormLabel>
                                        <FormControl>
                                            <Input placeholder="Ciudad de México" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="state"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Estado</FormLabel>
                                        <FormControl>
                                            <Input placeholder="CDMX" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="country"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>País</FormLabel>
                                        <FormControl>
                                            <Input placeholder="México" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="postalCode"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Código Postal</FormLabel>
                                        <FormControl>
                                            <Input placeholder="03100" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="latitude"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Latitud</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                step="0.000001"
                                                placeholder="19.432608"
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormDescription>
                                            Coordenada geográfica (decimal)
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="longitude"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Longitud</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                step="0.000001"
                                                placeholder="-99.133209"
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormDescription>
                                            Coordenada geográfica (decimal)
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="timezone"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Zona Horaria</FormLabel>
                                    <Select
                                        onValueChange={field.onChange}
                                        defaultValue={field.value}
                                    >
                                        <FormControl>
                                            <SelectTrigger>
                                                <SelectValue placeholder="Selecciona una zona horaria" />
                                            </SelectTrigger>
                                        </FormControl>
                                        <SelectContent>
                                            {TIMEZONES.map((tz) => (
                                                <SelectItem key={tz.value} value={tz.value}>
                                                    {tz.label}
                                                </SelectItem>
                                            ))}
                                        </SelectContent>
                                    </Select>
                                    <FormDescription>
                                        Zona horaria para cálculos de horarios
                                    </FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                    </CardContent>
                    <CardFooter className="flex justify-end border-t px-6 py-4">
                        <Button type="submit" disabled={isSaving}>
                            {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Guardar Ubicación
                        </Button>
                    </CardFooter>
                </form>
            </Form>
        </Card>
    );
}
