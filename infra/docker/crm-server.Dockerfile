# Qura-crm-server (Express + Prisma). Rebuilds dist/ from source rather than
# trusting the committed dist/.
FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
WORKDIR /app

COPY package.json package-lock.json ./
COPY prisma ./prisma
# Dev deps are kept: the Prisma CLI is needed at start for `db push`.
RUN npm ci --include=dev --ignore-scripts --no-audit --no-fund

COPY . .
RUN rm -rf dist && npx prisma generate && npx tsc

USER node
EXPOSE 4000

# `db push` without --accept-data-loss refuses destructive schema changes, so a
# risky schema change fails health and the deployer rolls back.
CMD ["sh", "-c", "npx prisma db push --skip-generate && exec node --max-old-space-size=320 dist/src/index.js"]
