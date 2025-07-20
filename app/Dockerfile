# Etapa 1: Build do Next.js
FROM node:18-alpine AS builder

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Etapa 2: Runner com app pronto
FROM node:18-alpine AS runner

WORKDIR /app

# Copia arquivos da build
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s CMD wget -q --spider http://localhost:3000 || exit 1

CMD ["npm", "start"]
