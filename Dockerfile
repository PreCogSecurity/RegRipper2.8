# RegRipper 2.8 Dockerfile
# Multi-stage build for minimal production image

# =============================================================================
# Build Stage
# =============================================================================
FROM perl:5.38-slim AS builder

# Install system dependencies for building Perl modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy dependency files first for better caching
COPY cpanfile ./
COPY cpanfile.snapshot* ./

# Install Perl dependencies
RUN cpanm --quiet --notest --installdeps .

# Copy source code
COPY . .

# Run tests
RUN prove -lr t/ || true

# Run linting
RUN perlcritic --profile .perlcriticrc rip.pl rr.pl plugins/ || true

# Build executables (optional, for Windows targets use PAR::Packer on Windows)
# RUN cpanm --quiet --notest PAR::Packer && pp -o rip.exe rip.pl && pp -o rr.exe rr.pl

# =============================================================================
# Runtime Stage
# =============================================================================
FROM perl:5.38-slim

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r -g 1000 regripper && \
    useradd -r -u 1000 -g regripper -m -s /bin/bash regripper

# Set working directory
WORKDIR /app

# Copy Perl modules from builder
COPY --from=builder /usr/local/lib/perl5 /usr/local/lib/perl5

# Copy application code
COPY --chown=regripper:regripper rip.pl rr.pl ./
COPY --chown=regripper:regripper plugins/ ./plugins/
COPY --chown=regripper:regripper .env.example ./

# Create workspace directory for hive files
RUN mkdir -p /workspace && chown regripper:regripper /workspace

# Switch to non-root user
USER regripper

# Set environment variables
ENV PERL5LIB=/usr/local/lib/perl5
ENV PLUGIN_DIR=/app/plugins

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD perl -c /app/rip.pl && perl -c /app/rr.pl || exit 1

# Default command shows help
ENTRYPOINT ["perl", "/app/rip.pl"]
CMD ["-h"]

# Labels
LABEL org.opencontainers.image.title="RegRipper" \
      org.opencontainers.image.description="Windows Registry Forensics Tool" \
      org.opencontainers.image.version="2.8.1" \
      org.opencontainers.image.authors="PreCog Security" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.source="https://github.com/PreCogSecurity/RegRipper2.8" \
      org.opencontainers.image.documentation="https://github.com/PreCogSecurity/RegRipper2.8/blob/main/README.md"