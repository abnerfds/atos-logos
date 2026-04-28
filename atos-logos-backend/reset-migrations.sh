#!/bin/bash

# Script para resetar e reaplicar migrations após renomeação
# Execute este script após iniciar o banco de dados

echo "🔄 Resetando banco de dados e reaplicando migrations..."
echo ""

# Inicia o banco de dados se não estiver rodando
echo "📦 Verificando Docker..."
if ! docker ps | grep -q atos_logos_db; then
  echo "🚀 Iniciando banco de dados..."
  docker compose up -d
  echo "⏳ Aguardando banco inicializar (5 segundos)..."
  sleep 5
fi

# Reseta o banco e aplica todas as migrations
echo "🗑️  Resetando banco de dados..."
npx prisma migrate reset --force

echo ""
echo "✅ Migrations reaplicadas com sucesso!"
echo ""
echo "📋 Migrations aplicadas:"
ls -1 prisma/migrations/ | grep -v migration_lock.toml

echo ""
echo "🎉 Pronto! Banco de dados resetado com nomenclatura correta."
