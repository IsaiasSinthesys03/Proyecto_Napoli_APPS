import { subDays } from "date-fns";
import { Loader2 } from "lucide-react";
import { useState } from "react";
import { DateRange } from "react-day-picker";
import { Cell, Pie, PieChart, ResponsiveContainer } from "recharts";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { colors } from "@/components/ui/colors";
import { DateRangePicker } from "@/components/ui/date-range-picker";
import { useGetPopularProductsQuery } from "@/core/hooks/useMetrics";

export function PopularProductsChart() {
  const [dateRange, setDateRange] = useState<DateRange | undefined>({
    from: subDays(new Date(), 7),
    to: new Date(),
  });

  const { data: popularProducts, isFetching: isFetchingPopularProducts } =
    useGetPopularProductsQuery({ from: dateRange?.from, to: dateRange?.to });

  return (
    <Card className="col-span-3">
      <CardHeader className="pb-8">
        <div className="flex items-center justify-between">
          <CardTitle className="text-base font-medium">
            Productos populares
          </CardTitle>
          <DateRangePicker date={dateRange} onDateChange={setDateRange} />
        </div>
      </CardHeader>
      <CardContent>
        {isFetchingPopularProducts && (
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
        )}
        {popularProducts && (
          <ResponsiveContainer width="100%" height={240}>
            <PieChart style={{ fontSize: 12 }}>
              <Pie
                data={popularProducts}
                dataKey="amount"
                nameKey="product"
                cx="50%"
                cy="50%"
                outerRadius={86}
                innerRadius={64}
                strokeWidth={8}
                labelLine={false}
                label={({
                  cx,
                  cy,
                  midAngle,
                  innerRadius,
                  outerRadius,
                  value,
                  index,
                }) => {
                  const RADIAN = Math.PI / 180;
                  const radius = 12 + innerRadius + (outerRadius - innerRadius);
                  const x = cx + radius * Math.cos(-midAngle * RADIAN);
                  const y = cy + radius * Math.sin(-midAngle * RADIAN);

                  return (
                    <text
                      x={x}
                      y={y}
                      className="fill-muted-foreground text-xs"
                      textAnchor={x > cx ? "start" : "end"}
                      dominantBaseline="central"
                    >
                      {popularProducts[index].product.length > 12
                        ? popularProducts[index].product
                            .substring(0, 12)
                            .concat("...")
                        : popularProducts[index].product}{" "}
                      ({value})
                    </text>
                  );
                }}
              >
                {popularProducts.map((_, i) => {
                  return (
                    <Cell
                      key={`cell-${i}`}
                      fill={colors[i]}
                      className="stroke-background hover:opacity-80"
                    />
                  );
                })}
              </Pie>
            </PieChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
