import { createBrowserRouter } from "react-router-dom";

import { AppLayout } from "./_layouts/app";
import { AuthLayout } from "./_layouts/auth";
import { NotFound } from "./404";
import { Addons } from "./app/business/addons";
import { Categories } from "./app/business/categories";
import { MenuManagement } from "./app/business/menu-management"; // New import
import { Products } from "./app/business/products";
import { Promotions } from "./app/business/promotions";
import { Dashboard } from "./app/dashboard/dashboard";
import { DeliveryMen } from "./app/delivery-men/delivery-men";
import { Orders } from "./app/orders/orders";
import { Reports } from "./app/reports/reports";
import { SalesReportDetail } from "./app/reports/sales-report-detail";
import { Settings } from "./app/settings/settings";
import { SignIn } from "./auth/sign-in";
import { SignUp } from "./auth/sign-up";
import { Error } from "./error";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <AppLayout />,
    errorElement: <Error />,
    children: [
      { path: "/", element: <Dashboard /> },
      { path: "/orders", element: <Orders /> },
      { path: "/business/menu", element: <MenuManagement /> }, // New route
      { path: "/business/products", element: <Products /> },
      { path: "/business/categories", element: <Categories /> },
      { path: "/business/addons", element: <Addons /> },
      { path: "/business/promotions", element: <Promotions /> },
      { path: "/delivery-men", element: <DeliveryMen /> },
      { path: "/settings", element: <Settings /> },
      { path: "/reports", element: <Reports /> },
      { path: "/reports/sales", element: <SalesReportDetail /> },
    ],
  },
  {
    element: <AuthLayout />,
    children: [
      { path: "/sign-in", element: <SignIn /> },
      { path: "/sign-up", element: <SignUp /> },
    ],
  },
  {
    path: "*",
    element: <NotFound />,
  },
]);
