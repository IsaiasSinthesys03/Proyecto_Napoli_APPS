-- Ver la definición ACTUAL de la función en Supabase
SELECT pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'get_available_orders'
  AND n.nspname = 'public';
