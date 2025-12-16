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
import { Label } from "@/components/ui/label";
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
import {
  useCreateDeliveryManMutation,
  useDeleteDeliveryManMutation,
  useGetDeliveryMenQuery,
  useToggleDeliveryManStatusMutation,
  useUpdateDeliveryManMutation,
} from "@/core/hooks/useDelivery";
import { Driver, VehicleType } from "@/core/models/delivery.model";

export function DeliveryMen() {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingDeliveryMan, setEditingDeliveryMan] = useState<Driver | null>(
    null,
  );
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [page, setPage] = useState(1);
  const deliveryMenPerPage = 10;

  const { data: deliveryMenData, isLoading: isLoadingDeliveryMen } =
    useGetDeliveryMenQuery();
  const { mutateAsync: createDeliveryManFn } = useCreateDeliveryManMutation();
  const { mutateAsync: updateDeliveryManFn } = useUpdateDeliveryManMutation();
  const { mutateAsync: deleteDeliveryManFn } = useDeleteDeliveryManMutation();
  const { mutateAsync: toggleDeliveryManStatusFn } =
    useToggleDeliveryManStatusMutation();

  const deliveryMen = deliveryMenData?.deliveryMen ?? [];

  const filteredDeliveryMen = deliveryMen
    .filter((deliveryMan) =>
      deliveryMan.name.toLowerCase().includes(searchTerm.toLowerCase()),
    )
    .filter(
      (deliveryMan) =>
        statusFilter === "all" ||
        (statusFilter === "active" && deliveryMan.status === "active") ||
        (statusFilter === "inactive" && deliveryMan.status === "inactive"),
    );

  const paginatedDeliveryMen = filteredDeliveryMen.slice(
    (page - 1) * deliveryMenPerPage,
    page * deliveryMenPerPage,
  );

  interface DeliveryManFormData {
    name: string;
    phone: string;
    email: string;
    vehicleType: string;
  }

  async function handleCreateOrUpdateDeliveryMan(data: DeliveryManFormData) {
    const payload = {
      name: data.name,
      phone: data.phone,
      email: data.email,
      vehicleType: (data.vehicleType || "moto") as VehicleType,
    };

    if (editingDeliveryMan) {
      await updateDeliveryManFn({
        id: editingDeliveryMan.id,
        payload,
      });
    } else {
      await createDeliveryManFn(payload);
    }

    setEditingDeliveryMan(null);
    setIsDialogOpen(false);
  }

  async function handleDeleteDeliveryMan(id: string) {
    await deleteDeliveryManFn(id);
  }

  async function handleToggleStatus(id: string, checked: boolean) {
    const newStatus = checked ? "active" : "inactive";
    await toggleDeliveryManStatusFn({ id, status: newStatus });
  }

  if (isLoadingDeliveryMen) {
    return (
      <div className="space-y-4">
        <div className="h-10 w-64 animate-pulse rounded-md bg-muted" />
        <div className="rounded-md border">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="flex items-center gap-4 border-b p-4">
              <div className="h-16 w-16 animate-pulse rounded-md bg-muted" />
              <div className="h-4 w-32 animate-pulse rounded bg-muted" />
              <div className="h-4 w-24 animate-pulse rounded bg-muted" />
              <div className="h-6 w-12 animate-pulse rounded-full bg-muted" />
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <>
      <Helmet title="Gestión de repartidores" />
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold tracking-tight">
            Gestión de repartidores
          </h1>
          <Dialog
            open={isDialogOpen}
            onOpenChange={(open) => {
              if (!open) setEditingDeliveryMan(null);
              setIsDialogOpen(open);
            }}
          >
            <DialogTrigger asChild>
              <Button onClick={() => setEditingDeliveryMan(null)}>
                Agregar Repartidor
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>
                  {editingDeliveryMan
                    ? "Editar Repartidor"
                    : "Agregar Repartidor"}
                </DialogTitle>
              </DialogHeader>
              <div className="space-y-4 py-4">
                <div className="space-y-2">
                  <Label htmlFor="driver-name">Nombre</Label>
                  <Input
                    id="driver-name"
                    placeholder="Nombre del repartidor"
                    defaultValue={editingDeliveryMan?.name || ""}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="driver-email">Email</Label>
                  <Input
                    id="driver-email"
                    type="email"
                    placeholder="correo@ejemplo.com"
                    defaultValue={editingDeliveryMan?.email || ""}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="driver-phone">Teléfono</Label>
                  <Input
                    id="driver-phone"
                    placeholder="Teléfono"
                    defaultValue={editingDeliveryMan?.phone || ""}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="driver-vehicle">Tipo de Vehículo</Label>
                  <select
                    id="driver-vehicle"
                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                    defaultValue={editingDeliveryMan?.vehicleType || "moto"}
                  >
                    <option value="moto">Moto</option>
                    <option value="bici">Bicicleta</option>
                    <option value="auto">Auto</option>
                    <option value="camioneta">Camioneta</option>
                    <option value="otro">Otro</option>
                  </select>
                </div>
                <Button
                  onClick={() => {
                    const nameInput = document.getElementById(
                      "driver-name",
                    ) as HTMLInputElement;
                    const emailInput = document.getElementById(
                      "driver-email",
                    ) as HTMLInputElement;
                    const phoneInput = document.getElementById(
                      "driver-phone",
                    ) as HTMLInputElement;
                    const vehicleSelect = document.getElementById(
                      "driver-vehicle",
                    ) as HTMLSelectElement;
                    handleCreateOrUpdateDeliveryMan({
                      name: nameInput.value,
                      email: emailInput.value,
                      phone: phoneInput.value,
                      vehicleType: vehicleSelect.value,
                    });
                  }}
                  className="w-full"
                >
                  {editingDeliveryMan ? "Actualizar" : "Crear"}
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>
        <div className="flex items-center gap-2">
          <Input
            placeholder="Buscar repartidor..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-[180px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Todos</SelectItem>
              <SelectItem value="active">Activos</SelectItem>
              <SelectItem value="inactive">Inactivos</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-24">Imagen</TableHead>
                <TableHead>Nombre</TableHead>
                <TableHead>Teléfono</TableHead>
                <TableHead>Estado</TableHead>
                <TableHead>Acciones</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {paginatedDeliveryMen.map((deliveryMan) => (
                <TableRow key={deliveryMan.id}>
                  <TableCell>
                    {deliveryMan.photoUrl && (
                      <img
                        src={deliveryMan.photoUrl}
                        alt={deliveryMan.name}
                        className="h-16 w-16 rounded-md object-cover"
                      />
                    )}
                  </TableCell>
                  <TableCell>{deliveryMan.name}</TableCell>
                  <TableCell>{deliveryMan.phone}</TableCell>
                  <TableCell>
                    <Switch
                      checked={deliveryMan.status === "active"}
                      onCheckedChange={(checked) =>
                        handleToggleStatus(deliveryMan.id, checked)
                      }
                    />
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="outline"
                      size="sm"
                      className="mr-2"
                      onClick={() => {
                        setEditingDeliveryMan(deliveryMan);
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
                            Esta acción no se puede deshacer. El repartidor se
                            eliminará permanentemente.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>Cancelar</AlertDialogCancel>
                          <AlertDialogAction
                            onClick={() =>
                              handleDeleteDeliveryMan(deliveryMan.id)
                            }
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
        <Pagination
          pageIndex={page - 1}
          totalCount={filteredDeliveryMen.length}
          perPage={deliveryMenPerPage}
          onPageChange={(page) => setPage(page + 1)}
        />
      </div>
    </>
  );
}
