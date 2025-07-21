#!/bin/bash

set -eo pipefail

echo "🧨 Iniciando destruição do ambiente DevOps Challenge..."

### VARIÁVEIS ###
IMAGE_NAME="devops-app"
IMAGE_TAG="v1"
ACR_NAME="acrdevopschallenge"
ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
AKS_NAME="aksdevopschallenge"
RG_NAME="rg-devops"
RELEASE_NAME="devops-app"

### 1. Remover deployment do Helm ###
echo "⛵ Removendo deploy do Helm..."
az aks get-credentials --name $AKS_NAME --resource-group $RG_NAME --overwrite-existing
helm uninstall $RELEASE_NAME || echo "⚠️ Helm release não encontrado ou já removido"

### 2. Remover serviços no AKS (opcional) ###
echo "🧹 Limpando recursos no AKS..."
kubectl delete svc $IMAGE_NAME --ignore-not-found
kubectl delete deployment $IMAGE_NAME --ignore-not-found

### 3. Remover infraestrutura com Terraform ###
echo "🌍 Destruindo infraestrutura com Terraform..."
cd terraform
terraform init -upgrade -input=false
terraform destroy -auto-approve
cd ..

### 4. Remover imagem do ACR (opcional) ###
echo "🗑️ Removendo imagem do ACR..."
#az acr repository delete --name $ACR_NAME --image $IMAGE_NAME:$IMAGE_TAG --yes || echo "⚠️ Imagem não encontrada no ACR"

### 5. Remover container e imagem local ###
echo "🗑️ Limpando Docker local..."
docker stop ${IMAGE_NAME}-container >/dev/null 2>&1 || true
docker rm ${IMAGE_NAME}-container >/dev/null 2>&1 || true
docker rmi $IMAGE_NAME:$IMAGE_TAG >/dev/null 2>&1 || true

echo "✅ Destruição concluída com sucesso!"
