# Fırsatçı Protokol (n8n + Supabase) — Cloud v1.106.3

## Amaç
- Güvenli **Webhook** → **If (x-api-key)** → **HttpRequest (Supabase insert)** → **Respond to Webhook** akışını kurmak.
- **$env kullanma** (Cloud’da engelli). Daima **$vars** kullan (n8n → Settings → Variables).
- HttpRequest **v4.1**'de header'lar **headerParametersUi.parameter** dizisiyle verilmelidir.

## Sürüm Kilitleri (n8n Cloud 1.106.3 ile uyumlu)
- Webhook: **v2.1** (`httpMethod=POST`, `responseMode=responseNode`)
- If: **v2.2** (`conditions.options.version=2`)
- RespondToWebhook: **v1.5**
- HttpRequest: **v4.1**

## Gerekli Variables (n8n → Settings → Variables)
- `N8N_ACTION_KEY` → örn. `n8nsalih`
- `SUPABASE_URL` → `https://<PROJECT_REF>.supabase.co`
- `SUPABASE_SERVICE_KEY` → **service_role** JWT (yalnız n8n’de saklanır)

## Hata → Çözüm
- **401 Unauthorized**: `x-api-key` eksik/yanlış → **If** koşulunu ve `$vars.N8N_ACTION_KEY` değerini kontrol et.
- **422 Invalid JSON**: Respond gövdesindeki JSON ifade hatalı → `={{ ({ ... }) }}` kalıbı ile saf obje dön.
- **403/429**: Anti-scraping → backoff + ScraperAPI/Proxy/Playwright (bkz. AntiScraping_Playbook.md).
- **Timeout**: Respond node var mı? Payload küçük mü? Üstel backoff + jitter kullan.

## Güvenlik ve KVKK
- Plaka gibi kişisel veriler **hash**'lenerek tutulmalı. Veri minimizasyonu, saklama süreleri sınırlı olmalı.
- robots.txt / ToS politikalarına saygı.
