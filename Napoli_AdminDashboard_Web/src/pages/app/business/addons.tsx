import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { Helmet } from "react-helmet-async";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
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
import { MultiSelect } from "@/components/ui/multi-select";
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
import {
  useAddons,
  useCreateAddon,
  useDeleteAddon,
  useUpdateAddon,
} from "@/core/hooks/useAddons";
import { useCategories } from "@/core/hooks/useCategories";
import { Addon } from "@/core/models/addon.model";

const addonFormSchema = z.object({
  name: z.string().min(3, "El nombre debe tener al menos 3 caracteres."),
  priceCents: z.coerce
    .number()
    .min(0, "El precio debe ser un número positivo."),
  categoryIds: z.array(z.string()).optional(),
  image: z.instanceof(File).optional(),
});

type AddonFormValues = z.infer<typeof addonFormSchema>;

export function Addons() {
  const { data: addons, isLoading, isError } = useAddons();
  const { data: categories } = useCategories();

  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingAddon, setEditingAddon] = useState<Addon | null>(null);
  const [search, setSearch] = useState("");
  const [availabilityFilter, setAvailabilityFilter] = useState("all");
  const [page, setPage] = useState(1);
  const addonsPerPage = 10;

  const createAddonMutation = useCreateAddon();
  const updateAddonMutation = useUpdateAddon();
  const deleteAddonMutation = useDeleteAddon();

  const filteredAddons = addons
    ?.filter((a) => a.name.toLowerCase().includes(search.toLowerCase()))
    .filter(
      (a) =>
        availabilityFilter === "all" ||
        (availabilityFilter === "available" && a.isAvailable) ||
        (availabilityFilter === "unavailable" && !a.isAvailable),
    );

  const paginatedAddons = filteredAddons?.slice(
    (page - 1) * addonsPerPage,
    page * addonsPerPage,
  );

  async function handleAddonSubmit(data: AddonFormValues) {
    try {
      if (editingAddon) {
        await updateAddonMutation.mutateAsync({
          id: editingAddon.id,
          ...data,
        });
        toast.success("Complemento actualizado con éxito.");
      } else {
        await createAddonMutation.mutateAsync(data);
        toast.success("Complemento creado con éxito.");
      }
      setEditingAddon(null);
      setIsDialogOpen(false);
    } catch (error) {
      toast.error("Error al guardar el complemento.");
    }
  }

  async function handleDeleteAddon(id: string) {
    try {
      await deleteAddonMutation.mutateAsync(id);
      toast.success("Complemento eliminado con éxito.");
    } catch (error) {
      toast.error("Error al eliminar el complemento.");
    }
  }

  async function handleAvailabilityChange(id: string, isAvailable: boolean) {
    try {
      await updateAddonMutation.mutateAsync({ id, isAvailable });
      toast.success("Disponibilidad actualizada.");
    } catch (error) {
      toast.error("Error al actualizar la disponibilidad.");
    }
  }

  return (
    <>
      <Helmet title="Complementos" />
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold tracking-tight">
            Gestión de Complementos
          </h1>
          <Dialog
            open={isDialogOpen}
            onOpenChange={(open) => {
              if (!open) setEditingAddon(null);
              setIsDialogOpen(open);
            }}
          >
            <DialogTrigger asChild>
              <Button onClick={() => setEditingAddon(null)}>
                Crear Complemento
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>
                  {editingAddon ? "Editar Complemento" : "Crear Complemento"}
                </DialogTitle>
              </DialogHeader>
              <AddonForm
                key={editingAddon?.id || "new"}
                addon={editingAddon}
                onSubmit={handleAddonSubmit}
                onCancel={() => setIsDialogOpen(false)}
                categories={categories || []}
                isSubmitting={
                  createAddonMutation.isPending || updateAddonMutation.isPending
                }
              />
            </DialogContent>
          </Dialog>
        </div>
        <div className="flex items-center gap-2">
          <Input
            placeholder="Buscar complementos..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
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
                        <Skeleton className="h-8 w-20" />
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
                  <TableCell colSpan={5} className="text-center text-red-500">
                    Error al cargar los complementos.
                  </TableCell>
                </TableRow>
              )}
              {paginatedAddons?.map((addon) => (
                <TableRow key={addon.id}>
                  <TableCell>
                    {addon.imageUrl && (
                      <img
                        src={addon.imageUrl}
                        alt={addon.name}
                        className="h-16 w-16 rounded-md object-cover"
                      />
                    )}
                  </TableCell>
                  <TableCell>{addon.name}</TableCell>
                  <TableCell>${(addon.priceCents / 100).toFixed(2)}</TableCell>
                  <TableCell>
                    <Switch
                      checked={addon.isAvailable}
                      onCheckedChange={(checked) =>
                        handleAvailabilityChange(addon.id, checked)
                      }
                    />
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="outline"
                      size="sm"
                      className="mr-2"
                      onClick={() => {
                        setEditingAddon(addon);
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
                            Esta acción no se puede deshacer. El complemento se
                            eliminará permanentemente.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>Cancelar</AlertDialogCancel>
                          <AlertDialogAction
                            onClick={() => handleDeleteAddon(addon.id)}
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
        {filteredAddons && (
          <Pagination
            pageIndex={page - 1}
            totalCount={filteredAddons.length}
            perPage={addonsPerPage}
            onPageChange={(page) => setPage(page + 1)}
          />
        )}
      </div>
    </>
  );
}

interface AddonFormProps {
  addon: Addon | null;
  onSubmit: (data: AddonFormValues) => void;
  onCancel: () => void;
  categories: { id: string; name: string }[];
  isSubmitting: boolean;
}

function AddonForm({
  addon,
  onSubmit,
  onCancel,
  categories,
  isSubmitting,
}: AddonFormProps) {
  const form = useForm<AddonFormValues>({
    resolver: zodResolver(addonFormSchema),
    defaultValues: {
      name: addon?.name || "",
      priceCents: addon?.priceCents || 0,
      categoryIds: [],
    },
  });

  function handleFormSubmit(data: AddonFormValues) {
    onSubmit(data);
  }

  const categoryOptions = categories.map((c) => ({
    value: c.id,
    label: c.name,
  }));

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
                  initialImageUrl={addon?.imageUrl}
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
          name="priceCents"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Precio (en centavos)</FormLabel>
              <FormControl>
                <Input type="number" {...field} disabled={isSubmitting} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="categoryIds"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Categorías</FormLabel>
              <MultiSelect
                options={categoryOptions}
                value={field.value}
                onChange={field.onChange}
                placeholder="Selecciona categorías..."
              />
              <FormMessage />
            </FormItem>
          )}
        />

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
