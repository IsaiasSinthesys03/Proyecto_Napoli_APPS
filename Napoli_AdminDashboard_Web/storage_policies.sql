-- ##############################################################################
-- # NAPOLI SAAS - SUPABASE STORAGE POLICIES (DROP & CREATE)
-- # Drops existing policies first to avoid conflicts
-- ##############################################################################

-- ============================================================================
-- DROP EXISTING POLICIES (if any)
-- ============================================================================

-- product-images policies
DROP POLICY IF EXISTS "Allow authenticated uploads to product-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to product-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to product-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from product-images" ON storage.objects;

-- category-images policies
DROP POLICY IF EXISTS "Allow authenticated uploads to category-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to category-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to category-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from category-images" ON storage.objects;

-- customer-avatars policies
DROP POLICY IF EXISTS "Allow authenticated uploads to customer-avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to customer-avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to customer-avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from customer-avatars" ON storage.objects;

-- restaurant-assets policies
DROP POLICY IF EXISTS "Allow authenticated uploads to restaurant-assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to restaurant-assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to restaurant-assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from restaurant-assets" ON storage.objects;

-- driver-documents policies
DROP POLICY IF EXISTS "Allow authenticated uploads to driver-documents" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated read access to driver-documents" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to driver-documents" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from driver-documents" ON storage.objects;

-- ============================================================================
-- STORAGE BUCKETS
-- ============================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

INSERT INTO storage.buckets (id, name, public)
VALUES ('category-images', 'category-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

INSERT INTO storage.buckets (id, name, public)
VALUES ('customer-avatars', 'customer-avatars', true)
ON CONFLICT (id) DO UPDATE SET public = true;

INSERT INTO storage.buckets (id, name, public)
VALUES ('driver-documents', 'driver-documents', false)
ON CONFLICT (id) DO UPDATE SET public = false;

INSERT INTO storage.buckets (id, name, public)
VALUES ('restaurant-assets', 'restaurant-assets', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- ============================================================================
-- CREATE POLICIES - product-images
-- ============================================================================

CREATE POLICY "Allow authenticated uploads to product-images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Allow public read access to product-images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'product-images');

CREATE POLICY "Allow authenticated updates to product-images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'product-images');

CREATE POLICY "Allow authenticated deletes from product-images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'product-images');

-- ============================================================================
-- CREATE POLICIES - category-images
-- ============================================================================

CREATE POLICY "Allow authenticated uploads to category-images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'category-images');

CREATE POLICY "Allow public read access to category-images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'category-images');

CREATE POLICY "Allow authenticated updates to category-images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'category-images');

CREATE POLICY "Allow authenticated deletes from category-images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'category-images');

-- ============================================================================
-- CREATE POLICIES - customer-avatars
-- ============================================================================

CREATE POLICY "Allow authenticated uploads to customer-avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'customer-avatars');

CREATE POLICY "Allow public read access to customer-avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'customer-avatars');

CREATE POLICY "Allow authenticated updates to customer-avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'customer-avatars');

CREATE POLICY "Allow authenticated deletes from customer-avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'customer-avatars');

-- ============================================================================
-- CREATE POLICIES - restaurant-assets
-- ============================================================================

CREATE POLICY "Allow authenticated uploads to restaurant-assets"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'restaurant-assets');

CREATE POLICY "Allow public read access to restaurant-assets"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'restaurant-assets');

CREATE POLICY "Allow authenticated updates to restaurant-assets"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'restaurant-assets');

CREATE POLICY "Allow authenticated deletes from restaurant-assets"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'restaurant-assets');

-- ============================================================================
-- CREATE POLICIES - driver-documents (private)
-- ============================================================================

CREATE POLICY "Allow authenticated uploads to driver-documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'driver-documents');

CREATE POLICY "Allow authenticated read access to driver-documents"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'driver-documents');

CREATE POLICY "Allow authenticated updates to driver-documents"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'driver-documents');

CREATE POLICY "Allow authenticated deletes from driver-documents"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'driver-documents');
