# Teste Técnico Analista DevOps 🚀 [![CI - CD](https://github.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/actions/workflows/main.yml/badge.svg)](https://github.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/actions/workflows/main.yml)

[![PHP](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php&logoColor=white)](https://www.php.net/) [![Docker](https://img.shields.io/badge/Docker-blue?logo=docker&logoColor=white)](https://www.docker.com/) [![Laravel](https://img.shields.io/badge/Laravel-red?logo=laravel&logoColor=white)](https://laravel.com/) [![Terraform](https://img.shields.io/badge/Terraform-1.x-4C6A86?logo=terraform&logoColor=white)](https://www.terraform.io/) [![AWS](https://img.shields.io/badge/AWS-Amazon%20Web%20Services-orange?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/) [![Nginx](https://img.shields.io/badge/nginx-stable-009639?logo=nginx&logoColor=white)](https://nginx.org/) [![Prometheus](https://img.shields.io/badge/Prometheus-orange?logo=prometheus&logoColor=white)](https://prometheus.io/) [![Grafana](https://img.shields.io/badge/Grafana-latest-F46800?logo=grafana&logoColor=white)](https://grafana.com/) [![Loki](https://img.shields.io/badge/Loki-latest-0f172a?logo=grafana&logoColor=white)](https://grafana.com/oss/loki) ![Kubernetes](https://img.shields.io/badge/K8s-optional-326CE5?logo=kubernetes)

Repositório de teste técnico para Analista DevOps.  
Objetivo:  
- Containerizar uma aplicação simples em PHP seguindo boas práticas para construção da imagem Docker 🐳  
- Criar pipeline de integração contínua (CI) usando GitHub Actions para build, push e checagem de vulnerabilidades da imagem ⚙️🔒  
- Provisionamento de infraestrutura na AWS usando Terraform (IaC) 🏗️🌩️  
- Implantação e entrega da aplicação (CD) no ambiente provisionado integrando as pipelines de CI/CD ✅

---

### Etapa 1: Containerização da Aplicação 🧩

- Build multi-stage: o Composer cria a aplicação e somente os artefatos necessários seguem para a imagem final.
- Imagem de runtime baseada em `php:8.4-fpm-alpine3.22`, com apenas Nginx adicionado.
- Dependências de desenvolvimento, cache do Composer e `.env` não são incluídos na imagem.
- Processo executado como `www-data`, sem privilégios de root, na porta interna `8080`.
- Configurações de produção para PHP, OPcache, PHP-FPM e Nginx.
- Logs enviados para `stdout`/`stderr` e endpoint `/healthz` validando Nginx e PHP-FPM.
- Contexto de build restrito por allowlist no `.dockerignore`.
- A página `/info.php` não usa `phpinfo()`, evitando exposição de módulos, caminhos e variáveis do ambiente.

Para construir e executar localmente:

```bash
docker build --tag teste-devops:local .
APP_KEY="$(docker run --rm --entrypoint php teste-devops:local artisan key:generate --show --no-ansi)"
docker run --rm --read-only \
  --publish 8080:8080 \
  --env "APP_KEY=${APP_KEY}" \
  --tmpfs /tmp \
  --tmpfs /var/cache/nginx:uid=82,gid=82 \
  --tmpfs /var/www/html/storage:uid=82,gid=82 \
  teste-devops:local
```

A chave da aplicação é obrigatória e deve ser fornecida em tempo de execução por um gerenciador de secrets; ela nunca deve ser gravada no Dockerfile ou versionada. Antes do deploy Kubernetes, crie o Secret referenciado pelo manifesto:

```bash
kubectl create secret generic php-app \
  --from-literal="app-key=$(openssl rand -base64 32 | sed 's/^/base64:/')"
```

No ECS, informe ao Terraform o ARN de um secret do AWS Secrets Manager cujo valor seja a `APP_KEY`:

```bash
terraform plan -var='app_key_secret_arn=arn:aws:secretsmanager:REGIAO:CONTA:secret:NOME'
```

---

### Etapa 2: Criação do Pipeline de Integração Contínua (CI) 🤖
Pipeline em GitHub Actions com as etapas principais:
- Checkout do código 📥  
- Login no Docker Hub 🔑  
- Build da imagem com tag baseada no hash do commit 🏷️  
- Push para Docker Hub (versão gerada + `latest`) 📦  
- Checagem de vulnerabilidades com Docker Scout 🔍

---

### Etapa 3: Infraestrutura como Código (IaC) e Implantação (CD) 🏗️➡️🚀
- Usando Terraform para IaC — arquivos em `terraform/` para provisionamento de cluster ECS com Fargate 🧭  
- Backend do Terraform armazenado em um bucket S3 (state remoto) 🗄️  
- Definições de tarefa em `terraform/taskdefinition.tf` com configuração das tasks do ECS 📝  
- Escolha do ECS por ser adequado para uma aplicação única, com suporte a escalabilidade e estabilidade 📈

---

### Pontos Importantes sobre o workflow no GitHub Actions 🔁
O workflow foi configurado para execução manual com alguns inputs:
- Executar build-push da imagem  
  - Se marcado sozinho, executa apenas o job CI 🛠️
- Executar `terraform apply`  
  - Se marcado sozinho, executa apenas o job CD para aplicar infra e implantar a task com a imagem `latest` 🌍
- Executar `terraform destroy`  
  - Se marcado sozinho, executa apenas o destroy para remover o ambiente ⚠️

Executando a pipeline completa: 
- CI --> Iac --> CD (build-push --> terraform apply) 🔗
[![CI -IaC - CD](https://github.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/actions/workflows/main.yml/badge.svg)](https://github.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/actions/workflows/main.yml)

<div align="center">
<img src="https://raw.githubusercontent.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/main/GITHUBACTIONS-CI-IaC-CD-Inputs.png" alt="INPUTS diagram" width="50%" />
<img src="https://raw.githubusercontent.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/main/GITHUBACTIONS-CI-IaC-CD.png" alt="CI-CD diagram" width="100%" />
</div>

---

### Etapa 4: Estratégia de Observabilidade 📊
Para observabilidade e monitoramento propus:
- Grafana para visualização, consultas e alertas 📈  
- Loki para logs da aplicação 🪵  
- Prometheus para métricas e criação de painéis de monitoramento 📡  
- Grafana Tempo para tracing (latência, gargalos) ⏱️
