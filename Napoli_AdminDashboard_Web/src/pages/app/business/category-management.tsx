import { Link } from "react-router-dom";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function CategoryManagement() {
  return (
    <Link to="/business/categories">
      <Card className="cursor-pointer hover:bg-muted/50">
        <CardHeader>
          <CardTitle>Gestión de Categorías</CardTitle>
        </CardHeader>
        <CardContent>
          <p>Crear y organizar las secciones del menú.</p>
        </CardContent>
      </Card>
    </Link>
  );
}
