# Copie les identifiants Learner Lab (renouvelés à chaque session) dans les
# secrets GitHub utilisés par le pipeline. Aucun secret n'est écrit sur disque.
# Prérequis : GitHub CLI (gh) installé et connecté (gh auth login),
#             aws configure à jour avec les identifiants de la session.

$ErrorActionPreference = "Stop"

$keys = @{
    "AWS_ACCESS_KEY_ID"     = (aws configure get aws_access_key_id)
    "AWS_SECRET_ACCESS_KEY" = (aws configure get aws_secret_access_key)
    "AWS_SESSION_TOKEN"     = (aws configure get aws_session_token)
}

foreach ($name in $keys.Keys) {
    if ([string]::IsNullOrWhiteSpace($keys[$name])) {
        throw "Valeur manquante pour $name : lancer d'abord aws configure."
    }
    $keys[$name] | gh secret set $name
    Write-Host "Secret $name mis à jour."
}

Write-Host "Vérification de l'identité AWS :"
aws sts get-caller-identity --query Arn --output text
