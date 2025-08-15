param([string]$SupabaseUrl="https://<PROJECT_REF>.supabase.co",[string]
$ServiceKey="SERVICE_ROLE_JWT")
$u="$SupabaseUrl/rest/v1/ingest_logs"
$h=@{"apikey"=$ServiceKey;"Authorization"="Bearer $ServiceKey";"ContentType"="application/json";"Prefer"="return=representation"}
$b=@{mode='full';city='Antalya';district='Konyaalti';threshold=15;payload=@{hello='world'}}|
ConvertTo-Json -Compress
try{(Invoke-RestMethod -Method Post -Uri $u -Headers $h -Body $b -ErrorAction
Stop)|ConvertTo-Json -Compress}catch{$r=$_.Exception.Response;if($r)
{"STATUS="+[int]$r.StatusCode;(New-Object
IO.StreamReader($r.GetResponseStream())).ReadToEnd()}else{$_|Out-String}}
