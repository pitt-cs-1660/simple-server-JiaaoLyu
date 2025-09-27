# ======================
# Build stage
# ======================
FROM python:3.12 AS builder

WORKDIR /app

# Copy dependency definition file (leverage cache)
COPY pyproject.toml ./

# Install dependencies
RUN pip install --upgrade pip \
    && pip install fastapi uvicorn pydantic httpx pytest pytest-cov

# Copy source code
COPY . .

# ======================
# Final stage
# ======================
FROM python:3.12-slim AS final

WORKDIR /app

# Copy dependencies and source code from builder
COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app

# Create non-root user and give permissions to /app
RUN useradd -m appuser && chown appuser:appuser /app
USER appuser

ENV PYTHONPATH=/app

EXPOSE 8000

CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
