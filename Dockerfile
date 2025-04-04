# Base PostgreSQL version to use
ARG PG_CONTAINER_VERSION=17
FROM docker.io/library/postgres:${PG_CONTAINER_VERSION}-bookworm as builder

# Set environment for non-interactive apt installations
ARG DEBIAN_FRONTEND=noninteractive
ARG PG_CONTAINER_VERSION=17

# Install build dependencies for PLV8
RUN set -ex \
  && apt-get update \
  && apt-get install -y build-essential git postgresql-server-dev-${PG_CONTAINER_VERSION} \
     libtinfo5 pkg-config clang binutils libstdc++-12-dev cmake \
  && apt-get clean
# PLV8 version configuration
ARG PLV8_BRANCH=r3.2
ENV PLV8_BRANCH=${PLV8_BRANCH}
ARG PLV8_VERSION=3.2.3
ENV PLV8_VERSION=${PLV8_VERSION}
# Build and install PLV8
RUN set -ex \
  && git clone --branch ${PLV8_BRANCH} --single-branch --depth 1 https://github.com/plv8/plv8 \
  && cd plv8 \
  && make install \
  && strip /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/plv8-${PLV8_VERSION}.so

# Final stage using CloudNativePG base image
FROM ghcr.io/cloudnative-pg/postgresql:${PG_CONTAINER_VERSION}
ARG PG_CONTAINER_VERSION=17
ARG PLV8_VERSION=3.2.3

# Switch to root user to copy files
USER root

# Copy PLV8 files from builder to final image
COPY --from=builder /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/plv8* /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/
COPY --from=builder /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/bitcode/plv8-${PLV8_VERSION}/* /usr/lib/postgresql/${PG_CONTAINER_VERSION}/lib/bitcode/plv8-${PLV8_VERSION}/
COPY --from=builder /usr/share/postgresql/${PG_CONTAINER_VERSION}/extension/plv8* /usr/share/postgresql/${PG_CONTAINER_VERSION}/extension/

# Change the uid of postgres to 26 (CloudNativePG requirement)
RUN usermod -u 26 postgres
USER 26

