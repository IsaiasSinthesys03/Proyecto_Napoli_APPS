import { Helmet } from "react-helmet-async";

import { PopularProducts } from "./popular-products";
import { SalesReport } from "./sales-report";

export function Reports() {
  return (
    <>
      <Helmet title="Reportes" />
      <div className="flex flex-col gap-4">
        <h1 className="text-3xl font-bold tracking-tight">
          Reportes y Analíticas
        </h1>

        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          <SalesReport />
          <PopularProducts />
        </div>
      </div>
    </>
  );
}
