# ── Stage 1: builder ──────────────────────────────────────────────────────────
# Installs dependencies into a prefix directory so the runtime stage can copy
# only the installed packages without pip, setuptools or build tools.
FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: runtime ──────────────────────────────────────────────────────────
# Minimal python:3.12-slim image, non-root user (UID/GID 1001).
# readOnlyRootFilesystem is enforced at the Kubernetes PodSpec level;
# uvicorn writes nothing to disk at runtime.
FROM python:3.12-slim AS runtime

RUN groupadd --gid 1001 appgroup \
 && useradd --uid 1001 --gid appgroup --no-create-home --shell /sbin/nologin appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Copy application source — owned by non-root user
COPY --chown=1001:1001 main.py .

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER 1001:1001

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

ENTRYPOINT ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
