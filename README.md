# DevOps Challenge

## Como Executar

### App local
```bash
cd app
docker build -t devops-app .
docker run -p 8080:80 devops-app


- ✅ Docker multi-stage build para imagens otimizadas
- ✅ Variáveis de ambiente expostas via Helm (values.yaml)
- ✅ ConfigMap para valores não sensíveis
- ✅ Secret com senha codificada em base64
- ✅ Liveness/Readiness Probes via Helm (health check)