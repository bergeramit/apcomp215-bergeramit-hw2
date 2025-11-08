FROM python:3.13-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml ./
COPY server.py ./

# Create virtual environment and install dependencies
RUN uv venv && \
    . .venv/bin/activate && \
    uv sync

# Expose port (default 8080, can be overridden via PORT env var)
EXPOSE 8080

# Run the server
CMD [".venv/bin/python", "server.py"]

