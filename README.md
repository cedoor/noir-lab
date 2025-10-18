# Noir Lab

A laboratory for experimenting with different Noir circuits and zero-knowledge proof applications.

## Description

This repository contains various Noir circuit experiments and implementations for learning and testing different cryptographic primitives and zero-knowledge proof techniques.

## Makefile Commands

```bash
# Setup and installation
make install          # Install Noir toolchain using noirup
make help             # Show all available commands

# Development
make check            # Check code compilation without building artifacts
make check-warnings   # Check code compilation and treat warnings as errors
make format           # Format code using nargo fmt
make format-check     # Check if code is properly formatted
make lint             # Run linting (check + format-check)

# Build
make compile          # Compile the circuit
make build            # Build the project (lint + compile)

# Testing
make test             # Run tests
make test-verbose     # Run tests with verbose output

# Cleanup
make clean            # Clean build artifacts

# Development workflow
make dev              # Development workflow (check + test)

# Watch
make watch            # Watch src directory and run 'make dev' on file changes

# Run web app
make run-app          # Run the Web app in development mode
```
