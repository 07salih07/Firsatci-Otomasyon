-- listings
create table if not exists public.listings (
ilan_id text primary key,
ilan_linki text,
ilan_basligi text,
fiyat numeric,
para_birimi text,
plaka_hash text,
ilan_tarihi date,
son_guncellenme_tarihi timestamptz,
aciklama_metni text,
ilk_gorulme_tarihi timestamptz default now(),
konum_il text,
konum_ilce text,
marka text,
seri text,
model text,
yil int,
paket_donanim text,
km int,
yakit_turu text,
vites_tipi text,
motor_hacmi_cc int,
motor_gucu_hp int,
cekis text,
kasa_tipi text,
renk text,
boya_degisen_bilgisi text,
tramer_kaydi_tutari numeric,
kimden text,
takasa_uygun_mu boolean,
created_at timestamptz default now(),
updated_at timestamptz default now()
);
-- price_history
create table if not exists public.price_history (
id bigserial primary key,
ilan_id text not null references public.listings(ilan_id) on delete
cascade,
plaka_hash text,
tarih timestamptz default now(),
fiyat numeric,
currency text
);
-- notifications
create table if not exists public.notifications (
id bigserial primary key,
ilan_id text,
reason text,
pct_diff numeric,
median_price numeric,
city text,
district text,
sent boolean default false,
created_at timestamptz default now()
);
alter table public.listings enable row level security;
alter table public.price_history enable row level security;
alter table public.notifications enable row level security;
