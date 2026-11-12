-- ============================================================================
-- 004 — Hapus data cabai (proyek fokus ke tomat saja)
-- ============================================================================
-- DESTRUKTIF dan TIDAK BISA DIBATALKAN. Jalankan manual di Supabase SQL Editor,
-- bagian demi bagian, setelah membaca hasil pra-cek.
--
-- Alternatif yang disarankan: `ml-service/scripts/purge_chili_data.py` — melakukan
-- hal yang sama TERMASUK menghapus file foto di Storage (cascade database TIDAK
-- menghapus objek Storage), dengan mode dry-run secara default.
--
-- Enum `crop_type` SENGAJA tidak diubah ('cabai' tetap ada sebagai nilai mati);
-- Postgres tidak mendukung DROP VALUE dengan rapi dan nilainya tidak mengganggu.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. PRA-CEK (aman, hanya membaca)
-- ---------------------------------------------------------------------------
select crop_type, count(*) as jumlah_zona from zones group by 1;

-- Foto di Storage milik zona cabai. SIMPAN hasil query ini sebelum langkah 2,
-- karena setelah zona dihapus path-nya hilang dari database (objek Storage yatim).
select u.image_path
from uploads u
join zones z on z.id = u.zone_id
where z.crop_type = 'cabai';

select count(*) as jumlah_diagnosis_cabai
from diagnoses d
join uploads u on u.id = d.upload_id
join zones z on z.id = u.zone_id
where z.crop_type = 'cabai';

select disease_label from disease_reference where crop_type = 'cabai';

-- ---------------------------------------------------------------------------
-- 2. HAPUS (cascade ke uploads, diagnoses, recommendations,
--    vegetation_index_readings, zone_health_daily)
-- ---------------------------------------------------------------------------
begin;
  delete from zones where crop_type = 'cabai';
  delete from disease_reference where crop_type = 'cabai';
commit;

-- ---------------------------------------------------------------------------
-- 3. PASCA-CEK — keduanya harus 0 baris cabai; disease_reference harus 10 baris
-- ---------------------------------------------------------------------------
select count(*) as zona_cabai_tersisa from zones where crop_type = 'cabai';
select count(*) as referensi_cabai_tersisa from disease_reference where crop_type = 'cabai';
select count(*) as total_referensi from disease_reference;
