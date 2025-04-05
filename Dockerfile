# Base PostgreSQL version to use
ARG PG_CONTAINER_VERSION=17
FROM ghcr.io/cloudnative-pg/postgresql:${PG_CONTAINER_VERSION} as builder

# Set environment for non-interactive apt installations
ARG DEBIAN_FRONTEND=noninteractive
ARG PG_CONTAINER_VERSION=17

# Switch to root user to copy files
USER root

# Install build dependencies for PLV8
# Note: Architecture-specific dependencies are handled automatically
RUN set -ex \
  && apt-get update \
  && apt-get install -y \
      build-essential \
      git \
      curl \
      cmake \
      clang \
      binutils \
      libstdc++-10-dev \
      libglib2.0-dev \
      postgresql-server-dev-${PG_CONTAINER_VERSION} \
      libtinfo5 \
      pkg-config \
  && apt-get clean
# PLV8 version configuration
ARG PLV8_BRANCH=r3.2
ENV PLV8_BRANCH=${PLV8_BRANCH}
ARG PLV8_VERSION=3.2.3
ENV PLV8_VERSION=${PLV8_VERSION}
# Build and install PLV8
# Note: Build will automatically adjust for the target architecture
RUN set -ex \
  && git clone --branch ${PLV8_BRANCH} --single-branch --depth 1 https://github.com/plv8/plv8 \
  && cd plv8 \
  && if [ "$(uname -m)" = "aarch64" ]; then \
       echo "Building on ARM64 architecture"; \
       # ARM64 might need more memory for the V8 build process \
       export V8_CXXFLAGS="-O2"; \
     fi \
  && make install \
  && strip /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/plv8-${PLV8_VERSION}.so

# Final stage using CloudNativePG base image
FROM ghcr.io/cloudnative-pg/postgresql:${PG_CONTAINER_VERSION}
ARG PG_CONTAINER_VERSION=17
ARG PLV8_VERSION=3.2.3

# Switch to root user to copy files
USER root

# Install required runtime dependencies for PLV8
RUN set -ex \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     libstdc++6 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy PLV8 files from builder to final image
COPY --from=builder /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/plv8* /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/
COPY --from=builder /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/bitcode/plv8-${PLV8_VERSION}/* /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/bitcode/plv8-${PLV8_VERSION}/
COPY --from=builder /usr/share/postgresql/${PG_CONTAINER_VERSION}/extension/plv8* /usr/share/postgresql/${PG_CONTAINER_VERSION}/extension/

# Change the uid of postgres to 26 (CloudNativePG requirement)
RUN usermod -u 26 postgres
USER 26

