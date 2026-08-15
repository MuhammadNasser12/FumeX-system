-- ═══════════════════════════════════════════════════════
--  FUME-X  —  Supabase Schema
--  Run this entire file in: Supabase Dashboard → SQL Editor
-- ═══════════════════════════════════════════════════════

-- 1. PRODUCTS
create table if not exists products (
  id                 text primary key,
  name               text not null,
  category           text not null default 'Fresh',
  price              numeric not null default 0,
  stock              integer not null default 0,
  low_stock_threshold integer not null default 10,
  image              text default '📦',
  created_at         timestamptz default now()
);

-- 2. ORDERS
create table if not exists orders (
  id          text primary key,
  customer    text not null,
  phone       text,
  source      text not null default 'manual',  -- manual | shopify | website
  status      text not null default 'pending', -- pending | processing | shipped | delivered | cancelled
  total       numeric not null default 0,
  date        date not null default current_date,
  created_at  timestamptz default now()
);

-- 3. ORDER ITEMS  (each row = one product line in an order)
create table if not exists order_items (
  id          bigint generated always as identity primary key,
  order_id    text references orders(id) on delete cascade,
  product_id  text references products(id),
  qty         integer not null default 1,
  unit_price  numeric not null default 0
);

-- ── Indexes ────────────────────────────────────────────
create index if not exists idx_orders_status   on orders(status);
create index if not exists idx_orders_date     on orders(date desc);
create index if not exists idx_order_items_ord on order_items(order_id);

-- ── Row Level Security (open for now — tighten later) ──
alter table products    enable row level security;
alter table orders      enable row level security;
alter table order_items enable row level security;

create policy "allow all products"    on products    for all using (true) with check (true);
create policy "allow all orders"      on orders      for all using (true) with check (true);
create policy "allow all order_items" on order_items for all using (true) with check (true);

-- ── Seed Data (optional — delete if you want a clean start) ──
insert into products (id, name, category, price, stock, low_stock_threshold, image) values
  ('P001', 'Oud Noir',      'Premium', 149, 42, 10, '🖤'),
  ('P002', 'Citrus Blast',  'Fresh',    89,  8, 10, '🍋'),
  ('P003', 'Rose Mystique', 'Floral',  119, 25, 10, '🌹'),
  ('P004', 'Ocean Drive',   'Fresh',    99,  3, 10, '🌊'),
  ('P005', 'Amber Gold',    'Premium', 179, 17, 10, '✨'),
  ('P006', 'Cedar Smoke',   'Woody',   129,  0, 10, '🌲')
on conflict (id) do nothing;
