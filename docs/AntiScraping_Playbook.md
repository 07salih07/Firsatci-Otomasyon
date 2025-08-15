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
