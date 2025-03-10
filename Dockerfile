FROM node:22-alpine AS base

# Install pnpm globally
RUN apk add --no-cache libc6-compat && \
  npm install -g pnpm

WORKDIR /app
COPY package.json pnpm-lock.yaml astro.config.mjs tsconfig.json ./
COPY src/ ./src/
COPY public/ ./public/

FROM base AS build-deps
RUN pnpm install --frozen-lockfile

FROM build-deps AS build
RUN pnpm build

FROM nginx:alpine AS runtime
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80