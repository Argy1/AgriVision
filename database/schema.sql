-- ============================================================================
-- AgriVision — Supabase Postgres Schema
-- Sistem Deteksi Penyakit dan Pemantauan Kesehatan Tanaman Tomat & Cabai
-- ============================================================================
-- Jalankan lewat Supabase SQL editor atau `supabase db push` / mcp__Supabase__apply_migration.
-- Urutan CREATE TABLE penting karena foreign key.

-- ---------------------------------------------------------------------------
-- 1. profiles — extends auth.users bawaan Supabase
-- ---------------------------------------------------------------------------
create type user_role as enum ('admin_ppl', 'petani');

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role user_role not null default 'petani',
  phone text,
  created_at timestamptz not null default now()
);

-- Trigger: auto-buat row profiles saat user baru daftar
create function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', 'Pengguna Baru'), 'petani');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- ---------------------------------------------------------------------------
-- 2. zones — petak/lahan yang dipantau
-- ---------------------------------------------------------------------------
create type crop_type as enum ('tomat', 'cabai');

create table zones (
  id uuid primary key default gen_random_uuid(),
  name text not null,                 -- contoh: "A3"
  crop_type crop_type not null,
  owner_id uuid not null references profiles(id) on delete cascade,
  location_note text,                 -- contoh: "Blok Tomat, belakang gudang"
  created_at timestamptz not null default now()
);

create index idx_zones_owner on zones(owner_id);

-- ---------------------------------------------------------------------------
-- 3. uploads — foto yang diunggah
-- ---------------------------------------------------------------------------
create table uploads (
  id uuid primary key default gen_random_uuid(),
  zone_id uuid not null references zones(id) on delete cascade,
  uploaded_by uuid not null references profiles(id) on delete cascade,
  image_path text not null,           -- path di Supabase Storage bucket 'plant-photos'
  captured_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index idx_uploads_zone on uploads(zone_id);
create index idx_uploads_captured on uploads(captured_at desc);

-- ---------------------------------------------------------------------------
-- 4. diagnoses — hasil inferensi model CNN (1:1 dengan uploads)
-- ---------------------------------------------------------------------------
create type severity_level as enum ('ringan', 'sedang', 'parah');

create table diagnoses (
  id uuid primary key default gen_random_uuid(),
  upload_id uuid not null unique references uploads(id) on delete cascade,
  disease_label text not null,        -- key internal, contoh: "tomato_early_blight"
  disease_name text not null,         -- nama tampilan, contoh: "Early Blight (Bercak Daun Awal)"
  confidence numeric(5,4) not null check (confidence >= 0 and confidence <= 1),
  severity severity_level not null,
  affected_area_pct numeric(5,2) not null check (affected_area_pct >= 0 and affected_area_pct <= 100),
  model_version text not null default 'v1',
  created_at timestamptz not null default now()
);

create index idx_diagnoses_upload on diagnoses(upload_id);

-- ---------------------------------------------------------------------------
-- 5. vegetation_index_readings — hasil ExG/VARI (modul monitoring)
-- ---------------------------------------------------------------------------
create table vegetation_index_readings (
  id uuid primary key default gen_random_uuid(),
  upload_id uuid not null unique references uploads(id) on delete cascade,
  exg_score numeric(6,3) not null,
  vari_score numeric(6,3) not null,
  health_score numeric(5,2) not null check (health_score >= 0 and health_score <= 100),
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 6. disease_reference — knowledge base rule-based (modul rekomendasi)
-- ---------------------------------------------------------------------------
create table disease_reference (
  disease_label text primary key,     -- cocok dengan diagnoses.disease_label
  disease_name text not null,
  crop_type crop_type not null,
  description text,
  recommendation_text text not null,
  dosage text,
  application_schedule text,
  warning_note text,
  -- Status verifikasi konten, DILACAK LEWAT DATA (bukan tag di dalam teks) karena
  -- recommendation_text/warning_note tampil langsung ke end user (petani) di aplikasi --
  -- bukan tempat yang tepat untuk catatan internal tim dev. false = draft dari literatur
  -- umum, belum diverifikasi ke dosen pembimbing/sumber agronomi terpercaya (lihat
  -- 05-ml-pipeline.md Modul 3); dosis pestisida yang salah berisiko nyata bagi pengguna.
  is_verified boolean not null default false,
  updated_at timestamptz not null default now()
);

-- Seed data — disease_label HARUS cocok persis dengan output notebook training
-- (ml-service/agrivision_training.ipynb, fungsi to_disease_label()).
insert into disease_reference (disease_label, disease_name, crop_type, description, recommendation_text, dosage, application_schedule, warning_note, is_verified) values

-- Tomat (10 kelas — PlantVillage)
('tomato_bacterial_spot', 'Bacterial Spot (Bercak Bakteri)', 'tomat',
 'Disebabkan bakteri Xanthomonas spp., bercak kecil kehitaman dengan tepi kekuningan pada daun.',
 'Gunakan bakterisida berbahan tembaga, hindari penyiraman dari atas yang membasahi daun.',
 'Sesuai label produk', 'Setiap 7 hari saat gejala aktif',
 null, false),
('tomato_early_blight', 'Early Blight (Bercak Daun Awal)', 'tomat',
 'Disebabkan jamur Alternaria solani, ditandai bercak coklat konsentris pada daun tua.',
 'Gunakan fungisida berbahan aktif klorotalonil. Pangkas dan musnahkan daun yang terinfeksi berat.',
 '2 g/L air',
 'Semprotkan setiap 7-10 hari hingga gejala mereda',
 'Menyebar cepat pada kondisi lembap — segera pantau zona sekitar.', true),
('tomato_late_blight', 'Late Blight (Busuk Daun)', 'tomat',
 'Disebabkan oomycete Phytophthora infestans, bercak coklat kehitaman basah yang menyebar cepat.',
 'Gunakan fungisida berbahan aktif mankozeb/metalaksil, cabut dan musnahkan tanaman terinfeksi berat segera.',
 'Sesuai label produk', 'Setiap 5-7 hari, lebih sering saat cuaca lembap',
 'Penyakit sangat destruktif dan cepat menyebar — segera isolasi tanaman yang terinfeksi.', false),
('tomato_leaf_mold', 'Leaf Mold (Jamur Daun)', 'tomat',
 'Disebabkan jamur Passalora fulva (Fulvia fulva), bercak kuning di permukaan atas daun dengan lapisan jamur di bawah daun.',
 'Perbaiki sirkulasi udara/kurangi kelembapan rumah kaca, gunakan fungisida sesuai anjuran.',
 'Sesuai label produk', 'Sesuai anjuran produk',
 null, false),
('tomato_septoria_leaf_spot', 'Septoria Leaf Spot (Bercak Septoria)', 'tomat',
 'Disebabkan jamur Septoria lycopersici, bercak kecil bulat dengan pusat abu-abu dan tepi gelap.',
 'Pangkas daun bawah yang terinfeksi, gunakan fungisida berbahan klorotalonil/tembaga.',
 'Sesuai label produk', 'Setiap 7-10 hari',
 null, false),
('tomato_spider_mites_two_spotted_spider_mite', 'Spider Mites (Tungau Laba-laba)', 'tomat',
 'Hama tungau Tetranychus urticae, menyebabkan bintik kuning/keperakan dan jaring halus di bawah daun.',
 'Gunakan akarisida sesuai anjuran, tingkatkan kelembapan (tungau menyukai kondisi kering).',
 'Sesuai label produk', 'Sesuai anjuran produk',
 'Ini serangan hama, bukan penyakit jamur/bakteri — fungisida biasa tidak efektif.', false),
('tomato_target_spot', 'Target Spot (Bercak Target)', 'tomat',
 'Disebabkan jamur Corynespora cassiicola, bercak coklat dengan cincin konsentris menyerupai target.',
 'Gunakan fungisida sesuai anjuran, perbaiki sirkulasi udara antar tanaman.',
 'Sesuai label produk', 'Sesuai anjuran produk',
 null, false),
('tomato_tomato_yellow_leaf_curl_virus', 'Yellow Leaf Curl Virus (Virus Keriting Kuning)', 'tomat',
 'Virus TYLCV ditularkan kutu kebul (whitefly), daun menguning, mengeriting, dan tanaman kerdil.',
 'Kendalikan populasi kutu kebul dengan insektisida sistemik, cabut tanaman terinfeksi berat.',
 'Sesuai label insektisida', 'Setiap 5-7 hari selama populasi vektor tinggi',
 'Virus tidak dapat disembuhkan — fokus pencegahan penyebaran vektor ke tanaman sehat.', false),
('tomato_tomato_mosaic_virus', 'Mosaic Virus (Virus Mosaik)', 'tomat',
 'Virus ToMV, menyebabkan pola mosaik hijau muda-tua pada daun dan pertumbuhan terhambat.',
 'Cabut dan musnahkan tanaman terinfeksi, sterilisasi alat kerja, hindari menangani tanaman sehat setelah tanaman sakit.',
 null, null,
 'Virus tidak dapat disembuhkan dan sangat mudah menular lewat kontak/alat kerja.', false),
('tomato_healthy', 'Sehat', 'tomat', 'Tidak ada gejala penyakit terdeteksi.', 'Lanjutkan perawatan rutin.', null, null, null, true),

-- Cabai (6 kelas — Roboflow chili-leaves-disease-classification; lihat docs/05-ml-pipeline.md
-- untuk riwayat pergantian dataset cabai dan kenapa nama kelasnya beda dari versi-versi sebelumnya)
('chili_leaf_curl', 'Leaf Curl (Keriting Daun)', 'cabai',
 'Umumnya disebabkan virus yang ditularkan kutu kebul (whitefly), daun mengeriting dan menebal.',
 'Kendalikan populasi kutu kebul dengan insektisida sistemik, cabut dan musnahkan tanaman yang terinfeksi berat.',
 'Sesuai label insektisida',
 'Setiap 5-7 hari selama populasi vektor masih tinggi',
 'Virus tidak dapat disembuhkan — fokus pencegahan penyebaran ke tanaman sehat.', true),
('chili_powdery_mildew', 'Powdery Mildew (Embun Tepung)', 'cabai',
 'Disebabkan jamur (kompleks Leveillula/Oidiopsis pada cabai), lapisan tepung putih di permukaan daun, biasanya di bawah daun terlebih dahulu.',
 'Gunakan fungisida berbahan sulfur atau triazol sesuai anjuran, perbaiki sirkulasi udara antar tanaman untuk kurangi kelembapan mikro.',
 'Sesuai label produk', 'Setiap 7-10 hari saat gejala muncul',
 null, false),
('chili_leaf_spot', 'Leaf Spot (Bercak Daun)', 'cabai',
 'Bercak pada daun, umumnya disebabkan jamur (mis. Cercospora capsici) — label dataset tidak merinci patogen spesifik, verifikasi visual/lab dianjurkan untuk kasus nyata.',
 'Gunakan fungisida sesuai anjuran, pangkas daun bawah yang terinfeksi untuk kurangi sumber inokulum.',
 'Sesuai label produk', 'Setiap 7-10 hari',
 'Gejala bercak daun ini bisa disebabkan beberapa jenis jamur berbeda — kalau tidak membaik setelah penanganan awal, konsultasikan ke PPL setempat.', false),
('chili_whitefly', 'Whitefly (Kutu Kebul)', 'cabai',
 'Serangan hama kutu kebul (Bemisia tabaci) — bukan penyakit, tapi vektor penyebar virus (termasuk leaf curl) dan penyebab kerusakan langsung lewat hisapan cairan daun.',
 'Gunakan insektisida sistemik atau perangkap kuning lengket, kendalikan populasi sejak dini karena berperan sebagai vektor virus.',
 'Sesuai label produk', 'Sesuai anjuran produk / saat populasi terdeteksi tinggi',
 'Ini hama vektor, bukan penyakit — populasi tinggi berisiko menyebarkan virus keriting daun ke tanaman sehat.', false),
('chili_yellowish', 'Yellowish (Daun Menguning)', 'cabai',
 'Gejala umum daun menguning — bisa disebabkan banyak hal (kekurangan nutrisi, serangan virus, kelebihan air, dll). Label dataset ini adalah gejala, bukan diagnosis penyebab spesifik.',
 'Periksa faktor lain (drainase, pemupukan, tanda hama/virus penyerta) sebelum menentukan penanganan — gejala ini butuh observasi lanjutan, bukan resep tunggal.',
 null, null,
 'Gejala menguning bisa disebabkan banyak hal (nutrisi, air, awal infeksi virus) — pantau perkembangannya beberapa hari sebelum penanganan lanjutan.', false),
('chili_healthy', 'Sehat', 'cabai', 'Tidak ada gejala penyakit terdeteksi.', 'Lanjutkan perawatan rutin.', null, null, null, true);

-- ---------------------------------------------------------------------------
-- 7. recommendations — snapshot rekomendasi per diagnosis (historical record)
-- ---------------------------------------------------------------------------
create table recommendations (
  id uuid primary key default gen_random_uuid(),
  diagnosis_id uuid not null unique references diagnoses(id) on delete cascade,
  recommendation_text text not null,
  dosage text,
  application_schedule text,
  warning_note text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 8. zone_health_daily — snapshot harian per zona untuk grafik tren dashboard
-- ---------------------------------------------------------------------------
create type zone_status as enum ('sehat', 'waspada', 'perlu_tindakan');

create table zone_health_daily (
  id uuid primary key default gen_random_uuid(),
  zone_id uuid not null references zones(id) on delete cascade,
  date date not null,
  avg_health_score numeric(5,2),
  diagnosis_count int not null default 0,
  status zone_status not null default 'sehat',
  created_at timestamptz not null default now(),
  unique (zone_id, date)
);

create index idx_zone_health_zone_date on zone_health_daily(zone_id, date desc);

-- Trigger: isi zone_health_daily on-the-fly setiap ada vegetation_index_reading
-- baru (tabel ini kosong sampai baris ini ditambahkan -- dashboard/monitoring/
-- detail zona semuanya bergantung padanya).
--
-- DEPENDENSI: lookup "severity terburuk hari ini" di bawah mengasumsikan row
-- diagnoses untuk upload_id ini SUDAH ADA saat trigger ini jalan. Ini benar
-- selama ml-service/app/routers/diagnose.py insert diagnoses SEBELUM
-- vegetation_index_readings untuk request yang sama -- kalau urutan itu pernah
-- dibalik, trigger ini akan melewatkan diagnosis terbaru hari itu di
-- perhitungan "severity terburuk".
--
-- "Hari ini" dihitung di zona waktu Asia/Jakarta (bukan UTC/current_date)
-- supaya batas hari cocok dengan hari petani sebenarnya, bukan jam server DB.
create or replace function public.upsert_zone_health_daily()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_zone_id uuid;
  v_today date := (now() at time zone 'Asia/Jakarta')::date;
  v_avg_health numeric(5,2);
  v_count int;
  v_worst_severity severity_level;
begin
  select u.zone_id into v_zone_id from uploads u where u.id = new.upload_id;
  if v_zone_id is null then
    return new;
  end if;

  select avg(vir.health_score), count(*)
    into v_avg_health, v_count
  from vegetation_index_readings vir
  join uploads u on u.id = vir.upload_id
  where u.zone_id = v_zone_id
    and (vir.created_at at time zone 'Asia/Jakarta')::date = v_today;

  select d.severity into v_worst_severity
  from diagnoses d
  join uploads u on u.id = d.upload_id
  where u.zone_id = v_zone_id
    and (d.created_at at time zone 'Asia/Jakarta')::date = v_today
  order by case d.severity when 'parah' then 3 when 'sedang' then 2 else 1 end desc
  limit 1;

  insert into zone_health_daily (zone_id, date, avg_health_score, diagnosis_count, status)
  values (
    v_zone_id, v_today, v_avg_health, coalesce(v_count, 0),
    coalesce(
      case v_worst_severity
        when 'parah' then 'perlu_tindakan'
        when 'sedang' then 'waspada'
        else 'sehat'
      end::zone_status,
      'sehat'
    )
  )
  on conflict (zone_id, date) do update set
    avg_health_score = excluded.avg_health_score,
    diagnosis_count  = excluded.diagnosis_count,
    status           = excluded.status;

  return new;
end;
$$;

-- Fungsi ini HANYA dipanggil oleh trigger di bawah, tidak pernah lewat RPC
-- client manapun -- revoke total dari public/anon/authenticated.
revoke execute on function public.upsert_zone_health_daily() from public, anon, authenticated;

drop trigger if exists trg_zone_health_daily on vegetation_index_readings;
create trigger trg_zone_health_daily
  after insert on vegetation_index_readings
  for each row execute procedure public.upsert_zone_health_daily();

-- ============================================================================
-- Row Level Security (RLS)
-- ============================================================================
alter table profiles enable row level security;
alter table zones enable row level security;
alter table uploads enable row level security;
alter table diagnoses enable row level security;
alter table vegetation_index_readings enable row level security;
alter table recommendations enable row level security;
alter table zone_health_daily enable row level security;
alter table disease_reference enable row level security;

-- Helper function: cek role user yang sedang login. HARUS security definer supaya bypass
-- RLS untuk lookup ini secara spesifik -- kalau tidak, setiap policy "admin_ppl bisa lihat
-- semua" di bawah ini akan query balik ke profiles, yang memicu policy profiles itu sendiri
-- lagi (query ke profiles), dan seterusnya: infinite recursion (Postgres error 42P17).
-- Fungsi ini sengaja TIDAK dibuka lewat PostgREST RPC ke anon (lihat revoke di bawah);
-- authenticated boleh, karena cuma mengembalikan role milik pemanggil sendiri.
create or replace function public.current_user_role()
returns user_role
language sql
security definer
set search_path = public
stable
as $$
  select role from profiles where id = auth.uid();
$$;

revoke execute on function public.current_user_role() from public;
grant execute on function public.current_user_role() to authenticated;

-- profiles: user hanya bisa lihat/ubah profil sendiri; admin_ppl bisa lihat semua
create policy "profiles_select_own_or_admin" on profiles for select
  using (id = auth.uid() or public.current_user_role() = 'admin_ppl');
create policy "profiles_update_own" on profiles for update using (id = auth.uid());

-- zones: admin_ppl lihat semua zona; petani hanya zona miliknya
create policy "zones_select" on zones for select
  using (owner_id = auth.uid() or public.current_user_role() = 'admin_ppl');
create policy "zones_insert_own" on zones for insert with check (owner_id = auth.uid());
create policy "zones_update_own" on zones for update using (owner_id = auth.uid());

-- uploads: mengikuti akses ke zona terkait
create policy "uploads_select" on uploads for select
  using (
    exists (
      select 1 from zones z
      where z.id = uploads.zone_id
      and (z.owner_id = auth.uid() or public.current_user_role() = 'admin_ppl')
    )
  );
-- uploads_insert juga verifikasi zone_id memang milik uploader (bukan cuma
-- uploaded_by = auth.uid()) -- tidak tereksploitasi lewat app UI (dropdown zona
-- sudah difilter RLS), tapi menutup celah di level DB juga, konsisten dengan
-- pola zones_select/zones_insert_own.
create policy "uploads_insert" on uploads for insert
  with check (
    uploaded_by = auth.uid()
    and exists (select 1 from zones z where z.id = uploads.zone_id and z.owner_id = auth.uid())
  );

-- diagnoses, vegetation_index_readings, recommendations: ikut akses upload terkait
create policy "diagnoses_select" on diagnoses for select
  using (
    exists (
      select 1 from uploads u join zones z on z.id = u.zone_id
      where u.id = diagnoses.upload_id
      and (z.owner_id = auth.uid() or public.current_user_role() = 'admin_ppl')
    )
  );
create policy "vegetation_select" on vegetation_index_readings for select
  using (
    exists (
      select 1 from uploads u join zones z on z.id = u.zone_id
      where u.id = vegetation_index_readings.upload_id
      and (z.owner_id = auth.uid() or public.current_user_role() = 'admin_ppl')
    )
  );
create policy "recommendations_select" on recommendations for select
  using (
    exists (
      select 1 from diagnoses d join uploads u on u.id = d.upload_id join zones z on z.id = u.zone_id
      where d.id = recommendations.diagnosis_id
      and (z.owner_id = auth.uid() or public.current_user_role() = 'admin_ppl')
    )
  );

-- zone_health_daily: ikut akses zona
create policy "zone_health_select" on zone_health_daily for select
  using (
    exists (
      select 1 from zones z
      where z.id = zone_health_daily.zone_id
      and (z.owner_id = auth.uid() or public.current_user_role() = 'admin_ppl')
    )
  );

-- disease_reference: dibaca semua authenticated user, hanya admin yang bisa ubah
create policy "disease_reference_select_all" on disease_reference for select
  using (auth.role() = 'authenticated');

-- Catatan: insert ke diagnoses/vegetation_index_readings/recommendations/zone_health_daily
-- dilakukan oleh FastAPI service memakai SERVICE_ROLE_KEY (bypass RLS by design),
-- bukan langsung dari client — jaga agar hasil inferensi tidak bisa dipalsukan dari frontend.

-- ============================================================================
-- Storage bucket (dibuat lewat Supabase Dashboard atau Storage API, bukan SQL)
-- ============================================================================
-- Nama bucket: plant-photos
-- Akses: private, signed URL untuk baca; upload lewat client SDK dengan RLS policy
--   yang sama (path harus diawali dengan auth.uid() sendiri, misal:
--   {user_id}/{zone_id}/{timestamp}.jpg)
