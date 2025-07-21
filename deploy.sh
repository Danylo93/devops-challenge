#!/bin/bash

set -eo pipefail

echo "🔧 Iniciando pipeline DevOps Challenge..."

### VARIÁVEIS ###
IMAGE_NAME="devops-app"
IMAGE_TAG="v1"
ACR_NAME="acrdevopschallenge"
ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
AKS_NAME="aksdevopschallenge"
RG_NAME="rg-devops"
LOCAL_PORT=8080

### 1. Pré-requisitos ###
for cmd in az docker kubectl helm terraform; do
  if ! command -v $cmd &>/dev/null; then
    echo "❌ Comando '$cmd' não encontrado. Instale antes de continuar."
    exit 1
  fi
done

### 2. Build da imagem Docker ###
echo "🐳 Buildando imagem $IMAGE_NAME:$IMAGE_TAG"
cd app
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Validação local
docker rm -f ${IMAGE_NAME}-container >/dev/null 2>&1 || true
docker run -d -p ${LOCAL_PORT}:3000 --name ${IMAGE_NAME}-container $IMAGE_NAME:$IMAGE_TAG
sleep 5
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${LOCAL_PORT})
docker rm -f ${IMAGE_NAME}-container
cd ..
[[ "$HTTP_CODE" == "200" ]] && echo "✅ Página local OK" || { echo "❌ Página local falhou (HTTP $HTTP_CODE)"; exit 1; }

### 3. Envio para o ACR ###
echo "🔐 Logando no ACR e enviando imagem..."
az acr login --name $ACR_NAME
docker tag $IMAGE_NAME:$IMAGE_TAG $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
echo "✅ Imagem enviada para $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"

### 4. Infra com Terraform ###
echo "🌍 Infraestrutura com Terraform"
cd terraform
terraform init -input=false
terraform validate
terraform plan -out=tfplan || true

# Importar RG caso já exista
if terraform plan -out=tfplan | grep -q "already exists"; then
  echo "⚠️ Importando resource group existente..."
  terraform import azurerm_resource_group.rg /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_NAME
fi

terraform apply -auto-approve tfplan
cd ..

### 5. Role AcrPull (garantir) ###
echo "🔑 Garantindo permissão de pull no ACR para o AKS..."
AKS_PRINCIPAL_ID=$(az aks show -g $RG_NAME -n $AKS_NAME --query "identity.principalId" -o tsv)
ACR_ID=$(az acr show --name $ACR_NAME --query id -o tsv)
az role assignment create --assignee "$AKS_PRINCIPAL_ID" --role "AcrPull" --scope "$ACR_ID" || true

### 6. Deploy com Helm ###
echo "⛵ Deploy com Helm"
az aks get-credentials --resource-group $RG_NAME --name $AKS_NAME --overwrite-existing
helm lint ./helm
helm upgrade --install $IMAGE_NAME ./helm \
  --set image.repository=$ACR_LOGIN_SERVER/$IMAGE_NAME \
  --set image.tag=$IMAGE_TAG \
  --set image.pullPolicy=Always \
  --wait --timeout 5m || {
    echo "⚠️ Retry do Helm após 10 segundos..."
    sleep 10
    helm upgrade --install $IMAGE_NAME ./helm \
      --set image.repository=$ACR_LOGIN_SERVER/$IMAGE_NAME \
      --set image.tag=$IMAGE_TAG \
      --set image.pullPolicy=Always \
      --wait --timeout 5m
  }

### 7. Forçar novos pods para pegar imagem ###
echo "♻️ Deletando pods antigos para forçar novo pull"
kubectl delete pod -l app=$IMAGE_NAME || true
sleep 10

### 8. Verificação final ###
echo "🔍 Verificando pods e IP externo..."
kubectl rollout status deployment/$IMAGE_NAME
kubectl get pods -l app=$IMAGE_NAME

EXTERNAL_IP=""
for i in {1..10}; do
  EXTERNAL_IP=$(kubectl get svc $IMAGE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  [[ -n "$EXTERNAL_IP" ]] && break
  echo "⌛ Aguardando IP externo... [$i/10]"
  sleep 10
done

if [[ -n "$EXTERNAL_IP" ]]; then
  echo "🌍 Aplicação disponível em: http://$EXTERNAL_IP"
  if which xdg-open >/dev/null; then xdg-open http://$EXTERNAL_IP; fi
else
  echo "⚠️ IP externo não disponível ainda. Verifique o serviço:"
  kubectl get svc $IMAGE_NAME
fi

echo "✅ Pipeline finalizada com sucesso!"
