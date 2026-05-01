#!/usr/bin/env bash
# Script de deploy para Oracle Cloud (usuário: deploy)
# Uso: ./deploy.sh [branch]

set -euo pipefail

BRANCH="${1:-main}"
APP_DIR="$(cd "$(dirname "$0")/atos-logos-backend" && pwd)"

echo "==> Atualizando código (branch: $BRANCH)..."
git -C "$(dirname "$0")" pull origin "$BRANCH"

echo "==> Acessando diretório da API..."
cd "$APP_DIR"

echo "==> Verificando arquivo .env..."
if [[ ! -f .env ]]; then
  echo "ERRO: arquivo .env não encontrado em $APP_DIR"
  echo "Copie .env.example para .env e preencha os valores."
  exit 1
fi

echo "==> Parando containers existentes..."
docker compose -f docker-compose.prod.yml down

echo "==> Subindo containers com rebuild..."
docker compose -f docker-compose.prod.yml up -d --build

echo "==> Aguardando banco ficar pronto..."
sleep 5

echo "==> Rodando migrations Prisma..."
docker compose -f docker-compose.prod.yml exec api npx prisma migrate deploy

echo "==> Deploy concluído."
docker compose -f docker-compose.prod.yml ps
