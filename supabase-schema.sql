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
