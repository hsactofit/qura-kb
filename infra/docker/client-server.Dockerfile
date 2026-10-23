# qura-client-server (FastAPI). Built from the service repo checkout; kept here so
# infra changes never require touching the app repo.
# Unlike the repo's own Dockerfile this one ships Alembic, and migrations run on
# start (the deployer takes a DB dump first and rolls back if health fails).
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    QURA_STORAGE_DIR=/data/storage

WORKDIR /app

COPY pyproject.toml ./
RUN pip install .

COPY app ./app
COPY alembic ./alembic
COPY alembic.ini ./

RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /data/storage && chown -R appuser /data/storage
USER appuser

EXPOSE 8787

CMD ["sh", "-c", "alembic upgrade head && exec uvicorn app.main:app --host 0.0.0.0 --port 8787 --workers 1 --proxy-headers --forwarded-allow-ips='*'"]
