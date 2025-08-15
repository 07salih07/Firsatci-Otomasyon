# Anti-Scraping Playbook (Crawl → Walk → Run)
1) Politeness: UA rotation, Accept-Language, Referer, 1–6sn gecikme, düşük concurrency.
2) Detection: 403/429, body'de `captcha|recaptcha|please enable javascript|access denied`, body < 200B.
3) Fallback A: ScraperAPI (`render=true`).
4) Fallback B: Residential proxy (IP bazlı engellerde).
5) Fallback C: Playwright (+2Captcha opsiyonel), human-like davranış.
6) Circuit breaker: üstel backoff + jitter; 10 ardışık hata → frekans 3× düş, alarm.

KPI: başarı %, 403/429 %, ort. süre, fırsat precision.  Etik/Hukuk: KVKK, TOS/robots.
