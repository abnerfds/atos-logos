# ── Stage 1: Build ───────────────────────────────────────────────────────────
FROM node:24.15.0-alpine3.22 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# GERA O CLIENT DO PRISMA ANTES DO BUILD DO NESTJS
RUN npx prisma generate 
RUN npm run build

# Remove dependências de dev para manter a imagem leve
RUN npm prune --omit=dev

# ── Stage 2: Runtime ──────────────────────────────────────────────────────────
FROM node:24.15.0-alpine3.22 AS runtime

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./package.json
COPY --from=builder --chown=appuser:appgroup /app/prisma ./prisma

USER appuser

EXPOSE 3000

CMD ["node", "dist/main"]