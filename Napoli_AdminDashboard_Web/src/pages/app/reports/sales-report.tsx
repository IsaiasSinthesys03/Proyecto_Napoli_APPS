import { useNavigate } from "react-router-dom";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { useGetMonthRevenueQuery } from "@/core/hooks/useMetrics";
import { useGetManagedRestaurantQuery } from "@/core/hooks/useRestaurant";

export function SalesReport() {
  const navigate = useNavigate();
  const { data: monthRevenue, isLoading } = useGetMonthRevenueQuery();
  const { data: restaurant } = useGetManagedRestaurantQuery();

  const currencySymbol = restaurant?.currencySymbol || "$";

  // Month revenue is in main units (already divided by 100 in service)
  const monthlyRevenue = monthRevenue?.receipt || 0;
  // Estimate weekly as ~1/4 of monthly, daily as ~1/30 (rough approximation)
  const weeklyRevenue = monthlyRevenue / 4;
  const dailyRevenue = monthlyRevenue / 30;

  const formatCurrency = (value: number) => {
    return `${currencySymbol}${value.toLocaleString("es-MX", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })}`;
  };

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Reporte de Ventas</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <Skeleton className="h-6 w-full" />
          <Skeleton className="h-6 w-full" />
          <Skeleton className="h-6 w-full" />
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="cursor-pointer" onClick={() => navigate("/reports/sales")}>
      <CardHeader>
        <CardTitle>Reporte de Ventas</CardTitle>
      </CardHeader>
      <CardContent className="space-y-2">
        <div className="flex items-center justify-between">
          <p className="text-sm text-muted-foreground">Ventas del día:</p>
          <p className="text-lg font-bold">{formatCurrency(dailyRevenue)}</p>
        </div>
        <div className="flex items-center justify-between">
          <p className="text-sm text-muted-foreground">Ventas de la semana:</p>
          <p className="text-lg font-bold">{formatCurrency(weeklyRevenue)}</p>
        </div>
        <div className="flex items-center justify-between">
          <p className="text-sm text-muted-foreground">Ventas del mes:</p>
          <p className="text-lg font-bold">{formatCurrency(monthlyRevenue)}</p>
        </div>
      </CardContent>
    </Card>
  );
}
