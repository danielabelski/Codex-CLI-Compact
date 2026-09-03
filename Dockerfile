FROM python:3.12-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ripgrep git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY dashboard /app/dual-graph-dashboard/dashboard
COPY bin /app/dual-graph-dashboard/bin

ENV DG_BASE_URL=http://127.0.0.1:8787

RUN chmod +x /app/dual-graph-dashboard/dashboard/start.sh

CMD ["/app/dual-graph-dashboard/dashboard/start.sh"]
