import { Link } from "react-router-dom";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function ProductManagement() {
  return (
    <Link to="/business/products">
      <Card className="cursor-pointer hover:bg-muted/50">
        <CardHeader>
          <CardTitle>Gestión de Productos</CardTitle>
        </CardHeader>
        <CardContent>
          <p>Crear, ver, editar o eliminar cualquier producto del menú.</p>
        </CardContent>
      </Card>
    </Link>
  );
}
