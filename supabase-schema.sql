create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  expense_date date not null,
  place text not null,
  amount numeric(12, 2) not null check (amount > 0),
  is_gift boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.settlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  payment_date date not null,
  settled_until date not null,
  amount numeric(12, 2) not null check (amount > 0),
  created_at timestamptz not null default now()
);

alter table public.expenses enable row level security;
alter table public.settlements enable row level security;

create policy "Users can read own expenses"
  on public.expenses for select
  using (auth.uid() = user_id);

create policy "Users can create own expenses"
  on public.expenses for insert
  with check (auth.uid() = user_id);

create policy "Users can update own expenses"
  on public.expenses for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own expenses"
  on public.expenses for delete
  using (auth.uid() = user_id);

create policy "Users can read own settlements"
  on public.settlements for select
  using (auth.uid() = user_id);

create policy "Users can create own settlements"
  on public.settlements for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own settlements"
  on public.settlements for delete
  using (auth.uid() = user_id);

create table if not exists public.app_sync (
  sync_key text primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_sync enable row level security;

drop policy if exists "Public can read app sync" on public.app_sync;
drop policy if exists "Public can create app sync" on public.app_sync;
drop policy if exists "Public can update app sync" on public.app_sync;

create policy "Public can read app sync"
  on public.app_sync for select
  to anon
  using (true);

create policy "Public can create app sync"
  on public.app_sync for insert
  to anon
  with check (true);

create policy "Public can update app sync"
  on public.app_sync for update
  to anon
  using (true)
  with check (true);

grant usage on schema public to anon;
grant select, insert, update on public.app_sync to anon;
