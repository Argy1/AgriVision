-- ============================================================================
-- 005: bucket Storage `plant-photos` + kebijakan akses (untuk project Supabase BARU)
-- ============================================================================
-- Untuk yang memasang AgriVision di project Supabase sendiri (docs/10-panduan-setup-mandiri.md).
-- Jalankan di SQL Editor SETELAH database/schema.sql. Aman dijalankan ulang.
--
-- PRODUKSI: bucket dan kebijakan setara sudah dibuat lewat Dashboard, jadi jangan
-- jalankan ini di sana tanpa memeriksa Storage -> Policies lebih dulu (kebijakan
-- permissive digabung dengan OR; duplikat tidak berbahaya tetapi membingungkan).
-- Catatan: isi berkas ini diturunkan dari perilaku kode (web/components/upload/Dropzone.tsx,
-- app/lib/data/repositories/uploads_repository.dart) dan dari aturan di docs/09 bagian 5,
-- bukan disalin dari kebijakan produksi.
--
-- Aturan:
--   * Bucket privat. Path objek selalu `{auth.uid()}/{zone_id}/{timestamp}.{ext}`.
--   * User login hanya boleh MENGUNGGAH ke folder dengan uid-nya sendiri, dan membaca/
--     mendaftar folder miliknya (app memanggil list() untuk cek idempotensi saat retry).
--   * admin_ppl boleh membaca semua. Tidak ada policy UPDATE/DELETE (foto = bukti diagnosis).
--   * ml-service memakai service role key (melewati RLS) untuk mengunduh foto.

-- Kolom `public` tidak diisi: nilai bawaannya false (bucket privat).
insert into storage.buckets (id, name)
values ('plant-photos', 'plant-photos')
on conflict (id) do nothing;

drop policy if exists "plant_photos_insert_own_folder" on storage.objects;
create policy "plant_photos_insert_own_folder" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'plant-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "plant_photos_select_own_or_admin" on storage.objects;
create policy "plant_photos_select_own_or_admin" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'plant-photos'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or public.current_user_role() = 'admin_ppl'
    )
  );
