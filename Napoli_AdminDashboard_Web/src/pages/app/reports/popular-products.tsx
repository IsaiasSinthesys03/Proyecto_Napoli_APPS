import { subDays } from "date-fns";
import { useState } from "react";
import { DateRange } from "react-day-picker";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DateRangePicker } from "@/components/ui/date-range-picker";
import { useGetPopularProductsQuery } from "@/core/hooks/useMetrics";

export function PopularProducts() {
  const [dateRange, setDateRange] = useState<DateRange | undefined>({
    from: subDays(new Date(), 7),
    to: new Date(),
  });

  const { data: popularProducts } = useGetPopularProductsQuery({
    from: dateRange?.from,
    to: dateRange?.to,
  });

  return (
    <Card>
      <CardHeader className="flex-row items-center justify-between pb-8">
        <div className="space-y-1">
          <CardTitle className="text-base font-medium">
            Productos Más Vendidos
          </CardTitle>
        </div>
        <DateRangePicker date={dateRange} onDateChange={setDateRange} />
      </CardHeader>
      <CardContent>
        {popularProducts && Array.isArray(popularProducts) ? (
          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={popularProducts} style={{ fontSize: 12 }}>
              <XAxis
                dataKey="product"
                stroke="#888888"
                axisLine={false}
                tickLine={false}
                dy={16}
              />
              <YAxis
                stroke="#888888"
                axisLine={false}
                tickLine={false}
                width={80}
              />
              <CartesianGrid vertical={false} className="stroke-muted" />
              <Bar dataKey="amount" fill="#f7a000" />
              <Tooltip />
            </BarChart>
          </ResponsiveContainer>
        ) : (
          <div className="flex h-60 items-center justify-center">
            <p className="text-muted-foreground">
              Cargando productos más vendidos...
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
