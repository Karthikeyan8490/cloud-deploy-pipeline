# ---- Build Stage ----
FROM python:3.12-slim AS builder

WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ---- Production Stage ----
FROM python:3.12-slim

WORKDIR /app

# Create a non-root user for security
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Copy installed packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# Copy application source
COPY app/ .

# Fix permissions
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 5000

# Use Gunicorn as the production WSGI server
CMD ["/home/appuser/.local/bin/gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "app:app"]
