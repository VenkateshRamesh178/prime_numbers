#!/bin/bash

# Usage: ./release.sh 0.1.2

set -e  # Exit if any command fails

VERSION=$1

if [[ -z "$VERSION" ]]; then
  echo "❌ Usage: ./release.sh <new_version>"
  exit 1
fi

echo "🚀 Releasing version $VERSION..."

# Step 1: Update pyproject.toml
if grep -q "\[project\]" pyproject.toml; then
  sed -i "s/^version = \".*\"/version = \"$VERSION\"/" pyproject.toml
  echo "✅ Updated version in pyproject.toml"
fi

# Step 2: Update __version__ in __init__.py
INIT_FILE="prime_nos/__init__.py"
if [ -f "$INIT_FILE" ]; then
  sed -i "s/^__version__ = \".*\"/__version__ = \"$VERSION\"/" $INIT_FILE
  echo "✅ Updated version in $INIT_FILE"
fi

SETUP_FILE="setup.py"
if [ -f "$SETUP_FILE" ]; then
  sed -i "s/^ *version=\"[^\"]*\"/    version=\"$VERSION\"/" $SETUP_FILE
  echo "✅ Updated version in $SETUP_FILE"
fi

# Step 3: Clean old builds
rm -rf dist/ build/ *.egg-info
echo "🧹 Cleaned old build files"

# Step 4: Build package
python -m build
twine upload dist/*
echo "📦 Built the package"

# Step 5: Commit & Tag
git add .
git commit -m "🔖 Release v$VERSION"
git push origin main
git tag v$VERSION
git push origin v$VERSION
echo "✅ Version $VERSION pushed and tagged"
