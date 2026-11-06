
-- Run once in Supabase SQL editor. Requires Supabase Auth enabled.
create extension if not exists pgcrypto;
create table public.admin_members (
 user_id uuid primary key references auth.users(id) on delete cascade,
 created_at timestamptz not null default now()
);
create table public.catalog_items (
 id uuid primary key default gen_random_uuid(),
 name text not null check(length(trim(name)) between 1 and 180),
 category text not null check(category in ('furniture','clothing','material','recipe')),
 source text not null default 'Unknown',
 dlc text not null default 'base',
 status text not null default 'draft' check(status in ('draft','published')),
 metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table public.player_profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 display_name text,
 play_frequency text not null default 'casual',
 playstyles text[] not null default '{}',
 dlcs text[] not null default array['base']::text[],
 updated_at timestamptz not null default now()
);
create table public.player_items (
 user_id uuid not null references auth.users(id) on delete cascade,
 item_id uuid not null references public.catalog_items(id) on delete cascade,
 owned boolean not null default false,
 unlocked boolean not null default false,
 quantity integer not null default 0 check(quantity>=0),
 wishlisted boolean not null default false,
 updated_at timestamptz not null default now(),
 primary key(user_id,item_id)
);
create table public.storage_chests (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null,
 created_at timestamptz not null default now()
);
create table public.chest_contents (
 chest_id uuid not null references public.storage_chests(id) on delete cascade,
 item_id uuid not null references public.catalog_items(id) on delete cascade,
 quantity integer not null check(quantity>=0),
 primary key(chest_id,item_id)
);
create table public.crafting_requirements (
 recipe_item_id uuid not null references public.catalog_items(id) on delete cascade,
 material_item_id uuid not null references public.catalog_items(id) on delete cascade,
 quantity integer not null check(quantity>0),
 primary key(recipe_item_id,material_item_id)
);
create table public.dreamsnaps (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 challenge_name text not null,
 submitted_on date,
 category text check(category in ('outfit','decor')),
 rank integer check(rank>0),
 moonstones integer check(moonstones>=0),
 photo_path text,
 created_at timestamptz not null default now()
);
create table public.catalog_audit (
 id bigint generated always as identity primary key,
 item_id uuid,
 actor uuid,
 operation text not null,
 old_row jsonb,
 new_row jsonb,
 created_at timestamptz not null default now()
);
create or replace function public.is_valley_admin() returns boolean
 language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.admin_members where user_id=(select auth.uid()))
 $$;
create or replace function public.catalog_audit_trigger() returns trigger
 language plpgsql security definer set search_path = '' as $$
 begin
 insert into public.catalog_audit(item_id,actor,operation,old_row,new_row)
 values(coalesce(new.id,old.id),auth.uid(),tg_op,to_jsonb(old),to_jsonb(new));
 if tg_op='DELETE' then return old; end if;
 new.updated_at=now();
 return new;
 end $$;
create trigger catalog_change before insert or update or delete on public.catalog_items
 for each row execute function public.catalog_audit_trigger();
-- RLS is enforced by the database, not by hiding dashboard buttons.
alter table public.admin_members enable row level security;
alter table public.catalog_items enable row level security;
alter table public.player_profiles enable row level security;
alter table public.player_items enable row level security;
alter table public.storage_chests enable row level security;
alter table public.chest_contents enable row level security;
alter table public.crafting_requirements enable row level security;
alter table public.dreamsnaps enable row level security;
alter table public.catalog_audit enable row level security;
create policy admin_self_read on public.admin_members for select to authenticated using (user_id=(select auth.uid()));
create policy catalog_read on public.catalog_items for select to authenticated using (status='published' or (select public.is_valley_admin()));
create policy catalog_admin_insert on public.catalog_items for insert to authenticated with check ((select public.is_valley_admin()));
create policy catalog_admin_update on public.catalog_items for update to authenticated using ((select public.is_valley_admin())) with check ((select public.is_valley_admin()));
create policy catalog_admin_delete on public.catalog_items for delete to authenticated using ((select public.is_valley_admin()));
create policy profiles_owner on public.player_profiles for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
create policy items_owner on public.player_items for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
create policy chests_owner on public.storage_chests for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
create policy chest_contents_owner on public.chest_contents for all to authenticated
 using (exists(select 1 from public.storage_chests c where c.id=chest_id and c.user_id=(select auth.uid())))
 with check (exists(select 1 from public.storage_chests c where c.id=chest_id and c.user_id=(select auth.uid())));
create policy requirements_read on public.crafting_requirements for select to authenticated using (true);
create policy requirements_admin_insert on public.crafting_requirements for insert to authenticated with check ((select public.is_valley_admin()));
create policy requirements_admin_update on public.crafting_requirements for update to authenticated using ((select public.is_valley_admin())) with check ((select public.is_valley_admin()));
create policy requirements_admin_delete on public.crafting_requirements for delete to authenticated using ((select public.is_valley_admin()));
create policy snaps_owner on public.dreamsnaps for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
create policy audit_admin_read on public.catalog_audit for select to authenticated using ((select public.is_valley_admin()));
-- Private bucket; application must use authenticated, per-user object paths.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
 values ('dreamsnaps','dreamsnaps',false,12582912,array['image/jpeg','image/png','image/webp'])
 on conflict (id) do nothing;
create policy dreamsnaps_read on storage.objects for select to authenticated
 using (bucket_id='dreamsnaps' and (storage.foldername(name))[1]=(select auth.uid())::text);
create policy dreamsnaps_insert on storage.objects for insert to authenticated
 with check (bucket_id='dreamsnaps' and (storage.foldername(name))[1]=(select auth.uid())::text);
create policy dreamsnaps_delete on storage.objects for delete to authenticated
 using (bucket_id='dreamsnaps' and (storage.foldername(name))[1]=(select auth.uid())::text);
