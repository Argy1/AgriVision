# Image LOKAL untuk ml-service (FastAPI + TFLite). Produksi di Railway TIDAK memakai berkas ini:
# Railway membangun dari ml-service/ lewat Procfile + .python-version. Berkas ini sengaja ada di
# docker/ (bukan ml-service/Dockerfile) supaya Railway tidak otomatis beralih ke Dockerfile.
#
# Build context = ./ml-service  (lihat docker-compose.yml di root repo)
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    TF_CPP_MIN_LOG_LEVEL=2

WORKDIR /srv

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app ./app
COPY models ./models

EXPOSE 8000

HEALTHCHECK --interval=15s --timeout=5s --start-period=60s --retries=5 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://localhost:8000/api/health').status==200 else 1)"

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
