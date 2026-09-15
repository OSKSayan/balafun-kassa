-- balaFUN Kassa: per-user schema with Row Level Security
-- Run this once in the Supabase SQL Editor (Project > SQL Editor > New query > Run)

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  emoji text not null default '🍽️',
  grp text not null default 'kitchen',
  created_at timestamptz not null default now()
);

create table public.items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete cascade,
  name text not null,
  price numeric not null default 0,
  photo text,
  created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  label text not null,
  status text not null default 'open',
  created_at timestamptz not null default now(),
  closed_at timestamptz
);

create table public.order_lines (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  item_id uuid,
  name text not null,
  price numeric not null,
  qty integer not null default 1
);

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.items enable row level security;
alter table public.orders enable row level security;
alter table public.order_lines enable row level security;

create policy "own profile" on public.profiles for all
  using (auth.uid() = id) with check (auth.uid() = id);
create policy "own categories" on public.categories for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own items" on public.items for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own orders" on public.orders for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own order_lines" on public.order_lines for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
