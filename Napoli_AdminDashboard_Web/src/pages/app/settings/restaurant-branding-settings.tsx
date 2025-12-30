import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { ImageUploader } from "@/components/image-uploader";
import { Button } from "@/components/ui/button";
import {
    Card,
    CardContent,
    CardDescription,
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
    useGetManagedRestaurantQuery,
    useUpdateRestaurantBrandingMutation,
    useUploadRestaurantLogoMutation,
    useUploadRestaurantBannerMutation,
} from "@/core/hooks/useRestaurant";

const brandingSchema = z.object({
    primaryColor: z
        .string()
        .regex(/^#[0-9A-F]{6}$/i, "Color inválido (formato: #RRGGBB)")
        .optional()
        .or(z.literal("")),
    secondaryColor: z
        .string()
        .regex(/^#[0-9A-F]{6}$/i, "Color inválido (formato: #RRGGBB)")
        .optional()
        .or(z.literal("")),
});

type BrandingFormValues = z.infer<typeof brandingSchema>;

export function RestaurantBrandingSettings() {
    const { data: restaurant, isLoading } = useGetManagedRestaurantQuery();
    const { mutate: updateBranding, isPending: isSaving } =
        useUpdateRestaurantBrandingMutation();
    const { mutateAsync: uploadLogo, isPending: isUploadingLogo } =
        useUploadRestaurantLogoMutation();
    const { mutateAsync: uploadBanner, isPending: isUploadingBanner } =
        useUploadRestaurantBannerMutation();

    const [logoUrl, setLogoUrl] = useState<string | null>(null);
    const [bannerUrl, setBannerUrl] = useState<string | null>(null);

    const form = useForm<BrandingFormValues>({
        resolver: zodResolver(brandingSchema),
        defaultValues: {
            primaryColor: "",
            secondaryColor: "",
        },
    });

    useEffect(() => {
        if (restaurant) {
            form.reset({
                primaryColor: restaurant.primaryColor || "",
                secondaryColor: restaurant.secondaryColor || "",
            });
            setLogoUrl(restaurant.logoUrl);
            setBannerUrl(restaurant.bannerUrl);
        }
    }, [restaurant, form]);

    async function handleLogoUpload(file: File | null) {
        if (!file) return;
        const url = await uploadLogo(file);
        setLogoUrl(url);
        await updateBranding({ logoUrl: url });
    }

    async function handleBannerUpload(file: File | null) {
        if (!file) return;
        const url = await uploadBanner(file);
        setBannerUrl(url);
        await updateBranding({ bannerUrl: url });
    }

    function onSubmit(data: BrandingFormValues) {
        updateBranding({
            primaryColor: data.primaryColor || null,
            secondaryColor: data.secondaryColor || null,
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
                <CardTitle>Marca e Identidad Visual</CardTitle>
                <CardDescription>
                    Personaliza el logo, banner y colores de tu restaurante
                </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
                {/* Logo */}
                <div className="space-y-2">
                    <label className="text-sm font-medium">Logo del Restaurante</label>
                    <ImageUploader
                        onFileSelected={handleLogoUpload}
                        initialImageUrl={logoUrl}
                        disabled={isUploadingLogo}
                    />
                    <p className="text-sm text-muted-foreground">
                        Recomendado: 512x512px, formato PNG o SVG
                    </p>
                </div>

                {/* Banner */}
                <div className="space-y-2">
                    <label className="text-sm font-medium">Banner / Portada</label>
                    <ImageUploader
                        onFileSelected={handleBannerUpload}
                        initialImageUrl={bannerUrl}
                        disabled={isUploadingBanner}
                    />
                    <p className="text-sm text-muted-foreground">
                        Recomendado: 1920x400px, formato JPG o PNG
                    </p>
                </div>

                {/* Colors */}
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="primaryColor"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Color Primario</FormLabel>
                                        <div className="flex gap-2">
                                            <FormControl>
                                                <Input
                                                    type="color"
                                                    className="h-10 w-20"
                                                    {...field}
                                                />
                                            </FormControl>
                                            <FormControl>
                                                <Input
                                                    placeholder="#E63946"
                                                    {...field}
                                                    className="flex-1"
                                                />
                                            </FormControl>
                                        </div>
                                        <FormDescription>
                                            Color principal de tu marca
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="secondaryColor"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Color Secundario</FormLabel>
                                        <div className="flex gap-2">
                                            <FormControl>
                                                <Input
                                                    type="color"
                                                    className="h-10 w-20"
                                                    {...field}
                                                />
                                            </FormControl>
                                            <FormControl>
                                                <Input
                                                    placeholder="#457B9D"
                                                    {...field}
                                                    className="flex-1"
                                                />
                                            </FormControl>
                                        </div>
                                        <FormDescription>Color complementario</FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className="flex justify-end pt-4">
                            <Button type="submit" disabled={isSaving}>
                                {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                Guardar Colores
                            </Button>
                        </div>
                    </form>
                </Form>
            </CardContent>
        </Card>
    );
}
