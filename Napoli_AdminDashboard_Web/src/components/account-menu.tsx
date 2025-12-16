import { Building, ChevronDown, LogOut, User } from "lucide-react";

import { StoreProfileDialog } from "@/components/store-profile-dialog"; // Import
import { useSignOutMutation } from "@/core/hooks/useAuth";
import { useGetManagedRestaurantQuery } from "@/core/hooks/useRestaurant";
import { useGetProfileQuery } from "@/core/hooks/useUser";

import { AdminProfileDialog } from "./admin-profile-dialog";
import { Button } from "./ui/button";
import { Dialog, DialogTrigger } from "./ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "./ui/dropdown-menu";
import { Skeleton } from "./ui/skeleton";

export function AccountMenu() {
  const { data: profile, isLoading: isLoadingProfile } = useGetProfileQuery();

  const { data: managedRestaurant, isLoading: isLoadingManagedRestaurant } =
    useGetManagedRestaurantQuery();

  const { mutateAsync: signOutFn, isPending: isSigningOut } =
    useSignOutMutation();

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button
          variant="outline"
          className="flex select-none items-center gap-2"
        >
          {isLoadingManagedRestaurant ? (
            <Skeleton className="h-4 w-40" />
          ) : (
            managedRestaurant?.name
          )}
          <ChevronDown className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-56">
        <DropdownMenuLabel className="flex flex-col">
          {isLoadingProfile ? (
            <div className="space-y-1.5">
              <Skeleton className="h-4 w-32" />
              <Skeleton className="h-3 w-24" />
            </div>
          ) : (
            <>
              <span>{profile?.name}</span>
              <span className="text-xs font-normal text-muted-foreground">
                {profile?.email}
              </span>
            </>
          )}
        </DropdownMenuLabel>
        <DropdownMenuSeparator />

        <Dialog>
          <DialogTrigger asChild>
            <DropdownMenuItem onSelect={(e) => e.preventDefault()}>
              <Building className="mr-2 h-4 w-4" />
              <span>Perfil de la tienda</span>
            </DropdownMenuItem>
          </DialogTrigger>
          <StoreProfileDialog />
        </Dialog>

        <Dialog>
          <DialogTrigger asChild>
            <DropdownMenuItem onSelect={(e) => e.preventDefault()}>
              <User className="mr-2 h-4 w-4" />
              <span>Perfil del administrador</span>
            </DropdownMenuItem>
          </DialogTrigger>
          <AdminProfileDialog />
        </Dialog>

        <DropdownMenuItem
          asChild
          className="text-rose-500 dark:text-rose-400"
          disabled={isSigningOut}
        >
          <button className="w-full" onClick={() => signOutFn()}>
            <LogOut className="mr-2 h-4 w-4" />
            <span>Cerrar sesión</span>
          </button>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
