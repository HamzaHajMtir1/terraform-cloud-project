# Test de répartition de charge : interroge l'ALB plusieurs fois et compte
# les réponses par instance. Résultat attendu : au moins deux instances.
param(
    [string]$Env = "dev",
    [int]$Count = 20
)

$url = terraform -chdir="environments/$Env" output -raw alb_url
Write-Host "URL : $url"

$ids = for ($i = 1; $i -le $Count; $i++) {
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive -TimeoutSec 10
    if ($r.Content -match '(i-[0-9a-f]{8,17})') { $Matches[1] }
}

$ids | Group-Object | Select-Object @{n = "Instance"; e = { $_.Name } }, Count | Format-Table -AutoSize
$n = ($ids | Sort-Object -Unique).Count
if ($n -ge 2) { Write-Host "OK : $n instances différentes ont répondu." -ForegroundColor Green }
else { Write-Host "ECHEC : une seule instance a répondu." -ForegroundColor Red }
