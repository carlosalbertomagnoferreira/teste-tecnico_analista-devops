# Teste Técnico — Analista DevOps (segundo README)

![GitHub Workflow Status](https://github.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/actions/workflows/main.yml/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/magnocarlos1988/teste-tecnico_analista-devops?logo=docker)
![Terraform](https://img.shields.io/badge/Terraform-present-5A9FDD?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-required-FF9900?logo=amazonaws)
![Kubernetes](https://img.shields.io/badge/K8s-optional-326CE5?logo=kubernetes)
![PHP](https://img.shields.io/badge/PHP-8.4-blue?logo=php)
![Composer](https://img.shields.io/badge/Composer-present-2F3A6F?logo=composer)
![Nginx](https://img.shields.io/badge/Nginx-present-009639?logo=nginx)

## Estrutura de arquivos do projeto

Abaixo está a estrutura principal do repositório e a finalidade de cada arquivo/pasta:

```
Dockerfile                     # Imagem multi-stage: composer -> php:8.4-fpm-alpine
info.php                       # Página de informação PHP (copiada para public/info.php)
README.md                      # README principal do projeto
README-SECOND.md               # Este arquivo adicional
.github/workflows/main.yml     # Workflow GitHub Actions (CI / IaC / CD)

docker/                        # Configs e scripts para imagem
  nginx/nginx.conf             # Configuração do Nginx usada na imagem
  php-fpm/entrypoint.sh        # Entrypoint/startup do container

k8s/
  deploy_svc.yaml              # Manifest para deploy/service no Kubernetes
  game_2048.yaml               # Manifest adicional da aplicação (game)

ECS-Tasks/
  task-game.json               # Task definition usada no deploy ECS via Actions

terraform/                     # Infraestrutura como código (Terraform)
  backend.tf                   # Backend (estado remoto)
  vpc.tf                       # VPC / rede
  iam.tf                       # Papéis/Policy IAM
  ecs.tf                       # Cluster/recursos ECS
  service.tf                   # Serviço ECS
  taskdefination.tf            # Task Definition (integra com task-definitions/task.json)
  variables.tf                 # Variáveis do Terraform
  task-definitions/php.json    # Task JSON usado por Terraform/GitHub Actions
  task-definitions/game.json   # Task JSON usado por Terraform/GitHub Actions
```

## Pré-requisitos

- Docker (para build local da imagem)
- Docker Hub account (para push, opcional)
- Terraform (versão compatível com os arquivos do diretório `terraform`)
- AWS CLI (ou credenciais AWS configuradas)
- kubectl (se for usar os manifests em `k8s/`)

Exportar credenciais AWS para execução local do Terraform (exemplo):

```zsh
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_REGION="us-east-1"
```

Ou configure via `aws configure`.

## Execução local — Build e run da imagem Docker

1. Build da imagem (local):

```zsh
docker build -t magnocarlos1988/teste-tecnico_analista-devops:local -f Dockerfile .
```

2. Rodar container (mapeando a porta 8080 -> 80):

```zsh
docker run --rm -p 8080:80 magnocarlos1988/teste-tecnico_analista-devops:local
```

A aplicação estará acessível em http://localhost:8080 (dependendo do entrypoint/NGINX dentro da imagem).

Observação: o Dockerfile monta uma imagem multi-stage com Laravel gerado via Composer e usa php-fpm + nginx; o container exige que o `entrypoint.sh` configure serviços corretamente — ver `docker/php-fpm/entrypoint.sh`.

## Execução local — Terraform (IaC)

Entrar na pasta `terraform` e rodar os comandos abaixo:

```zsh
cd terraform
terraform init
terraform validate
terraform plan -out=tfplan.tfout
terraform apply -auto-approve tfplan.tfout
```

Para destruir a infra:

```zsh
terraform plan -destroy -out=tfplandestroy
terraform apply -destroy -auto-approve tfplandestroy
```

Notas:
- As configurações usam AWS; confirme a existência do backend definido em `backend.tf` e das permissões IAM corretas.
- O workflow do GitHub altera o `task-definitions/task.json` para substituir a tag `latest` pelo hash da build quando o input `docker-build-push-image` estiver ativo.

## Deploy via GitHub Actions (CI / IaC / CD)

O workflow principal está em `.github/workflows/main.yml` e pode ser disparado manualmente via "Run workflow" no GitHub (workflow_dispatch). Os inputs disponíveis:

- `docker-build-push-image` (boolean) — build & push da imagem Docker
- `terraform-apply` (boolean) — executa `terraform plan/apply`
- `terraform-destroy` (boolean) — executa `terraform plan -destroy` e `terraform apply -destroy`
- `deploy-to-ecs` (boolean) — faz deploy no ECS com a task `ECS-Tasks/task-game.json`
- `deploy-to-k8s` (boolean) — faz deploy no Kubernetes (usa `KUBE_CONFIG` no secrets)

Requisitos para o workflow funcionar corretamente:
- Secrets no repositório: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `DOCKERHUB_TOKEN`.
- Variáveis: `DOCKERHUB_USERNAME` e `AWS_REGION` (ou definidas como GitHub vars/secrets conforme o workflow).
- Para deploy em Kubernetes: secret `KUBE_CONFIG` contendo o kubeconfig base64/plain conforme esperado pelo step `azure/k8s-set-context`.
