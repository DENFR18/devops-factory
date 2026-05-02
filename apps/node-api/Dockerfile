# ── Stage 1: deps ─────────────────────────────────────────────────────────────
FROM node:20-slim AS deps

WORKDIR /build

COPY package.json ./
RUN npm install --omit=dev --ignore-scripts

# ── Stage 2: runtime ──────────────────────────────────────────────────────────
FROM node:20-slim AS runtime

RUN groupadd --gid 1001 appgroup \
 && useradd --uid 1001 --gid appgroup --no-create-home --shell /sbin/nologin appuser

WORKDIR /app

COPY --from=deps /build/node_modules ./node_modules
COPY --chown=1001:1001 src/ ./src/
COPY --chown=1001:1001 package.json .

ENV NODE_ENV=production \
    PORT=3000

USER 1001:1001

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD node -e "const net=require('net');const s=net.connect({port:parseInt(process.env.PORT||'3000'),host:'127.0.0.1'},()=>{s.end();process.exit(0)});s.on('error',()=>process.exit(1))"

ENTRYPOINT ["node", "src/index.js"]
