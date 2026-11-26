# Crée le bucket du backend Terraform (étape 0, avant bootstrap/).
# Learner Lab : la ressource Terraform aws_s3_bucket est bloquée par le SCP
# (s3:GetBucketObjectLockConfiguration), d'où la création par AWS CLI.
param(
    [string]$ProjectName = "cloud5",
    [string]$Region = "us-east-1"
)

$AccountId = aws sts get-caller-identity --query Account --output text
$Bucket = "$ProjectName-tfstate-$AccountId"

aws s3api head-bucket --bucket $Bucket 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Bucket $Bucket existe déjà."
} else {
    aws s3api create-bucket --bucket $Bucket --region $Region
    Write-Host "Bucket $Bucket créé."
}
