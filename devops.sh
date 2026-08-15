#!/bin/bash

set -e

echo "==> Checking Node.js installation..."
if ! command -v node >/dev/null 2>&1; then
    echo "ERROR: Node.js is not installed."
    exit 1
fi

echo "Node.js version: $(node --version)"

echo "==> Stopping any running Node.js process..."
pkill -f "node index.js" || true

echo "==> Installing dependencies..."
npm install
echo "Dependencies installed successfully!"

echo "==> Starting application..."
node index.js
echo "Application started successfully!"