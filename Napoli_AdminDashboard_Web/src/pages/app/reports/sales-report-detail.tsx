import { subDays } from "date-fns";
import { useState } from "react";
import { DateRange } from "react-day-picker";
import { Helmet } from "react-helmet-async";
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DateRangePicker } from "@/components/ui/date-range-picker";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  useGetDailyRevenueInPeriodQuery,
  useGetSalesTransactionsQuery,
} from "@/core/hooks/useMetrics";

export function SalesReportDetail() {
  const [dateRange, setDateRange] = useState<DateRange | undefined>({
    from: subDays(new Date(), 7),
    to: new Date(),
  });

  const { data: dailyRevenueInPeriod } = useGetDailyRevenueInPeriodQuery({
    from: dateRange?.from,
    to: dateRange?.to,
  });

  const { data: salesTransactions } = useGetSalesTransactionsQuery({
    from: dateRange?.from,
    to: dateRange?.to,
  });

  return (
    <>
      <Helmet title="Detalle de Reporte de Ventas" />
      <div className="flex flex-col gap-4">
        <h1 className="text-3xl font-bold tracking-tight">Reporte de Ventas</h1>

        <div className="flex items-center gap-3">
          <DateRangePicker date={dateRange} onDateChange={setDateRange} />
        </div>

        <Card className="col-span-6">
          <CardHeader className="flex-row items-center justify-between pb-8">
            <div className="space-y-1">
              <CardTitle className="text-base font-medium">
                Ingresos en el período
              </CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            {dailyRevenueInPeriod && Array.isArray(dailyRevenueInPeriod) ? (
              <ResponsiveContainer width="100%" height={240}>
                <LineChart data={dailyRevenueInPeriod} style={{ fontSize: 12 }}>
                  <XAxis
                    dataKey="date"
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
                    tickFormatter={(value: number) =>
                      value.toLocaleString("es-MX", {
                        style: "currency",
                        currency: "MXN",
                      })
                    }
                  />
                  <CartesianGrid vertical={false} className="stroke-muted" />
                  <Line
                    type="linear"
                    strokeWidth={2}
                    dataKey="receipt"
                    stroke="#f7a000"
                  />
                  <Tooltip
                    formatter={(value: number) =>
                      value.toLocaleString("es-MX", {
                        style: "currency",
                        currency: "MXN",
                      })
                    }
                  />
                </LineChart>
              </ResponsiveContainer>
            ) : (
              <div className="flex h-60 items-center justify-center">
                <p className="text-muted-foreground">
                  Cargando datos del reporte...
                </p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Detalle de Transacciones</CardTitle>
          </CardHeader>
          <CardContent>
            {salesTransactions ? (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>ID Transacción</TableHead>
                    <TableHead>Fecha</TableHead>
                    <TableHead>Cliente</TableHead>
                    <TableHead>Total</TableHead>
                    <TableHead>Items</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {salesTransactions.map((transaction) => (
                    <TableRow key={transaction.id}>
                      <TableCell>{transaction.id}</TableCell>
                      <TableCell>{transaction.date}</TableCell>
                      <TableCell>{transaction.customerName}</TableCell>
                      <TableCell>
                        {transaction.total.toLocaleString("es-MX", {
                          style: "currency",
                          currency: "MXN",
                        })}
                      </TableCell>
                      <TableCell>
                        {transaction.items.map((item, index) => (
                          <div key={index}>
                            {item.product} (x{item.quantity}) -{" "}
                            {item.price.toLocaleString("es-MX", {
                              style: "currency",
                              currency: "MXN",
                            })}
                          </div>
                        ))}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            ) : (
              <div className="flex h-20 items-center justify-center">
                <p className="text-muted-foreground">
                  Cargando transacciones...
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </>
  );
}
