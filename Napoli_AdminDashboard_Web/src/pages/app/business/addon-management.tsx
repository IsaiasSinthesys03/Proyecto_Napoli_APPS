import { Link } from "react-router-dom";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function AddonManagement() {
  return (
    <Link to="/business/addons">
      <Card className="cursor-pointer hover:bg-muted/50">
        <CardHeader>
          <CardTitle>Gestión de Complementos</CardTitle>
        </CardHeader>
        <CardContent>
          <p>
            Definir y poner precio a los ingredientes extra, opciones de tamaño,
            masas, etc.
          </p>
        </CardContent>
      </Card>
    </Link>
  );
}
