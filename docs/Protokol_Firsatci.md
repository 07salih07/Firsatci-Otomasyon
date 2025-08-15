# Fırsatçı Protokol (n8n + Supabase) — Cloud v1.106.3

## Amaç
- Güvenli Webhook → (If) x-api-key → (HttpRequest) Supabase insert → (Respond).
- $env **kullanma**; Cloud’da engelli. Daima **$vars** kullan.
- HttpRequest v4.1 başlıkları **headerParametersUi.parameter** dizisinde.

## Sürüm Kilitleri
- n8n: **1.106.3**
- Webhook: **v2.1** (httpMethod=POST, responseMode=responseNode)
- If: **v2.2** (conditions.options.version=2)
- RespondToWebhook: **v1.5**
- HttpRequest: **v4.1**

## Variables (n8n → Settings → Variables)
- `N8N_ACTION_KEY` (örn. n8nsalih)
- `SUPABASE_URL` (https://<PROJECT_REF>.supabase.co)
- `SUPABASE_SERVICE_KEY` (service_role JWT — sadece n8n)

## Hata→Çözüm
- **401**: x-api-key eksik/yanlış → If koşulu + $vars.N8N_ACTION_KEY.
- **422**: Respond JSON hatalı → `={{ ({ ... }) }}` biçimi.
- **403/429**: Anti-scraping → backoff + ScraperAPI/Proxy/Playwright.
- **Timeout**: Respond var mı? Payload boyutu? Üstel backoff + jitter.

## Güvenlik/Hukuk
- KVKK uyumu; plaka hash; TOS/robots.
