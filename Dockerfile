# ---- Stage 1: build dependencies in an isolated layer ----
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build deps only where needed, then discard this whole stage later
# so no compiler/toolchain ends up in the final image (smaller attack surface).
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ---- Stage 2: minimal runtime image ----
FROM python:3.12-slim

# Security-relevant OS patches only, then clean apt cache to keep the image
# small (fewer packages = fewer CVEs for Trivy to ever find).
RUN apt-get update && apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# Run as a non-root user — never run application containers as root.
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --shell /bin/false --create-home appuser

WORKDIR /app

# Bring in only the installed packages from the builder stage, not the
# build tools that produced them.
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appgroup app.py .

ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# gunicorn, not the Flask dev server — the dev server is not meant for
# anything DAST will actually be pointed at.
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
