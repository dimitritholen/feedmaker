ARG PYTHON_VERSION=3.10-slim-buster

FROM python:${PYTHON_VERSION}

LABEL maintainer="Dimitri Tholen <d.tholen@blisdigital.com>"
LABEL description="Feed Maker - Generate RSS feeds from any website"
LABEL version="1.0"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Create necessary directories
RUN mkdir -p /code/data /code/static && \
    chmod 777 /code/data

WORKDIR /code

# Install dependencies
COPY requirements.txt /tmp/requirements.txt
RUN set -ex && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    rm -rf /root/.cache/

# Copy application code
COPY . /code/

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Run application
CMD ["gunicorn", "--bind", ":8000", "--workers", "1", "--access-logfile", "-", "--preload", "feedmaker.wsgi"]
