# MVP Uygulama Akışı
1. **Webhook (POST /webhook/firsatci/run)**
2. **If (x-api-key)** → doğruysa devam, değilse **401**
3. **HttpRequest (Supabase insert: ingest_logs)** → `mode/city/district/
threshold/payload`
4. **Respond 200** → `{ ok: true, echo: body }`
5. (Faz 2) `median/%diff` hesapla → **notifications** kaydı
6. (Faz 3) e‑posta ile bildir
