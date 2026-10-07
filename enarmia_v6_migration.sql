-- ENARMIA V6 — onboarding + materiales + calendario
-- Ejecutar una sola vez en Supabase > SQL Editor.

-- =========================
-- 1) Preferencias del estudiante
-- =========================
alter table public.profiles
  add column if not exists communication_style text not null default 'Claro y directo',
  add column if not exists exam_date date,
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists available_minutes integer not null default 90,
  add column if not exists days_per_week integer not null default 6,
  add column if not exists topic_goal integer not null default 1,
  add column if not exists preferred_study_time text not null default 'mañana',
  add column if not exists learning_preferences jsonb not null default '["preguntas"]'::jsonb,
  add column if not exists focus_topics text[] not null default '{}',
  add column if not exists focus_mode text not null default 'errores',
  add column if not exists current_level text not null default 'inicio',
  add column if not exists course_calendar_name text,
  add column if not exists course_calendar_path text;

grant update on public.profiles to authenticated;

-- =========================
-- 2) Materiales del estudiante
-- =========================
create table if not exists public.study_materials (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  material_type text not null default 'Resumen',
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.study_materials enable row level security;
grant select, insert, update, delete on public.study_materials to authenticated;

drop policy if exists "Users can view their own study materials" on public.study_materials;
create policy "Users can view their own study materials"
on public.study_materials for select to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can create their own study materials" on public.study_materials;
create policy "Users can create their own study materials"
on public.study_materials for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update their own study materials" on public.study_materials;
create policy "Users can update their own study materials"
on public.study_materials for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own study materials" on public.study_materials;
create policy "Users can delete their own study materials"
on public.study_materials for delete to authenticated
using (auth.uid() = user_id);

-- =========================
-- 3) Bucket privado para calendario del curso
-- =========================
insert into storage.buckets (id, name, public)
values ('course-calendars', 'course-calendars', false)
on conflict (id) do nothing;

-- Cada archivo debe vivir en una carpeta con el UUID del usuario como primer segmento.
drop policy if exists "Users can upload their own course calendar" on storage.objects;
create policy "Users can upload their own course calendar"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'course-calendars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can read their own course calendar" on storage.objects;
create policy "Users can read their own course calendar"
on storage.objects for select to authenticated
using (
  bucket_id = 'course-calendars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can delete their own course calendar" on storage.objects;
create policy "Users can delete their own course calendar"
on storage.objects for delete to authenticated
using (
  bucket_id = 'course-calendars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

grant usage on schema storage to authenticated;
grant select, insert, delete on storage.objects to authenticated;

-- Fin
