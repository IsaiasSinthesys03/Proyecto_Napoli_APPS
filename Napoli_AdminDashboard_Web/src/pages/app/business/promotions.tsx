import { Loader2, Plus } from "lucide-react";
import { useState } from "react";
import { Helmet } from "react-helmet-async";

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
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useProducts } from "@/core/hooks/useProducts";
import {
  useCreateCoupon,
  useCreatePromotion,
  useDeleteCoupon,
  useDeletePromotion,
  useMarketingData,
  useToggleCouponStatus,
  useTogglePromotionStatus,
  useUpdateCoupon,
  useUpdatePromotion,
} from "@/core/hooks/usePromotions";
import { MarketingItem } from "@/core/models/promotion.model";

import { PromotionForm } from "./promotion-form";

export function Promotions() {
  const { data: marketingData, isLoading } = useMarketingData();
  const { data: productsData } = useProducts(); // Correct hook name

  const createPromotion = useCreatePromotion();
  const updatePromotion = useUpdatePromotion();
  const deletePromotion = useDeletePromotion();
  const togglePromotion = useTogglePromotionStatus();

  const createCoupon = useCreateCoupon();
  const updateCoupon = useUpdateCoupon();
  const deleteCoupon = useDeleteCoupon();
  const toggleCoupon = useToggleCouponStatus();

  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<MarketingItem | null>(null);
  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState("all");
  const [page, setPage] = useState(1);
  const itemsPerPage = 10;

  const filteredItems = (marketingData || [])
    .filter((item) => item.name.toLowerCase().includes(search.toLowerCase()))
    .filter(
      (item) =>
        typeFilter === "all" ||
        item.type === typeFilter ||
        (typeFilter === "Cupón" && item.kind === "coupon"),
    );

  const paginatedItems = filteredItems.slice(
    (page - 1) * itemsPerPage,
    page * itemsPerPage,
  );

  async function handleFormSubmit(data: any) {
    try {
      if (data.kind === "coupon") {
        // Handle Coupon
        const payload = {
          code: data.code,
          description: data.description,
          type: "percentage",
          discountPercentage: data.discount,
          validFrom: data.dateRange?.from,
          validUntil: data.dateRange?.to,
          isActive: true,
        };

        if (editingItem && editingItem.kind === "coupon") {
          await updateCoupon.mutateAsync({
            ...payload,
            id: editingItem.id,
          } as any);
        } else {
          await createCoupon.mutateAsync(payload as any);
        }
      } else {
        // Handle Promotion
        const payload = {
          name: data.name,
          description: data.description,
          type: data.type,
          discountPercentage: data.discount,
          startDate: data.dateRange?.from,
          endDate: data.dateRange?.to,
          isActive: true,
        };

        if (editingItem && editingItem.kind === "promotion") {
          await updatePromotion.mutateAsync({
            payload: { ...payload, id: editingItem.id } as any,
            image: data.image,
          });
        } else {
          await createPromotion.mutateAsync({
            payload: payload as any,
            image: data.image,
          });
        }
      }
      setIsDialogOpen(false);
      setEditingItem(null);
    } catch (error) {
      console.error("Error saving marketing item", error);
    }
  }

  function handleDelete(item: MarketingItem) {
    if (item.kind === "promotion") {
      deletePromotion.mutate(item.id);
    } else {
      deleteCoupon.mutate(item.id);
    }
  }

  function handleStatusChange(item: MarketingItem, checked: boolean) {
    if (item.kind === "promotion") {
      togglePromotion.mutate({ id: item.id, isActive: checked });
    } else {
      toggleCoupon.mutate({ id: item.id, isActive: checked });
    }
  }

  const productOptions = (productsData || []).map((p: any) => ({
    value: p.id,
    label: p.name,
  }));

  return (
    <>
      <Helmet title="Promociones" />
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold tracking-tight">
            Gestión de Promociones y Cupones
          </h1>
          <Dialog
            open={isDialogOpen}
            onOpenChange={(open) => {
              if (!open) setEditingItem(null);
              setIsDialogOpen(open);
            }}
          >
            <DialogTrigger asChild>
              <Button onClick={() => setEditingItem(null)}>
                <Plus className="mr-2 h-4 w-4" />
                Crear Nuevo
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[625px]">
              <DialogHeader>
                <DialogTitle>
                  {editingItem ? "Editar" : "Crear"} Promoción o Cupón
                </DialogTitle>
              </DialogHeader>
              <PromotionForm
                marketingItem={editingItem}
                onSubmit={handleFormSubmit}
                onCancel={() => setIsDialogOpen(false)}
                productOptions={productOptions}
                isSubmitting={
                  createPromotion.isPending ||
                  updatePromotion.isPending ||
                  createCoupon.isPending ||
                  updateCoupon.isPending
                }
              />
            </DialogContent>
          </Dialog>
        </div>
        <div className="flex items-center gap-2">
          <Input
            placeholder="Buscar..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          <Select value={typeFilter} onValueChange={setTypeFilter}>
            <SelectTrigger className="w-[180px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Todos</SelectItem>
              <SelectItem value="percentage">Porcentaje</SelectItem>
              <SelectItem value="fixed">Monto Fijo</SelectItem>
              <SelectItem value="Cupón">Cupón</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-24">Imagen</TableHead>
                <TableHead>Nombre / Código</TableHead>
                <TableHead>Tipo</TableHead>
                <TableHead>Descripción</TableHead>
                <TableHead>Vigencia</TableHead>
                <TableHead>Estado</TableHead>
                <TableHead>Acciones</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={7} className="h-24 text-center">
                    <Loader2 className="mx-auto h-6 w-6 animate-spin" />
                  </TableCell>
                </TableRow>
              ) : paginatedItems.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="h-24 text-center">
                    No se encontraron resultados
                  </TableCell>
                </TableRow>
              ) : (
                paginatedItems.map((item) => (
                  <TableRow key={item.id}>
                    <TableCell>
                      {item.imageUrl ? (
                        <img
                          src={item.imageUrl}
                          alt={item.name}
                          className="h-10 w-10 rounded-md object-cover"
                        />
                      ) : (
                        <div className="flex h-10 w-10 items-center justify-center rounded-md bg-muted text-xs text-muted-foreground">
                          {item.kind === "coupon" ? "Cupón" : "N/A"}
                        </div>
                      )}
                    </TableCell>
                    <TableCell className="font-medium">{item.name}</TableCell>
                    <TableCell className="capitalize">
                      {item.type || item.kind}
                    </TableCell>
                    <TableCell
                      className="max-w-[200px] truncate"
                      title={item.description || ""}
                    >
                      {item.description || "-"}
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-col text-xs">
                        {item.startDate ? (
                          <span>
                            Desde:{" "}
                            {new Date(item.startDate).toLocaleDateString()}
                          </span>
                        ) : null}
                        {item.endDate ? (
                          <span>
                            Hasta: {new Date(item.endDate).toLocaleDateString()}
                          </span>
                        ) : null}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Switch
                        checked={item.isActive}
                        onCheckedChange={(checked) =>
                          handleStatusChange(item, checked)
                        }
                      />
                    </TableCell>
                    <TableCell>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => {
                          setEditingItem(item);
                          setIsDialogOpen(true);
                        }}
                      >
                        Editar
                      </Button>
                      <AlertDialog>
                        <AlertDialogTrigger asChild>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-destructive hover:text-destructive"
                          >
                            Eliminar
                          </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                          <AlertDialogHeader>
                            <AlertDialogTitle>¿Estás seguro?</AlertDialogTitle>
                            <AlertDialogDescription>
                              Esta acción no se puede deshacer.
                            </AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel>Cancelar</AlertDialogCancel>
                            <AlertDialogAction
                              onClick={() => handleDelete(item)}
                              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                            >
                              Eliminar
                            </AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
        <Pagination
          pageIndex={page - 1}
          totalCount={filteredItems.length}
          perPage={itemsPerPage}
          onPageChange={(page) => setPage(page + 1)}
        />
      </div>
    </>
  );
}
