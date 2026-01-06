-- Ver TODAS las políticas RLS activas en la tabla orders
SELECT 
  policyname, 
  cmd, 
  permissive,
  roles,
  qual 
FROM pg_policies 
WHERE tablename = 'orders' 
ORDER BY policyname;
