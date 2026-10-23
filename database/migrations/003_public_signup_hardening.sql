-- ============================================================================
-- 003: pengerasan untuk pendaftaran publik
-- ============================================================================
-- Jalankan di Supabase SQL Editor (project AgriVision). Aman dijalankan ulang.

-- 1. Cegah user mengubah role-nya sendiri.
-- Sebelumnya policy profiles_update_own tidak punya WITH CHECK/pembatasan kolom,
-- jadi user login mana pun bisa menjalankan profiles.update({role:'admin_ppl'})
-- dan melihat semua zona/diagnosis orang lain. auth.uid() hanya terisi untuk
-- request client (JWT user); service_role dan SQL Editor tidak terkena, jadi
-- menaikkan akun jadi admin_ppl tetap bisa lewat dashboard/SQL.
create or replace function public.prevent_profile_role_change()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.role is distinct from old.role and auth.uid() is not null then
    raise exception 'Role tidak boleh diubah dari client' using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_prevent_profile_role_change on public.profiles;
create trigger trg_prevent_profile_role_change
  before update on public.profiles
  for each row execute procedure public.prevent_profile_role_change();

-- 2. handle_new_user: search_path eksplisit + batasi panjang nama dari metadata
-- (metadata dikontrol client). Role tetap di-hardcode 'petani'.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    left(trim(coalesce(nullif(trim(new.raw_user_meta_data->>'full_name'), ''), 'Pengguna Baru')), 100),
    'petani'
  );
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;

-- 3. Batasi panjang nama di level tabel.
alter table public.profiles drop constraint if exists profiles_full_name_length;
alter table public.profiles
  add constraint profiles_full_name_length check (char_length(full_name) between 1 and 100);
