# 🚀 DevOps Challenge Argo - Azure Kubernetes + ACR + Terraform + Helm

Este projeto tem como objetivo demonstrar uma pipeline completa de CI/CD e infraestrutura como código, com deploy automatizado de uma aplicação **Next.js (porta 3000)** no **Azure Kubernetes Service (AKS)**, usando **Azure Container Registry (ACR)**, **Terraform** e **Helm**.

---

## 📁 Estrutura do Projeto

```

.
├── app/                  # Aplicação Next.js
├── terraform/            # IaC com Terraform para provisionar AKS, ACR, etc.
├── helm/                 # Helm chart para deploy no AKS
├── deploy.sh             # Script principal de build, push, deploy e validações
├── destroy.sh            # Script para destruir a infraestrutura criada
└── README.md             # Este arquivo

````

---

## ✅ Pré-requisitos

Você precisa ter instalado no seu ambiente:

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Docker](https://www.docker.com/products/docker-desktop/)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

Além disso, certifique-se de estar logado na Azure CLI:

```bash
az login
az account set --subscription "<NOME_DA_SUA_SUBSCRIÇÃO>"
````

---

## 🔧 Como Executar

### 1. ⏱️ Deploy da Aplicação

Execute o script completo de build e deploy:

```bash
./deploy.sh
```

Esse script fará:

* Validação de ferramentas
* Build e teste local da imagem Next.js
* Push da imagem para o Azure Container Registry (ACR)
* Provisionamento de infraestrutura com Terraform (AKS, ACR, VNet, etc)
* Deploy da aplicação com Helm no AKS
* Abertura automática da aplicação no navegador (caso IP esteja disponível)

---

### 2. 🌐 Acesso à aplicação

Após o deploy, a aplicação estará disponível no endereço retornado no final do `deploy.sh`, algo como:

```
🌍 Aplicação disponível em: http://<EXTERNAL_IP>:3000
```

---

### 3. 🗑️ Destruir Infraestrutura

Para destruir todos os recursos provisionados, execute:

```bash
./destroy.sh
```

Esse script removerá:

* Helm release
* Recursos provisionados pelo Terraform
* Imagem do ACR (opcional)
* Container local antigo

---

## 🔍 Testes Locais

Antes de realizar o deploy completo, você pode executar testes rápidos localmente:

### Testar aplicação local com Docker

```bash
cd app
docker build -t test-app .
docker run -p 8080:3000 test-app
# Verifique em : http://localhost:8080
docker stop $(docker ps -q --filter ancestor=test-app)
cd ..
```

### Validar os manifests do Helm

```bash
helm lint ./helm
helm template ./helm
```

### Validar a infraestrutura com Terraform

```bash
cd terraform
terraform init
terraform validate
terraform plan
cd ..
```

---

## ⚙️ Customizações

Você pode ajustar variáveis no topo do `deploy.sh`:

```bash
IMAGE_NAME="devops-app"
IMAGE_TAG="v1"
ACR_NAME="acrdevopschallenge"
AKS_NAME="aksdevopschallenge"
RG_NAME="rg-devops"
LOCAL_PORT=8080
```

---

## 📦 Sobre a Aplicação

A aplicação localizada em `app/` é uma aplicação básica em **Next.js**, rodando por padrão na porta **3000**.

---

## 💡 Decisões Técnicas

* **Next.js com Docker:** Utilizado multi-stage build para reduzir o tamanho da imagem final.
* **ACR + AKS:** Integração direta e segura para distribuição de containers.
* **Terraform:** Infraestrutura como código para manter reprodutibilidade.
* **Helm:** Gerenciamento simplificado de configurações e deploys.
* **Shell Script (deploy.sh):** Pipeline local automatizada com validações, retries e logs.

---

## 📌 Notas Adicionais

* Caso veja erro `ImagePullBackOff`, assegure que o AKS tenha permissão com:

```bash
az aks update --name $AKS_NAME --resource-group $RG_NAME --attach-acr $ACR_NAME
```

* O Terraform pode requerer importação de recursos já existentes:

```bash
terraform import azurerm_resource_group.rg /subscriptions/<id>/resourceGroups/<rg-name>
```

---

## 👨‍💻 Autor

**Danylo Oliveira**
Projeto para desafio técnico DevOps da Argo.

