.PHONY: all build run dev clean deps frontend-deps frontend-build frontend-watch certs test backend-test frontend-test help

# Default target
all: deps build

# Install all dependencies
deps: frontend-deps
	cd backend && gleam deps download

# Install frontend dependencies
frontend-deps:
	cd frontend && npm install

# Generate trusted HTTPS certificates using mkcert
certs:
	@echo "Generating HTTPS certificates with mkcert..."
	@if ! command -v mkcert >/dev/null 2>&1; then \
		echo "Error: mkcert is not installed."; \
		echo "Install it with: brew install mkcert (macOS) or see https://github.com/FiloSottile/mkcert"; \
		exit 1; \
	fi
	@mkdir -p backend/priv/certs
	cd backend/priv/certs && mkcert localhost 127.0.0.1 ::1
	cd backend/priv/certs && mv localhost+2.pem localhost.crt && mv localhost+2-key.pem localhost.key
	@echo "✅ Certificates generated successfully!"

# Typecheck frontend TypeScript
frontend-typecheck:
	cd frontend && npm run typecheck

# Build frontend assets
frontend-build:
	cd frontend && npm run build

# Build everything
build: frontend-build
	cd backend && gleam build

# Typecheck and build everything
check: frontend-typecheck build

# Run backend tests
backend-test:
	cd backend && gleam test

# Run frontend tests
frontend-test:
	cd frontend && npm test

# Run all tests (backend + frontend)
test: backend-test frontend-test

# Run the server
run:
	cd backend && gleam run

# Development mode - watch frontend and run server in separate terminals
dev:
	@echo "Starting development mode..."
	@echo "Run 'make dev-frontend' in one terminal and 'make dev-server' in another"

# Watch frontend assets (for development)
dev-frontend:
	cd frontend && npm run watch

# Run server (for development)
dev-server:
	cd backend && gleam run

# Clean build artifacts
clean:
	rm -rf backend/build/
	rm -rf backend/priv/static/css/
	rm -rf backend/priv/static/js/
	cd frontend && rm -rf node_modules/

# Clean and rebuild everything
rebuild: clean all

# Help target
help:
	@echo "Available targets:"
	@echo "  make all               - Install dependencies and build everything (default)"
	@echo "  make deps              - Install Gleam and frontend dependencies"
	@echo "  make certs             - Generate trusted HTTPS certificates with mkcert"
	@echo "  make frontend-typecheck - Type check frontend TypeScript code"
	@echo "  make build             - Build frontend assets"
	@echo "  make check             - Type check and build everything"
	@echo "  make test              - Run all tests (backend + frontend)"
	@echo "  make backend-test      - Run backend tests only"
	@echo "  make frontend-test     - Run frontend tests only"
	@echo "  make run               - Run the presentation server"
	@echo "  make dev               - Show instructions for development mode"
	@echo "  make dev-frontend      - Watch and rebuild frontend assets"
	@echo "  make dev-server        - Run the server"
	@echo "  make clean             - Remove build artifacts"
	@echo "  make rebuild           - Clean and rebuild everything"
	@echo ""
	@echo "Development workflow:"
	@echo "  1. Terminal 1: make dev-frontend"
	@echo "  2. Terminal 2: make dev-server"
	@echo "  3. Visit https://localhost:8444"
	@echo ""
	@echo "First time setup:"
	@echo "  1. make certs     - Generate trusted HTTPS certificates"
	@echo "  2. make all       - Install dependencies and build"
	@echo "  3. make run       - Start the server"
