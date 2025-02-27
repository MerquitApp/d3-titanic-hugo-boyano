FROM node:22-alpine as base

# Install pnpm globally
RUN apk add --no-cache libc6-compat && \
  npm install -g pnpm

WORKDIR /app
COPY package.json pnpm-lock.yaml ./

FROM base as build-deps
RUN pnpm install --frozen-lockfile

FROM build-deps as build
RUN pnpm run build

FROM nginx:alpine as runtime
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 8080