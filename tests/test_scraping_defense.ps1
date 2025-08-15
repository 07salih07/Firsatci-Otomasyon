param([int]$Status=200,[string]$Body="ok")
$blocked=($Status -eq 403 -or $Status -eq 429 -or
$Body.ToLower().Contains("captcha") -or $Body.Length -lt 200)
if($blocked){"DETECTED: anti-scraping. Strategy → backoff + fallback
(ScraperAPI → Proxy → Playwright)"}else{"OK: proceed normal path"}
