import { Link } from "react-router-dom";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function PromotionManagement() {
  return (
    <Link to="/business/promotions">
      <Card className="cursor-pointer hover:bg-muted/50">
        <CardHeader>
          <CardTitle>Gestión de Promociones</CardTitle>
        </CardHeader>
        <CardContent>
          <p>
            Crear ofertas especiales, combos o cupones, estableciendo sus
            condiciones y su duración.
          </p>
        </CardContent>
      </Card>
    </Link>
  );
}
