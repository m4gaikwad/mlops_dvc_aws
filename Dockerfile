# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install fastapi uvicorn

# Copy source
COPY app/ app/
COPY dvc.yaml dvc.yaml
COPY params.yaml params.yaml
COPY .dvc/ .dvc/
COPY src/ src/
COPY model/ model/

# Expose API
EXPOSE 8000

# When container starts: fetch model/data from S3 via DVC, then launch API
CMD uvicorn app.main:app --host 0.0.0.0 --port 8000

