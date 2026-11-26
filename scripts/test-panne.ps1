# Test de continuité : arrête une instance de l'Auto Scaling Group et vérifie
# que l'application reste disponible pendant que l'ASG la remplace.
param(
    [string]$Env = "dev",
    [int]$DurationSeconds = 240
)

$url = terraform -chdir="environments/$Env" output -raw alb_url
$asg = terraform -chdir="environments/$Env" output -raw asg_name

$victim = aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asg `
    --query "AutoScalingGroups[0].Instances[0].InstanceId" --output text
Write-Host "Arrêt de l'instance $victim ..." -ForegroundColor Yellow
aws ec2 stop-instances --instance-ids $victim | Out-Null

$ok = 0; $ko = 0
$end = (Get-Date).AddSeconds($DurationSeconds)
while ((Get-Date) -lt $end) {
    $t = Get-Date -Format "HH:mm:ss"
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive -TimeoutSec 5
        $id = if ($r.Content -match '(i-[0-9a-f]{8,17})') { $Matches[1] } else { "?" }
        Write-Host "$t  HTTP $($r.StatusCode)  $id"
        $ok++
    } catch {
        Write-Host "$t  ERREUR" -ForegroundColor Red
        $ko++
    }
    Start-Sleep -Seconds 5
}

Write-Host "`nRequêtes réussies : $ok / $($ok + $ko)"
Write-Host "Instances de l'ASG après le test :"
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asg `
    --query "AutoScalingGroups[0].Instances[].[InstanceId,AvailabilityZone,HealthStatus,LifecycleState]" --output table
