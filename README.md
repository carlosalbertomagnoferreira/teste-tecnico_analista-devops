# Teste Tecnico Analista Devops
Repositorio para teste tecnico analista devops, com uma aplicação simples PHP, Docker e pipeline Ci-CD


### Etapa 1: Containerização da Aplicação   
Dockerfile configurado para uma aplicação simples do PHP com Laravel, pois não recebi o link git da aplicação.

Dockerfile usando imagem php:8.3-fpm-alpine3.22 otimizada com poucos pacotes e poucas vulnerabilidades.

Executado apk update && apk upgrade para corrigir algumas vulneradilidades.

Para funcionamento da aplicação foi instalado o nginx e configurado para iniciar com o container.

Adicionado HEALTHCHECK.


### Etapa 2: Criação do Pipeline de Integração Contínua (CI)
Pipeline de CI realizando as actions de checkout do codigo, build da imagem e push para docker hub e checagem de vulnerabilidades com docker scout.

### Etapa 3: Infraestrutura como Código (IaC) e Implantação (CD)
Na pasta terraform constam os arquivos tf para provisionamento de um cluster ECS com Fargate, o backend do terraform fica armazenado em um bucket no S3, e na pasta task-definitions dentro da terraform consta o task.jon com a definição da tarefa.
Foi implementado ECS devido ser para uma unica aplicaçao, para uma unica aplicação o ECS vai dar suporte suficiente para escalabilidade, estabilidade e agilidade na entrega.

Apos o push na branch main é iniciado o processo de CI, realizando todo o processe descrito acima, apos finalizado o CI é iniciado o CD que faz o provisionamento do ECS e disponibiliza a aplicação para acesso.

### Etapa 4: Estratégia de Observabilidade
Para as principais metricas de observabilidade usaria o Grafana para centralizar a visualização, consultas e alertas, sendo:
- Loki para logs da aplicação   
- Prometheus para as metricas e criar paineis de monitoramento.
- Grafana Tempo para tracing do tempo de resposta de requisição, gargalos e latencia.