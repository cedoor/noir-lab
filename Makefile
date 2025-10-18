# Makefile for noir-lab Noir project

# Variables
PROJECT_NAME = noir_lab
TARGET_DIR = target
CIRCUIT_ARTIFACT = $(TARGET_DIR)/$(PROJECT_NAME).json
NOIRUP_VERSION = 1.0.0-beta.14

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Setup and installation
.PHONY: install
install: ## Install Noir toolchain using noirup
	@echo "Installing Noir toolchain..."
	@if command -v noirup >/dev/null 2>&1; then \
		noirup -v $(NOIRUP_VERSION); \
	else \
		echo "Installing noirup first..."; \
		curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash; \
		noirup -v $(NOIRUP_VERSION); \
	fi

# Development targets
.PHONY: check
check: ## Check code compilation without building artifacts
	@echo "Checking code compilation..."
	nargo check --workspace

.PHONY: check-warnings
check-warnings: ## Check code compilation and treat warnings as errors
	@echo "Checking code compilation with warnings as errors..."
	nargo check --deny-warnings --workspace

.PHONY: format
format: ## Format code using nargo fmt
	@echo "Formatting code..."
	nargo fmt --workspace

.PHONY: format-check
format-check: ## Check if code is properly formatted
	@echo "Checking code formatting..."
	nargo fmt --check --workspace

.PHONY: lint
lint: check-warnings format-check ## Run linting (check + format-check)

# Build targets
.PHONY: compile
compile: ## Compile the circuit
	@echo "Compiling circuit..."
	nargo compile --workspace

.PHONY: build
build: lint compile ## Build the project (lint + compile)

# Test targets
.PHONY: test
test: ## Run tests
	@echo "Running tests..."
	nargo test --workspace

.PHONY: test-verbose
test-verbose: ## Run tests with verbose output
	@echo "Running tests with verbose output..."
	nargo test --show-output --workspace

# Clean targets
.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	rm -rf $(TARGET_DIR)
	@echo "Clean complete"

# Development workflow
.PHONY: dev
dev: check test ## Development workflow (check + test)

.PHONY: watch
watch: ## Watch src directory and run 'make dev' on file changes
	@echo "Watching src/ for changes (Ctrl+C to stop)..."
	@watchexec -e nr -w src "make dev"