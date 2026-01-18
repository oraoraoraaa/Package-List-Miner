#!/bin/bash

# Script to publish all miners to PyPI
# Usage: ./publish_all.sh [test|prod]
# - test: Upload to TestPyPI
# - prod: Upload to PyPI (default)

set -e  # Exit on error

MINERS=(
    "Crates-Miner"
    "NPM-Miner"
    "PyPI-Miner"
    "Go-Miner"
    "PHP-Miner"
    "Ruby-Miner"
)

MODE="${1:-prod}"

if [ "$MODE" = "test" ]; then
    REPO_FLAG="--repository testpypi"
    echo "Publishing to TestPyPI..."
elif [ "$MODE" = "prod" ]; then
    REPO_FLAG=""
    echo "Publishing to PyPI..."
else
    echo "Invalid mode. Use 'test' or 'prod'"
    exit 1
fi

echo "========================================="
echo "Publishing all miners"
echo "Mode: $MODE"
echo "========================================="
echo ""

for miner in "${MINERS[@]}"; do
    if [ ! -d "$miner" ]; then
        echo "Warning: $miner directory not found, skipping..."
        continue
    fi
    
    echo "========================================="
    echo "Publishing $miner"
    echo "========================================="
    
    cd "$miner"
    
    # Clean previous builds
    echo "Cleaning previous builds..."
    rm -rf dist/ build/ *.egg-info
    
    # Build
    echo "Building package..."
    python -m build
    
    # Upload
    echo "Uploading to repository..."
    python -m twine upload $REPO_FLAG dist/*
    
    echo "✓ $miner published successfully!"
    echo ""
    
    cd ..
done

echo "========================================="
echo "All packages published successfully!"
echo "========================================="

if [ "$MODE" = "test" ]; then
    echo ""
    echo "To install from TestPyPI:"
    echo "  pip install --index-url https://test.pypi.org/simple/ <package-name>"
fi
