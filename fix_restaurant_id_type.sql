-- Migration: Fix restaurant_id type mismatch
-- Problem: restaurant_id is UUID but app sends TEXT
-- Solution: Change to TEXT for flexibility

-- Step 1: Change restaurant_id type to TEXT
ALTER TABLE drivers 
ALTER COLUMN restaurant_id TYPE TEXT;

-- Step 2: Verify the change
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'drivers' 
AND column_name = 'restaurant_id';

-- Step 3: Clean up any test data if needed
-- DELETE FROM drivers WHERE email LIKE '%test%';
-- DELETE FROM auth.users WHERE email LIKE '%test%';
