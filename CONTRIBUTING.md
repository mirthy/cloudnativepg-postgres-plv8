# Contributing to CloudNativePG PLV8

Thank you for your interest in contributing to this project! Here's how you can help.

## Reporting Issues

If you find a bug or have a suggestion for improving the project:

1. Check if the issue already exists in the [Issues](https://github.com/YOUR-USERNAME/cloudnativepg-plv8/issues) section.
2. If not, create a new issue with a descriptive title and detailed information about the problem or suggestion.

## Pull Requests

We welcome pull requests! Here's the process:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes.
4. Test your changes thoroughly.
5. Submit a pull request with a clear description of the changes.

## Development Setup

To set up a development environment:

1. Clone your fork of the repository.
2. Build the Docker image using the provided Dockerfile.
3. Test your changes by running the image and verifying PLV8 functionality.

## Building for Different PostgreSQL Versions

This project supports multiple PostgreSQL versions. When contributing, please consider testing your changes with different PostgreSQL versions:

```bash
# For PostgreSQL 13
docker build --build-arg PG_CONTAINER_VERSION=13 -t cloudnativepg-plv8:13-test .

# For PostgreSQL 14
docker build --build-arg PG_CONTAINER_VERSION=14 -t cloudnativepg-plv8:14-test .

# etc.
```

## Code Style

Please follow these guidelines:

- Keep the Dockerfile clean and well-commented.
- Follow best practices for Docker image creation (minimizing layers, cleaning up after installs, etc.).
- Document any significant changes in the README.

## License

By contributing to this project, you agree that your contributions will be licensed under the project's license.
