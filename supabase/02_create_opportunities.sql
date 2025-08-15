-- Örnek fırsat tablosu: kurala uygun aday kayıtları burada toplanabilir
create table if not exists public.opportunities (
id bigserial primary key,
ilan_id text,
city text,
district text,
price numeric,
median_price numeric,
pct_diff numeric,
reason text,
created_at timestamptz default now()
11
);
alter table public.opportunities enable row level security;
