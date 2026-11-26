# Test de sécurité : la base RDS ne doit pas être joignable depuis Internet.
param([string]$Env = "dev")

$db = terraform -chdir="environments/$Env" output -raw db_endpoint
Write-Host "Endpoint RDS : $db"

Write-Host "`nRésolution DNS (doit donner une IP privée 10.x.x.x) :"
Resolve-DnsName $db -Type A | Select-Object Name, IPAddress | Format-Table -AutoSize

Write-Host "Connexion TCP 3306 depuis ce poste :"
$res = Test-NetConnection -ComputerName $db -Port 3306 -WarningAction SilentlyContinue
if ($res.TcpTestSucceeded) {
    Write-Host "ECHEC : la base est accessible depuis Internet !" -ForegroundColor Red
} else {
    Write-Host "OK : accès refusé, la base n'est pas joignable depuis Internet." -ForegroundColor Green
}

Write-Host "`nAttribut PubliclyAccessible :"
aws rds describe-db-instances --db-instance-identifier "cloud5-$Env-db" `
    --query "DBInstances[0].PubliclyAccessible" --output text
