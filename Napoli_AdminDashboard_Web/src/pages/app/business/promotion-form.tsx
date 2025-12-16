import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { memo, useEffect } from "react";
import { DateRange } from "react-day-picker";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { ImageUploader } from "@/components/image-uploader";
import { Button } from "@/components/ui/button";
import { DateRangePicker } from "@/components/ui/date-range-picker";
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
import { MultiSelect } from "@/components/ui/multi-select";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { MarketingItem } from "@/core/models/promotion.model";

const promotionFormSchema = z
  .object({
    name: z.string().min(3, "El nombre es requerido."),
    description: z.string().optional(),
    type: z.string(),
    code: z.string().optional(),
    discount: z.coerce.number().optional(),
    products: z.array(z.string()),
    conditions: z.string().optional(), // Used for description in coupons or just metadata
    dateRange: z
      .object({
        from: z.date().optional(),
        to: z.date().optional(),
      })
      .optional(),
    image: z.instanceof(File).optional(),
  })
  .refine(
    (data) => {
      // Logic: If type is 'Cupón', code is required
      if (data.type === "Cupón" && (!data.code || data.code.length < 3)) {
        return false;
      }
      return true;
    },
    {
      message: "El código es requerido para los cupones (mín. 3 caracteres).",
      path: ["code"],
    },
  );

type PromotionFormValues = z.infer<typeof promotionFormSchema>;

interface PromotionFormProps {
  marketingItem: MarketingItem | null;
  onSubmit: (data: any) => void;
  onCancel: () => void;
  productOptions: { value: string; label: string }[];
  isSubmitting?: boolean;
}

function PromotionFormComponent({
  marketingItem,
  onSubmit,
  onCancel,
  productOptions,
  isSubmitting = false,
}: PromotionFormProps) {
  // Determine initial values based on marketingItem (which can be Promotion or Coupon)
  // We map them to a common form structure
  const defaultValues: Partial<PromotionFormValues> = {
    name: marketingItem?.name || "", // Name for Promo, Code for Coupon (but we split them in form)
    // Actually for Coupon, 'name' in Model is 'code'. But in UI form we want 'name' field to be distinct?
    // Wait, MarketingItem.name is mapped to 'code' for Coupons in usePromotions.ts.
    // Ideally we want a separate 'Description/Title' for coupon? Schema has 'description'.
    // Let's assume 'name' in form maps to 'code' if coupon, or we separate them.
    // BETTER: For Coupon, 'name' field in form -> 'code' field in DB? No, Coupon has 'code'.
    // Let's use 'name' field for 'code' if it is a coupon? Or show separate fields.

    // In schema: Coupons have 'code' and 'description'. No 'name'.
    // Promotions have 'name' and 'description'.

    // So if "Cupón" is selected:
    // - Name field -> Hidden or used as Code?
    // - Code field -> Required.

    // Let's keep it simple:
    // If Cupón: 'name' field is ignored or used as description?
    // Let's bind 'code' field to Coupon.code.
    // 'name' field... maybe we force user to enter a name for the promotion?
    // But Coupon doesn't have a name. It has Description.
    // So 'name' in form might be unused for Coupon?

    description: marketingItem?.description || "",
    type: marketingItem?.type || "Oferta Especial",
    // For coupon, name was mapped to code in hook.
    code: marketingItem?.kind === "coupon" ? marketingItem.name : "",
    discount:
      (marketingItem?.original as any)?.discountPercentage ||
      (marketingItem?.original as any)?.discountAmountCents ||
      undefined,
    // Products only for promotions. We don't have them in MarketingItem unified interface easily unless we fetch them or check original type.
    // Assuming standard list doesn't have products populated fully yet without extra fetch?
    // But assuming we might have them if we extended the hook. For now leave empty or try to map.
    products: [],
    conditions: "",
    dateRange: {
      from: marketingItem?.startDate
        ? new Date(marketingItem.startDate)
        : undefined,
      to: marketingItem?.endDate ? new Date(marketingItem.endDate) : undefined,
    } as DateRange,
  };

  // If it's a real update, we might need to handle name correctness.
  // if marketingItem.kind == 'promotion', name is name.
  if (marketingItem?.kind === "promotion") {
    defaultValues.name = marketingItem.name;
  } else if (marketingItem?.kind === "coupon") {
    // Coupon doesn't have a name column.
    // We can use the 'code' as the name in the form, or leave name empty.
    defaultValues.name = "";
    // But the schema requires 'name' (min 3).
    // If type is Cupón, maybe we don't require name? Or we mapped code to name.
  }

  const form = useForm<PromotionFormValues>({
    resolver: zodResolver(promotionFormSchema),
    defaultValues,
  });

  // Watch type to conditional render
  const type = form.watch("type");

  // If editing an existing item, set the type once.
  useEffect(() => {
    if (marketingItem) {
      form.setValue("type", marketingItem.type);
      if (marketingItem.kind === "coupon") {
        form.setValue("code", marketingItem.name);
        form.setValue("name", "CUPON-" + marketingItem.name); // Dummy name to pass validation
      }
    }
  }, [marketingItem, form]);

  function handleFormSubmit(data: PromotionFormValues) {
    // Determine kind
    const kind = data.type === "Cupón" ? "coupon" : "promotion";

    // Prepare data
    const submitData = {
      ...data,
      kind,
      // If coupon, name is ignored or mapped to description if needed, but we have description field.
      // Code is used for coupon.
    };

    onSubmit(submitData);
  }

  function generateCouponCode() {
    const code = Math.random().toString(36).substring(2, 10).toUpperCase();
    form.setValue("code", code);
  }

  function handleProductChange(selectedProducts: string[]) {
    form.setValue("products", selectedProducts);
  }

  function handleDateChange(dateRange: DateRange | undefined) {
    form.setValue("dateRange", dateRange);
  }

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(handleFormSubmit)}
        className="space-y-4"
      >
        {/* Only show Image for Promotions */}
        {type !== "Cupón" && (
          <FormField
            control={form.control}
            name="image"
            render={({ field }) => (
              <FormItem>
                <FormControl>
                  <ImageUploader
                    onFileSelected={(file) => field.onChange(file)}
                    initialImageUrl={marketingItem?.imageUrl || undefined}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
        )}

        {/* Name is required for Promotions. For Coupons we auto-generate or hide or make optional? 
            Schema validation says name min 3. 
            If Cupón, we can hide Name and auto-fill it to satisfy Zod, or use it as Description?
        */}
        {type !== "Cupón" && (
          <FormField
            control={form.control}
            name="name"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Nombre de la Promoción</FormLabel>
                <FormControl>
                  <Input {...field} placeholder="Ej. Martes 2x1" />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
        )}

        <FormField
          control={form.control}
          name="description"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Descripción</FormLabel>
              <FormControl>
                <Input
                  {...field}
                  placeholder="Detalles visibles para el cliente"
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="type"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Tipo</FormLabel>
              <Select
                onValueChange={(val) => {
                  field.onChange(val);
                  // If switching to Coupon, ensure name is valid if hidden
                  if (val === "Cupón") {
                    form.setValue("name", "CUPON-GENERICO");
                  } else if (form.getValues("name") === "CUPON-GENERICO") {
                    form.setValue("name", "");
                  }
                }}
                defaultValue={field.value}
                disabled={!!marketingItem} // Disable changing type when editing to avoid schema mismatch issues
              >
                <FormControl>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectItem value="Oferta Especial">
                    Oferta Especial
                  </SelectItem>
                  <SelectItem value="Combo">Combo</SelectItem>
                  <SelectItem value="Descuento">Descuento</SelectItem>
                  <SelectItem value="Cupón">Cupón de Descuento</SelectItem>
                </SelectContent>
              </Select>
              {marketingItem && (
                <FormDescription>
                  El tipo no se puede cambiar al editar.
                </FormDescription>
              )}
              <FormMessage />
            </FormItem>
          )}
        />

        {type === "Cupón" && (
          <FormField
            control={form.control}
            name="code"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Código del Cupón</FormLabel>
                <div className="flex items-center gap-2">
                  <FormControl>
                    <Input
                      {...field}
                      placeholder="Ej. VERANO2025"
                      className="font-mono uppercase"
                    />
                  </FormControl>
                  <Button
                    type="button"
                    variant="secondary"
                    onClick={generateCouponCode}
                  >
                    Generar
                  </Button>
                </div>
                <FormMessage />
              </FormItem>
            )}
          />
        )}

        {/* Discount Field - simplified to single number for now */}
        <FormField
          control={form.control}
          name="discount"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Descuento (%)</FormLabel>
              <FormControl>
                <Input type="number" {...field} placeholder="Ej. 15" />
              </FormControl>
              <FormDescription>
                Porcentaje de descuento aplicable.
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Products only for Promotions (not coupons) */}
        {type !== "Cupón" && (
          <FormField
            control={form.control}
            name="products"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Productos Aplicables</FormLabel>
                <FormControl>
                  <MultiSelect
                    options={productOptions}
                    selected={field.value}
                    onChange={handleProductChange}
                    placeholder="Seleccionar productos..."
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
        )}

        <FormField
          control={form.control}
          name="dateRange"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Vigencia</FormLabel>
              <FormControl>
                <DateRangePicker
                  date={field.value as DateRange | undefined}
                  onDateChange={handleDateChange}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <div className="flex justify-end gap-2 pt-4">
          <Button
            type="button"
            variant="ghost"
            onClick={onCancel}
            disabled={isSubmitting}
          >
            Cancelar
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            Guardar
          </Button>
        </div>
      </form>
    </Form>
  );
}

export const PromotionForm = memo(PromotionFormComponent);
