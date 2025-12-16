import { Loader2 } from "lucide-react";
import { useEffect, useState } from "react";

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
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  useGetManagedRestaurantQuery,
  useUpdateRestaurantSettingsMutation,
} from "@/core/hooks/useRestaurant";

const DAYS_MAP: Record<string, string> = {
  monday: "Lunes",
  tuesday: "Martes",
  wednesday: "Miércoles",
  thursday: "Jueves",
  friday: "Viernes",
  saturday: "Sábado",
  sunday: "Domingo",
};

const ORDERED_DAYS = [
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday",
  "sunday",
];

interface DaySchedule {
  enabled: boolean;
  open: string | null;
  close: string | null;
}

export function OperatingHoursSettings() {
  const { data: restaurant, isLoading } = useGetManagedRestaurantQuery();
  const { mutate: updateSettings, isPending: isSaving } =
    useUpdateRestaurantSettingsMutation();

  const [schedule, setSchedule] = useState<Record<string, DaySchedule>>({});

  // Initialize state from fetched data
  useEffect(() => {
    if (restaurant?.businessHours) {
      setSchedule(restaurant.businessHours);
    }
  }, [restaurant]);

  const handleToggleDay = (dayKey: string) => {
    setSchedule((prev) => ({
      ...prev,
      [dayKey]: {
        ...prev[dayKey],
        enabled: !prev[dayKey]?.enabled,
      },
    }));
  };

  const handleTimeChange = (
    dayKey: string,
    type: "open" | "close",
    value: string,
  ) => {
    setSchedule((prev) => ({
      ...prev,
      [dayKey]: {
        ...prev[dayKey],
        [type]: value,
      },
    }));
  };

  const handleSave = () => {
    updateSettings({ businessHours: schedule });
  };

  if (isLoading) {
    return (
      <div className="flex h-40 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  return (
    <Card className="lg:col-span-2">
      <CardHeader>
        <CardTitle>Horario de Operación</CardTitle>
        <CardDescription>
          Define los horarios de apertura y cierre para cada día de la semana.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {ORDERED_DAYS.map((dayKey) => {
          const dayConfig = schedule[dayKey] || {
            enabled: false,
            open: "09:00",
            close: "22:00",
          };
          return (
            <div
              key={dayKey}
              className="flex items-center justify-between space-x-4"
            >
              <div className="flex items-center space-x-2">
                <Checkbox
                  id={`enable-${dayKey}`}
                  checked={dayConfig.enabled}
                  onCheckedChange={() => handleToggleDay(dayKey)}
                />
                <Label htmlFor={`enable-${dayKey}`} className="w-24">
                  {DAYS_MAP[dayKey]}
                </Label>
              </div>
              <div className="flex items-center space-x-2">
                <Input
                  id={`${dayKey}-open`}
                  type="time"
                  value={dayConfig.open || ""}
                  onChange={(e) =>
                    handleTimeChange(dayKey, "open", e.target.value)
                  }
                  disabled={!dayConfig.enabled}
                  className="w-32"
                />
                <span>-</span>
                <Input
                  id={`${dayKey}-close`}
                  type="time"
                  value={dayConfig.close || ""}
                  onChange={(e) =>
                    handleTimeChange(dayKey, "close", e.target.value)
                  }
                  disabled={!dayConfig.enabled}
                  className="w-32"
                />
              </div>
            </div>
          );
        })}
      </CardContent>
      <CardFooter className="flex justify-end border-t px-6 py-4">
        <Button onClick={handleSave} disabled={isSaving}>
          {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
          Guardar Cambios
        </Button>
      </CardFooter>
    </Card>
  );
}
