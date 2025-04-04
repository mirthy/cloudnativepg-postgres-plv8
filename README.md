# CloudNativePG with PLV8

This repository provides a Docker image that extends [CloudNativePG](https://cloudnative-pg.io/) with the [PLV8](https://github.com/plv8/plv8) JavaScript extension for PostgreSQL.

## What is PLV8?

PLV8 is a trusted JavaScript language extension for PostgreSQL. It enables you to write database functions in JavaScript, opening up possibilities for data processing directly inside your PostgreSQL database.

## Usage

### Docker Image

#### Using Prebuilt Images

Prebuilt images are available from GitHub Container Registry:

```bash
# Pull the image (replace USERNAME with your GitHub username)
docker pull ghcr.io/USERNAME/cloudnativepg-plv8:latest-17

# Available tags:
# - latest-13, latest-14, latest-15, latest-16, latest-17: Latest builds for specific PostgreSQL versions
# - 1.0.0-17, 1.0.0-16, etc.: Version-specific tags (when releases are tagged)
```

All images are multi-architecture builds with support for:
- linux/amd64 (x86_64) - Standard Intel/AMD servers
- linux/arm64 (aarch64) - AWS Graviton, Apple Silicon, Raspberry Pi 4, etc.

#### Building Locally

You can also build the Docker image locally:

```bash
# For PostgreSQL 17 (default)
docker build -t cloudnativepg-plv8:17 .

# For a specific PostgreSQL version
docker build --build-arg PG_CONTAINER_VERSION=15 -t cloudnativepg-plv8:15 .
```

### Using with CloudNativePG

To use this image with CloudNativePG, specify it in your cluster definition:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: pg-with-plv8
spec:
  instances: 3
  imageName: ghcr.io/USERNAME/cloudnativepg-plv8:latest-17
  # Additional CloudNativePG configuration...
```

Make sure to replace `USERNAME` with your GitHub username.

### Enabling PLV8 Extension

Once your cluster is running, you can enable the PLV8 extension:

```sql
CREATE EXTENSION plv8;
```

## Build Arguments

- `PG_CONTAINER_VERSION`: PostgreSQL version (default: 17)
- `PLV8_BRANCH`: PLV8 git branch (default: r3.2)
- `PLV8_VERSION`: PLV8 version (default: 3.2.3)

## CI/CD Workflow

This repository includes GitHub Actions workflows that:

1. Build the image for multiple PostgreSQL versions (13, 14, 15, 16, 17)
2. Create multi-architecture images for both AMD64 (x86_64) and ARM64 platforms
3. Run basic tests to ensure the image works properly
4. Push the images to GitHub Container Registry with appropriate tags

To trigger a release with semantic versioning tags:

```bash
# Tag a new version
git tag v1.0.0
git push origin v1.0.0
```

This will create images with tags like `1.0.0-13`, `1.0.0-14`, etc.

### Multi-Architecture Builds

The CI/CD pipeline builds images for both AMD64 (x86_64) and ARM64 architectures. This means:

- The same image can run on regular x86 servers, AWS Graviton instances, Apple Silicon Macs, etc.
- No need to specify the architecture when pulling the image - Docker will automatically select the correct one for your platform
- ARM64 builds may take longer in the CI/CD pipeline due to emulation on GitHub's x86 runners

If you encounter any architecture-specific issues, please report them via GitHub issues.

## License

[Add your license information here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
