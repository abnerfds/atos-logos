#!/bin/bash
cd /home/deploy/apps/atos-logos

echo "🚀 Iniciando Deploy..."

# 1. Atualiza as imagens
docker compose pull

# 2. Garante que o banco está de pé antes de migrar
docker compose up -d db
echo "⏳ Aguardando banco de dados estabilizar..."
sleep 5 

# 3. Roda a migração
echo "🔄 Aplicando Migrations..."
docker compose run --rm api npx prisma migrate deploy

# 4. Sobe/Atualiza a API
echo "🆙 Subindo a API..."
docker compose up -d api

# 5. Limpeza
docker image prune -f
echo "✅ Deploy finalizado com sucesso!"