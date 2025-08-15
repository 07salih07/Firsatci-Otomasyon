# Fırsatçı‑Otomasyon — **GitHub’a Yüklenecek TAM PAKET** (eksiksiz, kopyalanabilir)

Aşağıdaki içerik **tek tek GitHub web arayüzünde** `Add file → Create new file` ile **aynı yol ve dosya adlarıyla** oluşturulup **tam metin olarak yapıştırılmalıdır**. İki ihtiyaç listesinin **birleşimi** sağlanmıştır ve önceki kısa özetler **tam metinlere** yükseltilmiştir. Ayrıca **GPT günlük başlatma protokolü** eklendi.

> Not: `schema_diagram.png` bir görsel dosyadır. GitHub arayüzünden yüklerken **Upload files** butonunu kullan. Aşağıda ayrıca **ASCII diyagram** eşleniğini de verdim ki metin olarak da depolayabilesin.

---

## ✅ Klasör yapısı

```
/docs/
/n8n_workflows/
/supabase/
/tests/
/gpt_config/
/knowledge_base/
```

---

## 📁 /docs

### 1) `docs/Protokol_Firsatci.md`

```markdown
# Fırsatçı Protokol (n8n + Supabase) — Cloud v1.106.3

## Amaç
- Güvenli **Webhook** → **If (x-api-key)** → **HttpRequest (Supabase insert)** → **Respond to Webhook** akışını kurmak.
- **$env kullanma** (Cloud’da engelli). Daima **$vars** kullan (n8n → Settings → Variables).
- HttpRequest **v4.1**'de header'lar **headerParametersUi.parameter** dizisiyle verilmelidir.

## Sürüm Kilitleri (n8n Cloud 1.106.3 ile uyumlu)
- Webhook: **v2.1** (`httpMethod=POST`, `responseMode=responseNode`)
- If: **v2.2** (`conditions.options.version=2`, `typeValidation=strict`, `caseSensitive=true`)
- RespondToWebhook: **v1.5**
- HttpRequest: **v4.1**

## Gerekli Variables (n8n → Settings → Variables)
- `N8N_ACTION_KEY` → örn. `n8nsalih`
- `SUPABASE_URL` → `https://<PROJECT_REF>.supabase.co`
- `SUPABASE_SERVICE_KEY` → **service_role** JWT (yalnız n8n’de saklanır)

## Akış Kalıpları
1) **SMOKE**: Webhook + Respond 200 (echo)
2) **API Gateway**: Webhook + If(x‑api‑key) → 200/401
3) **Ingest**: API Gateway TRUE → HttpRequest(Supabase) → Respond 200

## Expresssion Kalıpları
- **Respond 200 Body**: `={{ ({ ok: true, mode: $json.body?.mode ?? 'production', echo: $json.body ?? {} }) }}`
- **Respond 401 Body**: `={{ ({ ok: false, error: 'Unauthorized', reason: 'Invalid x-api-key' }) }}`
- **If (x-api-key) left**: `={{ ($json["headers"]["x-api-key"] || "").trim() }}`
- **If (x-api-key) right**: `={{ ($vars.N8N_ACTION_KEY || "").trim() }}`
- **HttpRequest → URL**: `={{ $vars.SUPABASE_URL + '/rest/v1/ingest_logs' }}`
- **HttpRequest → Header**: `apikey`, `Authorization: Bearer <service_key>`, `Content-Type: application/json`, `Prefer: return=representation`

## Hata → Çözüm
- **401 Unauthorized**: `x-api-key` eksik/yanlış → **If** koşulunu ve `$vars.N8N_ACTION_KEY` değerini kontrol et.
- **422 Invalid JSON**: Respond gövdesindeki JSON ifade hatalı → `={{ ({ ... }) }}` kalıbı ile saf obje dön.
- **403/429**: Anti-scraping → backoff + ScraperAPI/Proxy/Playwright (bkz. AntiScraping_Playbook.md).
- **Timeout**: Respond node var mı? Payload küçük mü? Üstel backoff + jitter kullan.

## Güvenlik ve KVKK
- Plaka gibi kişisel veriler **hash**'lenerek tutulmalı. Veri minimizasyonu, saklama süreleri sınırlı olmalı.
- robots.txt / ToS politikalarına saygı.

## Versiyonlama & Commit Kuralları
- **Branch**: `main` (MVP), `feat/*`, `fix/*`.
- **Commit**: `feat(n8n): add SECURE_firsatci_supabase_push` gibi anlamsal önek.
- **Tag**: `v0.1.0-mvp`, `v0.2.0-notifications`.
```

### 2) `docs/AntiScraping_Playbook.md`

```markdown
# Anti-Scraping Playbook (Crawl → Walk → Run)

## 1) Politeness (DAİMA)
- UA rotation, Accept-Language, Referer
- Rastgele gecikme (1–6 sn), düşük concurrency (1–3)
- Gerekirse cookie/session reuse

## 2) Detection
- HTTP 403 / 429
- Body’de anahtar kelimeler: `recaptcha`, `captcha`, `please enable javascript`, `access denied`
- Şüpheli kısa body (< 200 byte)

## 3) Fallback A — ScraperAPI/ZenRows
- `render=true` ile JS-render gerekirse

## 4) Fallback B — Residential Proxy (Bright Data, Oxylabs)
- IP tabanlı engellerde

## 5) Fallback C — Playwright Microservice (+ 2Captcha ops.)
- Human-like davranış (yavaş scroll, beklemeler)
- Session/cookie persistence; farklı UA

## 6) Circuit Breaker / Backoff
- Üstel backoff: 1s, 2s, 4s… + jitter
- 10 ardışık hata → frekansı 3× azalt, alarm

## KPI / Sağlık Göstergeleri
- Başarılı çekim oranı
- 403/429 oranı
- Ortalama sayfa süresi
- Fırsat precision (ilk 50 örnekte manuel kontrol)

## Hukuk & Etik
- KVKK uyumu; plaka hash; veri minimizasyonu
- TOS/robots saygısı; gerekirse lisanslama opsiyonları değerlendir
```

### 3) `docs/Hedefler_Plan.md`

```markdown
# Hedefler ve Plan (MVP → Ürün)

- **Faz 0**: Kurulum, n8n Variables, SECURE_SMOKE testi
- **Faz 1**: `ingest_logs` tablosu; 200/401/422 uçtan uca test
- **Faz 2**: median fiyat hesabı (SQL/RPC) + %diff + `notifications` insert
- **Faz 3**: e-posta bildirimi (SMTP/Mailgun/Resend)
- **Faz 4**: anti-scraping katmanlarının devreye alınması
- **Faz 5**: GPT Actions ile tetikleme, açıklamalı rapor

## Ölçütler (KPIs)
- 200/401 doğrulama süresi < 1s
- `ingest_logs` insert başarı oranı > %99
- Fırsat precision (manuel örneklem) ≥ %70
- Bildirim teslim oranı ≥ %98 (Faz 3 sonrası)
```

### 4) `docs/MVP_Uygulama_Akisi.md`

```markdown
# MVP Uygulama Akışı (Detaylı)

1. **Webhook (POST /webhook/firsatci/run)** — `httpMethod=POST`, `responseMode=responseNode`
2. **If (x-api-key)** — TRUE → devam; FALSE → **Respond 401**
3. **HttpRequest (Supabase insert: ingest_logs)** — Body: `mode/city/district/threshold/payload`
4. **Respond 200** — `{ ok: true, echo: body }`
5. (Faz 2) median/%diff hesapla → **notifications** insert
6. (Faz 3) e‑posta
```

### 5) `docs/Canvas_Proje_Plani.md`

```markdown
# Canvas Proje Planı
- Ürün: Fırsatları tespit edip bildirim gönderen motor.
- Kullanıcı: Şehir/ilçe + eşik + bildirim sıklığı seçer.
- Teknoloji: n8n Cloud, Supabase, (opsiyonel) Glide UI.
- AI: Fırsatçı Koçu GPT; neden‑fırsat analizleri ve Q&A.
- Ölçüm: Başarı oranı, 403/429, bildirim kalite geri bildirimi.
```

### 6) `docs/Proje_Akisi_Gantt.md`

```markdown
# Proje Akışı (Gantt - Metin)

- Hafta 1: n8n + Supabase kurulum, SECURE_SMOKE
- Hafta 2: ingest_logs insert akışı + testler (200/401/422)
- Hafta 3: median/%diff + notifications
- Hafta 4: e‑posta
- Hafta 5+: anti‑scraping + GPT Actions
```

### 7) `docs/GPT_Daily_Boot_Checklist.md`

```markdown
# GPT Günlük Başlatma Kontrol Listesi (Fırsatçı Koçu)

1) **Repo senkronu**: Son commit’leri oku; değişen dosyaları (diff) ve sürüm notunu özetle.
2) **Proje alanı**: Açık iş listesi, Faz/KPI durumu, engeller.
3) **n8n health**: Workflows aktif mi? Variables tamam mı? Son 10 execution hatası.
4) **Supabase health**: `ingest_logs` son 24h, hata oranı, tablo büyüklüğü.
5) **Testler**: `tests/*.ps1` hızlı duman testleri (200/401/422) için yönerge üret.
6) **Günlük plan**: 3–5 maddelik net hedef; gün sonunda çıkarılacak artefaktlar.
7) **Loglama**: Yeni oluşturulan kod/SQL/JSON dosyalarını versiyonlu kaydet ve değişiklik özetini yaz.
```

---

## 📁 /n8n_workflows

(İki isimlendirme seti—**tam içerikler**. n8n 1.106.3 şemaları.)

### A) İlk listendeki dosyalar

#### 1) `n8n_workflows/SECURE_SMOKE.json`

```json
{
  "name": "SECURE_SMOKE",
  "active": false,
  "nodes": [
    { "parameters": { "path": "smoke-secure", "httpMethod": "POST", "responseMode": "responseNode" }, "id": "Webhook_1", "name": "Webhook (POST /smoke-secure)", "type": "n8n-nodes-base.webhook", "typeVersion": 2.1, "position": [ -240, 200 ] },
    { "parameters": { "responseCode": 200, "responseFormat": "json", "responseBody": "={{ ({ ok: true, echo: $json.body ?? {} }) }}" }, "id": "Resp_200", "name": "Respond 200", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 80, 200 ] }
  ],
  "connections": { "Webhook (POST /smoke-secure)": { "main": [ [ { "node": "Respond 200", "type": "main", "index": 0 } ] ] } },
  "settings": {},
  "version": 2
}
```

#### 2) `n8n_workflows/SECURE_FIRSATCI_1_VARS.json`

```json
{
  "name": "SECURE_FIRSATCI_1_VARS",
  "active": false,
  "nodes": [
    { "parameters": { "path": "firsatci/run", "httpMethod": "POST", "responseMode": "responseNode" }, "id": "Webhook_1", "name": "Webhook (POST /firsatci/run)", "type": "n8n-nodes-base.webhook", "typeVersion": 2.1, "position": [ -240, 200 ] },
    { "parameters": { "conditions": { "options": { "caseSensitive": true, "typeValidation": "strict", "version": 2 }, "conditions": [ { "id": "cond-key", "leftValue": "={{ ($json[\"headers\"][\"x-api-key\"] || \"\").trim() }}", "rightValue": "={{ ($vars.N8N_ACTION_KEY || \"\").trim() }}", "operator": { "type": "string", "operation": "equals", "name": "filter.operator.equals" } } ], "combinator": "and" } }, "id": "If_Auth", "name": "If (x-api-key)", "type": "n8n-nodes-base.if", "typeVersion": 2.2, "position": [ 40, 200 ] },
    { "parameters": { "responseCode": 401, "responseFormat": "json", "responseBody": "={{ ({ ok: false, error: 'Unauthorized', reason: 'Invalid x-api-key' }) }}" }, "id": "Resp_401", "name": "Respond 401", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 360, 310 ] },
    { "parameters": { "responseCode": 200, "responseFormat": "json", "responseBody": "={{ ({ ok: true, mode: $json.body?.mode ?? 'production', echo: $json.body ?? {} }) }}" }, "id": "Resp_200", "name": "Respond 200", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 360, 110 ] }
  ],
  "connections": { "Webhook (POST /firsatci/run)": { "main": [ [ { "node": "If (x-api-key)", "type": "main", "index": 0 } ] ] }, "If (x-api-key)": { "main": [ [ { "node": "Respond 200", "type": "main", "index": 0 } ], [ { "node": "Respond 401", "type": "main", "index": 0 } ] ] } },
  "settings": {},
  "version": 2
}
```

#### 3) `n8n_workflows/SECURE_FIRSATCI_2_LOG_FIX.json`

```json
{
  "name": "SECURE_FIRSATCI_2_LOG_FIX",
  "active": false,
  "nodes": [
    { "parameters": { "path": "firsatci/run", "httpMethod": "POST", "responseMode": "responseNode" }, "id": "Webhook_1", "name": "Webhook (POST /firsatci/run)", "type": "n8n-nodes-base.webhook", "typeVersion": 2.1, "position": [ -240, 280 ] },
    { "parameters": { "conditions": { "options": { "caseSensitive": true, "typeValidation": "strict", "version": 2 }, "conditions": [ { "id": "cond-key", "leftValue": "={{ ($json[\"headers\"][\"x-api-key\"] || \"\").trim() }}", "rightValue": "={{ ($vars.N8N_ACTION_KEY || \"\").trim() }}", "operator": { "type": "string", "operation": "equals", "name": "filter.operator.equals" } } ], "combinator": "and" } }, "id": "If_Auth", "name": "If (x-api-key)", "type": "n8n-nodes-base.if", "typeVersion": 2.2, "position": [ 40, 280 ] },
    { "parameters": { "responseCode": 401, "responseFormat": "json", "responseBody": "={{ ({ ok: false, error: 'Unauthorized', reason: 'Invalid x-api-key' }) }}" }, "id": "Resp_401", "name": "Respond 401", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 340, 410 ] },
    { "parameters": { "method": "POST", "url": "={{ $vars.SUPABASE_URL + '/rest/v1/ingest_logs' }}", "authentication": "none", "sendBody": true, "jsonParameters": true, "headerParametersUi": { "parameter": [ { "name": "apikey", "value": "={{ $vars.SUPABASE_SERVICE_KEY }}" }, { "name": "Authorization", "value": "={{ 'Bearer ' + $vars.SUPABASE_SERVICE_KEY }}" }, { "name": "Content-Type", "value": "application/json" }, { "name": "Prefer", "value": "return=representation" } ] }, "bodyParametersJson": "={{ ({ mode: $json.body?.mode ?? 'full', city: $json.body?.city ?? '', district: $json.body?.district ?? '', threshold: Number($json.body?.threshold ?? 0), payload: $json.body ?? {} }) }}" }, "id": "HTTP_Supabase", "name": "Supabase Insert (ingest_logs)", "type": "n8n-nodes-base.httpRequest", "typeVersion": 4.1, "position": [ 340, 160 ] },
    { "parameters": { "responseCode": 200, "responseFormat": "json", "responseBody": "={{ ({ ok: true, mode: $json.body?.mode ?? 'production', echo: $json.body ?? {} }) }}" }, "id": "Resp_200", "name": "Respond 200", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 640, 160 ] }
  ],
  "connections": { "Webhook (POST /firsatci/run)": { "main": [ [ { "node": "If (x-api-key)", "type": "main", "index": 0 } ] ] }, "If (x-api-key)": { "main": [ [ { "node": "Supabase Insert (ingest_logs)", "type": "main", "index": 0 } ], [ { "node": "Respond 401", "type": "main", "index": 0 } ] ] }, "Supabase Insert (ingest_logs)": { "main": [ [ { "node": "Respond 200", "type": "main", "index": 0 } ] ] } },
  "settings": {},
  "version": 2
}
```

### B) İkinci listendeki **yeni isimli** eşdeğerler

#### 4) `n8n_workflows/SECURE_firsatci_ingest.json`

```json
{ "name": "SECURE_firsatci_ingest", "active": false, "nodes": [ { "parameters": { "path": "smoke-secure", "httpMethod": "POST", "responseMode": "responseNode" }, "id": "Webhook_1", "name": "Webhook (POST /smoke-secure)", "type": "n8n-nodes-base.webhook", "typeVersion": 2.1, "position": [ -240, 200 ] }, { "parameters": { "responseCode": 200, "responseFormat": "json", "responseBody": "={{ ({ ok: true, echo: $json.body ?? {} }) }}" }, "id": "Resp_200", "name": "Respond 200", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 80, 200 ] } ], "connections": { "Webhook (POST /smoke-secure)": { "main": [ [ { "node": "Respond 200", "type": "main", "index": 0 } ] ] } }, "settings": {}, "version": 2 }
```

#### 5) `n8n_workflows/SECURE_firsatci_api_gateway.json`

```json
{ "name": "SECURE_firsatci_api_gateway", "active": false, "nodes": [ { "parameters": { "path": "firsatci/run", "httpMethod": "POST", "responseMode": "responseNode" }, "id": "Webhook_1", "name": "Webhook (POST /firsatci/run)", "type": "n8n-nodes-base.webhook", "typeVersion": 2.1, "position": [ -240, 200 ] }, { "parameters": { "conditions": { "options": { "caseSensitive": true, "typeValidation": "strict", "version": 2 }, "conditions": [ { "id": "cond-key", "leftValue": "={{ ($json[\"headers\"][\"x-api-key\"] || \"\").trim() }}", "rightValue": "={{ ($vars.N8N_ACTION_KEY || \"\").trim() }}", "operator": { "type": "string", "operation": "equals", "name": "filter.operator.equals" } } ], "combinator": "and" } }, "id": "If_Auth", "name": "If (x-api-key)", "type": "n8n-nodes-base.if", "typeVersion": 2.2, "position": [ 40, 200 ] }, { "parameters": { "responseCode": 401, "responseFormat": "json", "responseBody": "={{ ({ ok: false, error: 'Unauthorized', reason: 'Invalid x-api-key' }) }}" }, "id": "Resp_401", "name": "Respond 401", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 360, 310 ] }, { "parameters": { "responseCode": 200, "responseFormat": "json", "responseBody": "={{ ({ ok: true, mode: $json.body?.mode ?? 'production', echo: $json.body ?? {} }) }}" }, "id": "Resp_200", "name": "Respond 200", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 360, 110 ] } ], "connections": { "Webhook (POST /firsatci/run)": { "main": [ [ { "node": "If (x-api-key)", "type": "main", "index": 0 } ] ] }, "If (x-api-key)": { "main": [ [ { "node": "Respond 200", "type": "main", "index": 0 } ], [ { "node": "Respond 401", "type": "main", "index": 0 } ] ] } }, "settings": {}, "version": 2 }
```

#### 6) `n8n_workflows/SECURE_firsatci_supabase_push.json`

```json
{ "name": "SECURE_firsatci_supabase_push", "active": false, "nodes": [ { "parameters": { "path": "firsatci/run", "httpMethod": "POST", "responseMode": "responseNode" }, "id": "Webhook_1", "name": "Webhook (POST /firsatci/run)", "type": "n8n-nodes-base.webhook", "typeVersion": 2.1, "position": [ -240, 280 ] }, { "parameters": { "conditions": { "options": { "caseSensitive": true, "typeValidation": "strict", "version": 2 }, "conditions": [ { "id": "cond-key", "leftValue": "={{ ($json[\"headers\"][\"x-api-key\"] || \"\").trim() }}", "rightValue": "={{ ($vars.N8N_ACTION_KEY || \"\").trim() }}", "operator": { "type": "string", "operation": "equals", "name": "filter.operator.equals" } } ], "combinator": "and" } }, "id": "If_Auth", "name": "If (x-api-key)", "type": "n8n-nodes-base.if", "typeVersion": 2.2, "position": [ 40, 280 ] }, { "parameters": { "responseCode": 401, "responseFormat": "json", "responseBody": "={{ ({ ok: false, error: 'Unauthorized', reason: 'Invalid x-api-key' }) }}" }, "id": "Resp_401", "name": "Respond 401", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 340, 410 ] }, { "parameters": { "method": "POST", "url": "={{ $vars.SUPABASE_URL + '/rest/v1/ingest_logs' }}", "authentication": "none", "sendBody": true, "jsonParameters": true, "headerParametersUi": { "parameter": [ { "name": "apikey", "value": "={{ $vars.SUPABASE_SERVICE_KEY }}" }, { "name": "Authorization", "value": "={{ 'Bearer ' + $vars.SUPABASE_SERVICE_KEY }}" }, { "name": "Content-Type", "value": "application/json" }, { "name": "Prefer", "value": "return=representation" } ] }, "bodyParametersJson": "={{ ({ mode: $json.body?.mode ?? 'full', city: $json.body?.city ?? '', district: $json.body?.district ?? '', threshold: Number($json.body?.threshold ?? 0), payload: $json.body ?? {} }) }}" }, "id": "HTTP_Supabase", "name": "Supabase Insert (ingest_logs)", "type": "n8n-nodes-base.httpRequest", "typeVersion": 4.1, "position": [ 340, 160 ] }, { "parameters": { "responseCode": 200, "responseFormat": "json", "responseBody": "={{ ({ ok: true, mode: $json.body?.mode ?? 'production', echo: $json.body ?? {} }) }}" }, "id": "Resp_200", "name": "Respond 200", "type": "n8n-nodes-base.respondToWebhook", "typeVersion": 1.5, "position": [ 640, 160 ] } ], "connections": { "Webhook (POST /firsatci/run)": { "main": [ [ { "node": "If (x-api-key)", "type": "main", "index": 0 } ] ] }, "If (x-api-key)": { "main": [ [ { "node": "Supabase Insert (ingest_logs)", "type": "main", "index": 0 } ], [ { "node": "Respond 401", "type": "main", "index": 0 } ] ] }, "Supabase Insert (ingest_logs)": { "main": [ [ { "node": "Respond 200", "type": "main", "index": 0 } ] ] } }, "settings": {}, "version": 2 }
```

---

## 📁 /supabase

### 1) `supabase/01_create_ingest_logs.sql`

```sql
create table if not exists public.ingest_logs (
  id bigint generated by default as identity primary key,
  mode text not null,
  city text not null,
  district text not null,
  threshold numeric not null,
  payload jsonb,
  created_at timestamptz default now()
);
```

### 2) `supabase/02_create_opportunities.sql`

```sql
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
);

alter table public.opportunities enable row level security;
```

### 3) (İlk listeden ek şema) `supabase/02_schema_core.sql`

```sql
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
  ilan_id text not null references public.listings(ilan_id) on delete cascade,
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
```

### 4) `supabase/supabase_env_sample.txt`

```text
SUPABASE_URL=https://<PROJECT_REF>.supabase.co
SUPABASE_SERVICE_KEY=SERVICE_ROLE_JWT
```

### 5) `supabase/schema_diagram.png`

- Bu dosyayı **GitHub → Upload files** ile görsel olarak yükleyin.
- Metin eşleniği için şu ASCII diyagramı `supabase/schema_diagram.txt` olarak da ekleyebilirsiniz:

```
[listings]──┐ 1      * ┌──[price_history]
            └──────────┘

[notifications] (bağımsız ilan_id alanı)
[opportunities] (kural bazlı aday kayıtlar)
```

---

## 📁 /tests

### 1) `tests/test_firsatci_api.ps1`

```powershell
param([string]$Url="https://ysl-salih.app.n8n.cloud/webhook/firsatci/run",[string]$ApiKey="n8nsalih",[string]$City="Antalya",[string]$District="Konyaalti",[int]$Threshold=15)
$hdrs=@{'x-api-key'=$ApiKey};$body=@{mode='full';city=$City;district=$District;threshold=$Threshold}|ConvertTo-Json -Compress
try{(Invoke-RestMethod -Method Post -Uri $Url -Headers $hdrs -Body $body -ContentType 'application/json' -ErrorAction Stop)|ConvertTo-Json -Compress}catch{$r=$_.Exception.Response;if($r -is [System.Net.Http.HttpResponseMessage]){"STATUS="+[int]$r.StatusCode;$r.Content.ReadAsStringAsync().GetAwaiter().GetResult()}elseif($r){"STATUS="+[int]$r.StatusCode;(New-Object IO.StreamReader($r.GetResponseStream())).ReadToEnd()}else{$_|Out-String}}
```

### 2) `tests/test_supabase_insert.ps1`

```powershell
param([string]$SupabaseUrl="https://<PROJECT_REF>.supabase.co",[string]$ServiceKey="SERVICE_ROLE_JWT")
$u="$SupabaseUrl/rest/v1/ingest_logs"
$h=@{"apikey"=$ServiceKey;"Authorization"="Bearer $ServiceKey";"Content-Type"="application/json";"Prefer"="return=representation"}
$b=@{mode='full';city='Antalya';district='Konyaalti';threshold=15;payload=@{hello='world'}}|ConvertTo-Json -Compress
try{(Invoke-RestMethod -Method Post -Uri $u -Headers $h -Body $b -ErrorAction Stop)|ConvertTo-Json -Compress}catch{$r=$_.Exception.Response;if($r){"STATUS="+[int]$r.StatusCode;(New-Object IO.StreamReader($r.GetResponseStream())).ReadToEnd()}else{$_|Out-String}}
```

### 3) `tests/test_scraping_defense.ps1`

```powershell
param([int]$Status=200,[string]$Body="ok")
$blocked=($Status -eq 403 -or $Status -eq 429 -or $Body.ToLower().Contains("captcha") -or $Body.Length -lt 200)
if($blocked){"DETECTED: anti-scraping. Strategy → backoff + fallback (ScraperAPI → Proxy → Playwright)"}else{"OK: proceed normal path"}
```

---

## 📁 /gpt_config

### 1) `gpt_config/instructions.txt`

```text
[BİRLEŞİK SİSTEM İLETİSİ — Fırsatçı Koçu]

### Rol ve Genel Tanım
Sen; gelişmiş veri analizi yapabilen, Python kodu çalıştırabilen, yüklenen dosyaları işleyebilen, net görselleştirmeler üretebilen ve tek bir proje alanı içinde süreklilik ile çalışabilen Kıdemli Veri Analisti & Kalıcı Proje Asistanısın. Hem Codex modu ile yüksek kaliteli, çalışır, yorumlu kod üretirsin; hem de GPT‑5 Think tarzıyla planlamanı gizli tutup, kullanıcıya yalın, sonuç odaklı anlatım sunarsın. Her yeni projede otomatik klasör yapısını kurar, dosyaları versiyonlu kaydeder, her oturumda kaldığın yerden devam edersin. Yeni bir proje başladığında kendi kendine başlatma sürecini tetikler ve proje yapısını kurarsın.

### Otomatik Proje Başlatma Kuralı
Kullanıcı yeni bir proje tanımı yaptığında veya ilk defa veri dosyaları yüklediğinde şu adımları otomatik uygula:
1. Klasör yapısını oluştur.
2. Boş dosya şablonlarını oluştur:
   - /04_Rapor/yonetici_ozeti/rapor_v1.md
   - /04_Rapor/teknik_rapor/rapor_teknik_v1.md
   - /02_Kod/analiz/analiz_v1.py
   - /05_Dokuman/notlar/toplanti_notlari_v1.md
3. Yüklenen dosyaları /01_Veriler/ham/ klasörüne yerleştir ve listele.
4. İlk Durum Özeti: dosya listesi, boyutlar, sütun adları, ilk 5 satır, eksik/aykırı analiz özeti.
5. İlk Sonraki Adımlar listesi: veri temizleme, keşif analizi, model ön hazırlığı.
Başlatma süreci kendiliğinden tetiklenir; kullanıcı ayrıca “başlat” komutu vermez.

### Görev ve Amaçlar
1) Proje Sürekliliği: Her oturum başında durum özeti, versiyonlama (v1, v2), diff, anlamlı dosya adları.
2) Veri Analizi: Tanımlayıcı istatistik → Korelasyon/segmentasyon → Hipotez testi → Basit modelleme. Eksik değer stratejisi belirle.
3) Kod Üretimi (Codex): Modüler, açıklamalı, tekrar çalıştırılabilir. Bölümlere ayır: Kurulum, Veri Yükleme, İşleme, Analiz, Görselleştirme, Çıktı.
4) Sunum (GPT‑5 Think): Mini Plan → Sonuçlar → Kanıtlar → Sınırlamalar → Sonraki Adımlar.

### Fırsatçı‑Otomasyon’a Özel İlkeler
- n8n 1.106.3 node sürümleri; $env erişimi yok, $vars kullan.
- Anti‑Scraping Playbook’a sadık kal.
- Supabase tabloları: listings, price_history, notifications, opportunities, ingest_logs.
- Bildirim motoru: median/%diff → notifications → e‑posta.
```

### 2) `gpt_config/actions_openapi.yaml`

```yaml
openapi: 3.1.0
info: { title: Firsatci n8n Actions, version: "1.0.0" }
servers: [ { url: https://ysl-salih.app.n8n.cloud } ]
paths:
  /webhook/smoke-secure:
    post:
      operationId: smokeSecure
      security: [ { n8nApiKey: [] } ]
      responses: { "200": { description: OK } }
  /webhook/firsatci/run:
    post:
      operationId: runFirsatci
      security: [ { n8nApiKey: [] } ]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [mode, city, district, threshold]
              properties:
                mode: { type: string, enum: [full, quick], default: full }
                city: { type: string }
                district: { type: string }
                threshold: { type: number, minimum: 1 }
      responses: { "200": { description: OK }, "401": { description: Unauthorized }, "422": { description: Invalid body } }
components:
  securitySchemes:
    n8nApiKey: { type: apiKey, in: header, name: x-api-key }
```

### 3) `gpt_config/prompts_examples.md`

```markdown
• Antalya/Konyaalti %15 ile firsatci/run tetikle ve sonucu özetle.
• ingest_logs'a son 5 kaydı yazdıran PowerShell testi üret.
• If v2.2 + HttpRequest v4.1 ile median fiyat akışı JSON'unu yaz.
• ScraperAPI fallback’li mini akış JSON'u üret.
```

---

## 📁 /knowledge_base

### 1) `knowledge_base/is_fikri_ozet.md`

```markdown
# İş Fikri Özeti
Bildirim bazlı fırsat avcısı; ilanları toplar, segment medianına göre skorlar, e‑posta ile iletir. Kullanıcı marka/model seçmez; şehir/ilçe ve eşik tanımlar.
```

### 2) `knowledge_base/mvp_detaylari.md`

```markdown
# MVP Detayları
Güvenli webhook → ingest_logs → median/%diff → notifications → e‑posta. n8n orkestrasyon; Supabase veritabanı; opsiyonel Glide UI; GPT açıklama ve Q&A.
```

### 3) `knowledge_base/teknik_mimari.md`

```markdown
# Teknik Mimari
n8n (orkestrasyon) + Supabase (DB) + GPT (analiz). Anti‑scraping için ScraperAPI/Proxy/Playwright fallback katmanları.
```

### 4) `knowledge_base/dataset_aciklama.md`

```markdown
# Dataset Açıklama
- **listings**: ilan detayları (PK: ilan_id)
- **price_history**: fiyat değişimleri (FK → listings.ilan_id)
- **notifications**: fırsat bildirimleri
- **opportunities**: kurala uyan aday kayıtlar
- **ingest_logs**: API giriş logları
```

### 5) `knowledge_base/scraping_risk_senaryolari.md`

```markdown
# Scraping Risk Senaryoları
403/429, captcha, JS-render ihtiyacı, IP engeli, DOM değişikliği. Çözümler: backoff, ScraperAPI, proxy, Playwright, selector bakımı.
```

### 6) `knowledge_base/yasal_uyumluluk_notlari.md`

```markdown
# Yasal Uyumluluk Notları
KVKK: plaka hash; veri minimizasyonu; saklama süreleri sınırlı. TOS/robots’a uyum; gerekirse resmi veri lisanslama seçenekleri değerlendirilir.
```

---

# 🔗 Proje Alanı & GPT Birlikte Çalışma Planı (Uygulama Adımları)

1. **GitHub’da repo’yu** bu içeriklerle oluştur (bugünkü sayfa).
2. **n8n Cloud** → `/n8n_workflows` altındaki 3 JSON’u **Import from file**. **Variables**: `N8N_ACTION_KEY`, `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`.
3. **Supabase Studio** → `/supabase/01_create_ingest_logs.sql` + `/supabase/02_schema_core.sql` + `/supabase/02_create_opportunities.sql` çalıştır.
4. **Proje Alanı (Canvas/Projects)** → `/docs` ve `/knowledge_base` MD’lerini **documentation** olarak ekle; `schema_diagram.png` görselini **Upload files** ile yükle.
5. **Fırsatçı Koçu GPT** → Builder’da:
   - **System message**: `gpt_config/instructions.txt`
   - **Actions**: `gpt_config/actions_openapi.yaml` (auth header: `x-api-key` → `N8N_ACTION_KEY`)
   - **Knowledge**: `/docs` + `/knowledge_base` altındaki tüm MD’ler
6. **Test** → `tests/test_firsatci_api.ps1` ile 200/401 doğrula; Supabase’de `ingest_logs` kayıt oluştuğunu kontrol et.
7. **Faz ilerleme** → Protokol’e göre Faz 2–3–4; median/%diff → notifications → e‑posta; Anti‑Scraping katmanları; GPT üzerinden tetiklemeler.

> Bundan sonra tüm ilerlemeyi **Proje alanında** tutacağız. GPT “Fırsatçı Koçu” o alanın **kalıcı kod asistanı** olacak; her değişikliği ve çıktıyı orada referanslayacağız.

