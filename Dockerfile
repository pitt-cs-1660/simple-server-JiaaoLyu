# ======================
# Build stage
# ======================
FROM python:3.12 AS builder

WORKDIR /app

# Copy dependency definition file (leverage cache)
COPY pyproject.toml ./

# Install dependencies into a virtual environment
RUN python -m venv .venv \
    && .venv/bin/pip install --upgrade pip \
    && .venv/bin/pip install fastapi uvicorn pydantic httpx pytest pytest-cov

# Copy source code and tests
COPY . .

# ======================
# Final stage
# ======================
FROM python:3.12-slim AS final

WORKDIR /app

# Copy venv from builder
COPY --from=builder /app/.venv /app/.venv

# Copy application code
COPY --from=builder /app /app

# Copy tests directory into final stage
COPY --from=builder /app/tests ./tests

# Create non-root user and give permissions to /app
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Ensure venv Python is used
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH=/app

EXPOSE 8000

CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
