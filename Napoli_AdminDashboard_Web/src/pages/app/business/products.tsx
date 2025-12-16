import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { Helmet } from "react-helmet-async";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { ImageUploader } from "@/components/image-uploader";
import { Pagination } from "@/components/pagination";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Form,
  FormControl,
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
import { Skeleton } from "@/components/ui/skeleton";
import { Switch } from "@/components/ui/switch";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Textarea } from "@/components/ui/textarea";
import { useCategories } from "@/core/hooks/useCategories";
import {
  useCreateProduct,
  useDeleteProduct,
  useProducts,
  useToggleProductAvailability,
  useUpdateProduct,
} from "@/core/hooks/useProducts";
import { Product } from "@/core/models/product.model";

const productFormSchema = z.object({
  name: z.string().min(3, "El nombre debe tener al menos 3 caracteres."),
  description: z.string().optional(),
  priceCents: z.coerce
    .number()
    .min(0, "El precio debe ser un número positivo."),
  categoryId: z.string().optional(),
  image: z.instanceof(File).optional(),
  isFeatured: z.boolean().optional(),
  preparationTimeMinutes: z.coerce.number().optional(),
});

type ProductFormValues = z.infer<typeof productFormSchema>;

export function Products() {
  const { data: products, isLoading, isError } = useProducts();
  const { data: categories } = useCategories();

  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [search, setSearch] = useState("");
  const [availabilityFilter, setAvailabilityFilter] = useState("all");
  const [page, setPage] = useState(1);
  const productsPerPage = 10;

  const createProductMutation = useCreateProduct();
  const updateProductMutation = useUpdateProduct();
  const deleteProductMutation = useDeleteProduct();
  const toggleAvailabilityMutation = useToggleProductAvailability();

  const filteredProducts = (products || [])
    .filter((p) => p.name.toLowerCase().includes(search.toLowerCase()))
    .filter(
      (p) =>
        availabilityFilter === "all" ||
        (availabilityFilter === "available" && p.isAvailable) ||
        (availabilityFilter === "unavailable" && !p.isAvailable),
    );

  const paginatedProducts = filteredProducts.slice(
    (page - 1) * productsPerPage,
    page * productsPerPage,
  );

  async function handleProductSubmit(data: ProductFormValues) {
    if (editingProduct) {
      await updateProductMutation.mutateAsync({
        payload: {
          id: editingProduct.id,
          name: data.name,
          description: data.description,
          priceCents: data.priceCents,
          categoryId: data.categoryId,
          isFeatured: data.isFeatured,
          preparationTimeMinutes: data.preparationTimeMinutes,
        },
        image: data.image,
      });
    } else {
      await createProductMutation.mutateAsync({
        payload: {
          name: data.name,
          description: data.description,
          priceCents: data.priceCents,
          categoryId: data.categoryId,
          isFeatured: data.isFeatured,
          preparationTimeMinutes: data.preparationTimeMinutes,
        },
        image: data.image,
      });
    }
    setEditingProduct(null);
    setIsDialogOpen(false);
  }

  async function handleDeleteProduct(id: string) {
    await deleteProductMutation.mutateAsync(id);
  }

  async function handleAvailabilityChange(id: string, isAvailable: boolean) {
    await toggleAvailabilityMutation.mutateAsync({ id, isAvailable });
  }

  return (
    <>
      <Helmet title="Productos" />
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold tracking-tight">
            Gestión de Productos
          </h1>
          <Dialog
            open={isDialogOpen}
            onOpenChange={(open) => {
              if (!open) setEditingProduct(null);
              setIsDialogOpen(open);
            }}
          >
            <DialogTrigger asChild>
              <Button onClick={() => setEditingProduct(null)}>
                Crear Producto
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>
                  {editingProduct ? "Editar Producto" : "Crear Producto"}
                </DialogTitle>
              </DialogHeader>
              <ProductForm
                key={editingProduct?.id || "new"}
                product={editingProduct}
                onSubmit={handleProductSubmit}
                onCancel={() => setIsDialogOpen(false)}
                categories={categories || []}
                isSubmitting={
                  createProductMutation.isPending ||
                  updateProductMutation.isPending
                }
              />
            </DialogContent>
          </Dialog>
        </div>
        <div className="flex items-center gap-2">
          <Input
            placeholder="Buscar productos..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="max-w-sm"
          />
          <Select
            value={availabilityFilter}
            onValueChange={setAvailabilityFilter}
          >
            <SelectTrigger className="w-[180px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Todos</SelectItem>
              <SelectItem value="available">Disponibles</SelectItem>
              <SelectItem value="unavailable">No Disponibles</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-24">Imagen</TableHead>
                <TableHead>Nombre</TableHead>
                <TableHead>Categoría</TableHead>
                <TableHead>Precio</TableHead>
                <TableHead>Disponibilidad</TableHead>
                <TableHead>Acciones</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading && (
                <>
                  {[...Array(5)].map((_, i) => (
                    <TableRow key={i}>
                      <TableCell>
                        <Skeleton className="h-16 w-16 rounded-md" />
                      </TableCell>
                      <TableCell>
                        <Skeleton className="h-4 w-32" />
                      </TableCell>
                      <TableCell>
                        <Skeleton className="h-4 w-24" />
                      </TableCell>
                      <TableCell>
                        <Skeleton className="h-4 w-20" />
                      </TableCell>
                      <TableCell>
                        <Skeleton className="h-8 w-12" />
                      </TableCell>
                      <TableCell>
                        <Skeleton className="h-8 w-24" />
                      </TableCell>
                    </TableRow>
                  ))}
                </>
              )}
              {isError && (
                <TableRow>
                  <TableCell colSpan={6} className="text-center text-red-500">
                    Error al cargar los productos.
                  </TableCell>
                </TableRow>
              )}
              {paginatedProducts?.map((product) => (
                <TableRow key={product.id}>
                  <TableCell>
                    {product.imageUrl && (
                      <img
                        src={product.imageUrl}
                        alt={product.name}
                        className="h-16 w-16 rounded-md object-cover"
                      />
                    )}
                  </TableCell>
                  <TableCell>
                    <div className="font-medium">{product.name}</div>
                    {product.isFeatured && (
                      <span className="text-xs text-yellow-600">
                        ★ Destacado
                      </span>
                    )}
                  </TableCell>
                  <TableCell>{product.category?.name || "-"}</TableCell>
                  <TableCell>
                    ${(product.priceCents / 100).toFixed(2)}
                  </TableCell>
                  <TableCell>
                    <Switch
                      checked={product.isAvailable}
                      onCheckedChange={(checked) =>
                        handleAvailabilityChange(product.id, checked)
                      }
                    />
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="outline"
                      size="sm"
                      className="mr-2"
                      onClick={() => {
                        setEditingProduct(product);
                        setIsDialogOpen(true);
                      }}
                    >
                      Editar
                    </Button>
                    <AlertDialog>
                      <AlertDialogTrigger asChild>
                        <Button variant="destructive" size="sm">
                          Eliminar
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle>¿Estás seguro?</AlertDialogTitle>
                          <AlertDialogDescription>
                            Esta acción no se puede deshacer. El producto se
                            eliminará permanentemente.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>Cancelar</AlertDialogCancel>
                          <AlertDialogAction
                            onClick={() => handleDeleteProduct(product.id)}
                          >
                            Eliminar
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
        {filteredProducts && (
          <Pagination
            pageIndex={page - 1}
            totalCount={filteredProducts.length}
            perPage={productsPerPage}
            onPageChange={(page) => setPage(page + 1)}
          />
        )}
      </div>
    </>
  );
}

interface ProductFormProps {
  product: Product | null;
  onSubmit: (data: ProductFormValues) => void;
  onCancel: () => void;
  categories: { id: string; name: string }[];
  isSubmitting: boolean;
}

function ProductForm({
  product,
  onSubmit,
  onCancel,
  categories,
  isSubmitting,
}: ProductFormProps) {
  const form = useForm<ProductFormValues>({
    resolver: zodResolver(productFormSchema),
    defaultValues: {
      name: product?.name || "",
      description: product?.description || "",
      priceCents: product?.priceCents || 0,
      categoryId: product?.categoryId || "",
      isFeatured: product?.isFeatured || false,
      preparationTimeMinutes: product?.preparationTimeMinutes ?? 0,
    },
  });

  function handleFormSubmit(data: ProductFormValues) {
    onSubmit(data);
  }

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(handleFormSubmit)}
        className="space-y-4"
      >
        <FormField
          control={form.control}
          name="image"
          render={({ field }) => (
            <FormItem>
              <FormControl>
                <ImageUploader
                  onFileSelected={(file) => field.onChange(file)}
                  initialImageUrl={product?.imageUrl || undefined}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Nombre</FormLabel>
              <FormControl>
                <Input {...field} disabled={isSubmitting} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="description"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Descripción</FormLabel>
              <FormControl>
                <Textarea {...field} disabled={isSubmitting} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <div className="grid grid-cols-2 gap-4">
          <FormField
            control={form.control}
            name="priceCents"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Precio (centavos)</FormLabel>
                <FormControl>
                  <Input type="number" {...field} disabled={isSubmitting} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="categoryId"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Categoría</FormLabel>
                <Select onValueChange={field.onChange} value={field.value}>
                  <FormControl>
                    <SelectTrigger>
                      <SelectValue placeholder="Seleccionar categoría..." />
                    </SelectTrigger>
                  </FormControl>
                  <SelectContent>
                    {categories.map((cat) => (
                      <SelectItem key={cat.id} value={cat.id}>
                        {cat.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <FormMessage />
              </FormItem>
            )}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <FormField
            control={form.control}
            name="preparationTimeMinutes"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Tiempo de preparación (min)</FormLabel>
                <FormControl>
                  <Input type="number" {...field} disabled={isSubmitting} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="isFeatured"
            render={({ field }) => (
              <FormItem className="flex items-center gap-2 pt-6">
                <FormControl>
                  <Switch
                    checked={field.value}
                    onCheckedChange={field.onChange}
                    disabled={isSubmitting}
                  />
                </FormControl>
                <FormLabel className="!mt-0">Producto destacado</FormLabel>
              </FormItem>
            )}
          />
        </div>

        <div className="flex justify-end gap-2">
          <Button
            type="button"
            variant="ghost"
            onClick={onCancel}
            disabled={isSubmitting}
          >
            Cancelar
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? "Guardando..." : "Guardar"}
          </Button>
        </div>
      </form>
    </Form>
  );
}
