#!/bin/bash
# LiveAvatar RunPod One-Click Setup Script
# Run this script on a fresh RunPod instance
# Usage: curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/LiveAvatar-RunPod/main/setup_runpod.sh | bash

set -e

echo "=============================================="
echo "  LiveAvatar RunPod One-Click Setup"
echo "=============================================="

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
REPO_URL="${LIVEAVATAR_REPO:-https://github.com/YOUR_USERNAME/LiveAvatar-RunPod.git}"

# Clone repository
echo "[INFO] Cloning LiveAvatar repository..."
cd $WORKSPACE_DIR

if [ -d "LiveAvatar" ]; then
    echo "[WARN] LiveAvatar directory exists. Pulling latest changes..."
    cd LiveAvatar
    git pull || true
else
    git clone $REPO_URL LiveAvatar
    cd LiveAvatar
fi

# Make scripts executable
chmod +x install.sh run.sh

# Run installation
./install.sh

echo ""
echo "[INFO] Setup complete! Run './run.sh' to start LiveAvatar."
