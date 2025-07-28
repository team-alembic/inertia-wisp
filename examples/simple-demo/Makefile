# Simple Demo Makefile
# Provides convenient commands for building and running the frontend and backend

.PHONY: help install build build-frontend build-backend start watch clean test

# Default target
help:
	@echo "Simple Demo - Inertia.js with Gleam"
	@echo ""
	@echo "Available commands:"
	@echo "  install        Install all dependencies (frontend + backend)"
	@echo "  build          Build both frontend and backend"
	@echo "  build-frontend Build only the frontend assets"
	@echo "  build-backend  Build only the backend"
	@echo "  start          Build and start the server"
	@echo "  watch          Start development mode with file watching"
	@echo "  test           Run backend tests"
	@echo "  clean          Clean build artifacts"
	@echo ""

# Install dependencies
install:
	@echo "Installing backend dependencies..."
	gleam deps download
	@echo "Installing frontend dependencies..."
	cd frontend && npm install

# Build everything
build: build-frontend build-backend

# Build frontend assets
build-frontend:
	@echo "Building frontend assets..."
	cd frontend && npm run build

# Build backend
build-backend:
	@echo "Building backend..."
	gleam build

# Build and start server
start: build
	@echo "Starting server on https://localhost:8443"
	@echo "Note: You'll need to accept the self-signed certificate in your browser"
	gleam run

# Development mode with file watching
watch:
	@echo "Starting development mode..."
	@echo "Frontend assets will be built with file watching"
	@echo "Start the backend server with 'gleam run' in another terminal"
	@echo "Server will be available at https://localhost:8443"
	cd frontend && npm run build:watch

# Run tests
test:
	@echo "Running backend tests..."
	gleam test

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf build/
	rm -rf static/js/main.js
	rm -rf static/css/styles.css
	cd frontend && rm -rf node_modules/
