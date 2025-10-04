# Teste Tecnico Analista Devops [![CI - CD](https://github.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/actions/workflows/main.yml/badge.svg)](https://github.com/carlosalbertomagnoferreira/teste-tecnico_analista-devops/actions/workflows/main.yml)
Repositorio de teste tecnico para analista devops.   
Objetivo:   
Containerizar uma aplicação simples em PHP seguindo boas praticas para construção da imagem docker   
Criar pipeline de integração continua (CI) usando o Github Actions para fazer build, push e checagem de vulnerabilidades da imagem   
Provisionamento de infraestrutura na AWS para implantação da aplicação usando Terraform para IaC   
Implantação e entrega da aplicação (CD) no ambiente provisionado integrando as pipelines de CI-CD

### Etapa 1: Containerização da Aplicação   
Dockerfile configurado para uma aplicação simples do PHP com Laravel.   
Imagem usada: php:8.3-fpm-alpine3.22 otimizada com poucos pacotes e poucas vulnerabilidades.   
Executado apk update && apk upgrade para corrigir algumas vulneradilidades.   
Para funcionamento da aplicação foi instalado o nginx e configurado para iniciar com o container.   
Adicionado HEALTHCHECK com o php-fpm-healthcheck.

### Etapa 2: Criação do Pipeline de Integração Contínua (CI)
Pipeline de CI com o Github Actions realizando as actions:   
Checkout do codigo;   
Login no Docker Hub;   
Build da imagem com a tag baseada no hash do commit;   
Push para docker hub da versão gerada e tambem a latest   
Realiza checagem de vulnerabilidades com docker scout.

### Etapa 3: Infraestrutura como Código (IaC) e Implantação (CD)
Usando o Terraform para Iac, na pasta terraform constam os arquivos tf para provisionamento de um cluster ECS com Fargate.   
O backend do terraform fica armazenado em um bucket no S3, e na pasta task-definitions dentro da terraform consta o task.jon com a definição da tarefa para implantação no ECS.   
Foi implementado ECS devido ser para uma unica aplicaçao simples, o ECS vai dar suporte suficiente para escalabilidade, estabilidade e agilidade na entrega.

### Pontos Importantes sobre o workflow feito no GitHub Actions
O workflow foi configurado para ser executado manualmente com alguns inputs, sendo:   
- Executar build-push da imagem   
  - Com apenas esse imput marcado será executado apenas o job CI   
- Executar terraform apply   
  - Com apenas esse imput marcado, apenas o job CD ira ser executado com o apply para implantar o cluster ECS e a task com a versão latest da imagem   
- Executar terraform destroy   
  - Se marcado sozinho deve executar o destroy do ECS implantado.   

Tambem é possivel fazer a combinação:
  - CI --> CD   
    - build-push --> terraform apply

<img src="GITHUBACTIONS-CI-CD.png ">

### Etapa 4: Estratégia de Observabilidade
Para as principais metricas de observabilidade usaria o Grafana para centralizar a visualização, consultas e alertas, sendo:
- Loki para logs da aplicação   
- Prometheus para as metricas e criar paineis de monitoramento.
- Grafana Tempo para tracing do tempo de resposta de requisição, gargalos e latencia.
