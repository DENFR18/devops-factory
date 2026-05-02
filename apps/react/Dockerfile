# ── Stage 1: builder ──────────────────────────────────────────────────────────
FROM node:20-slim AS builder

WORKDIR /build

COPY package.json ./
RUN npm install --ignore-scripts

COPY index.html vite.config.js ./
COPY src/ ./src/
RUN npm run build

# ── Stage 2: runtime ──────────────────────────────────────────────────────────
FROM nginx:1.27-alpine AS runtime

RUN rm /etc/nginx/conf.d/default.conf

COPY --from=builder /build/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/app.conf

RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx \
 && touch /var/run/nginx.pid \
 && chown nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD nc -zw3 127.0.0.1 8080 || exit 1

ENTRYPOINT ["nginx", "-g", "daemon off;"]
