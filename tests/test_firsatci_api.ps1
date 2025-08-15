param([string]$Url="https://ysl-salih.app.n8n.cloud/webhook/firsatci/run",
[string]$ApiKey="n8nsalih",[string]$City="Antalya",[string]
$District="Konyaalti",[int]$Threshold=15)
$hdrs=@{'x-api-key'=$ApiKey};
$body=@{mode='full';city=$City;district=$District;threshold=$Threshold}|
ConvertTo-Json -Compress
try{(Invoke-RestMethod -Method Post -Uri $Url -Headers $hdrs -Body $body -
ContentType 'application/json' -ErrorAction Stop)|ConvertTo-Json -Compress}
catch{$r=$_.Exception.Response;if($r -is
[System.Net.Http.HttpResponseMessage]){"STATUS="+[int]$r.StatusCode;
$r.Content.ReadAsStringAsync().GetAwaiter().GetResult()}elseif($r){"STATUS="+
[int]$r.StatusCode;(New-Object
IO.StreamReader($r.GetResponseStream())).ReadToEnd()}else{$_|Out-String}}
