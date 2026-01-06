-- Ver políticas RLS de la tabla orders
SELECT *
FROM pg_policies
WHERE tablename = 'orders';
