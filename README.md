# Fırsatçı Otomasyon (n8n + Supabase + GPT)

Güvenli webhook → key kontrol → Supabase'e log → JSON yanıt.  
Sürüm kilitleri: n8n 1.106.3 (Webhook v2.1, If v2.2, Respond v1.5, HttpRequest v4.1).  
**$env kullanma, $vars kullan.**

## Hızlı Başlangıç
1) Supabase Studio → `/supabase/01_create_ingest_logs.sql` ve `02_schema_core.sql` çalıştır.
2) n8n Cloud → `/n8n_workflows` altındaki 3 JSON’u Import from file.
3) n8n → Settings → Variables:
   - `N8N_ACTION_KEY` (örn. `n8nsalih`)
   - `SUPABASE_URL` → `https://<PROJECT_REF>.supabase.co`
   - `SUPABASE_SERVICE_KEY` → service_role JWT (SADECE n8n’de)
4) `tests/test_firsatci_api.ps1` ile 200/401 testleri.

## Klasörler
- docs/ → protokol, anti-scraping, planlar
- n8n_workflows/ → JSON akışları
- supabase/ → SQL şema ve tablolar
- tests/ → PowerShell testleri
- gpt_config/ → GPT Instructions ve Actions (OpenAPI)
- knowledge_base/ → GPT knowledge içeriği
# Firsatci-Otomasyon
