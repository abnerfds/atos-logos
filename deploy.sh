#!/bin/bash
cd /home/deploy/apps/atos-logos

# 1. Baixa a nova imagem do OCI Registry
docker compose pull api

# 2. Roda a migração em contêiner temporário e o descarta ao final
docker compose run --rm api npx prisma migrate deploy

# 3. Sobe a aplicação principal de forma destacada
docker compose up -d --no-deps api

# 4. Remove imagens antigas soltas para não lotar o disco da VM
# docker image prune -f