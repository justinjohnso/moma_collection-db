#!/bin/bash
# Setup script for MoMA Collection Database
# Configures git hooks for automatic database rebuilding

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎨 MoMA Collection Database - Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Check if in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Configure git to use .githooks directory
echo "🔧 Configuring git hooks..."
git config core.hooksPath .githooks
echo "✅ Git configured to use .githooks/"
echo

# Initialize submodule if not already done
if [ ! -f "collection/.git" ]; then
    echo "📦 Initializing collection submodule..."
    git submodule update --init --recursive
    echo "✅ Submodule initialized"
    echo
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "⚠️  Warning: python3 not found"
    echo "   Python 3 is required to build the database"
    echo
fi

# Check for Git LFS
if ! command -v git-lfs &> /dev/null; then
    echo "⚠️  Warning: git-lfs not found"
    echo "   Git LFS is required to download collection data files"
    echo "   Install: brew install git-lfs (macOS) or apt-get install git-lfs (Linux)"
    echo
else
    echo "📦 Pulling LFS files from collection..."
    (cd collection && git lfs pull)
    echo "✅ LFS files downloaded"
    echo
fi

# Build initial database
if [ ! -f "moma_full.db" ]; then
    echo "🏗️  Building initial database..."
    if python3 build_moma.py; then
        echo "✅ Database built successfully"
    else
        echo "❌ Database build failed"
        exit 1
    fi
else
    echo "ℹ️  Database already exists (moma_full.db)"
    echo "   Run 'python3 build_moma.py' to rebuild manually"
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "The database will automatically rebuild when you run:"
echo "  git pull"
echo "  git submodule update --remote collection"
echo
