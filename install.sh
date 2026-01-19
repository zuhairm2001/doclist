#!/bin/bash
#
# Installs doclist CLI tool for Linux/macOS.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/zuhairm2001/doclist/main/install.sh | bash
#

set -e

REPO="zuhairm2001/doclist"
INSTALL_DIR="$HOME/.local/bin"
BINARY_NAME="doclist"

echo "Installing doclist..."

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    linux)
        OS="linux"
        ;;
    darwin)
        OS="darwin"
        ;;
    *)
        echo "Error: Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Build asset name
ASSET_NAME="doclist-${OS}-${ARCH}"

echo "Detected: ${OS}/${ARCH}"

# Get latest release info
echo "Fetching latest release..."
RELEASE_INFO=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")

if [ -z "$RELEASE_INFO" ]; then
    echo "Error: Failed to fetch release info from GitHub."
    exit 1
fi

# Extract version
VERSION=$(echo "$RELEASE_INFO" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Latest version: $VERSION"

# Extract download URL for the asset
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -o "\"browser_download_url\": *\"[^\"]*${ASSET_NAME}\"" | head -1 | cut -d'"' -f4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find binary for ${OS}/${ARCH} in release."
    echo "Available assets may not include ${ASSET_NAME}"
    exit 1
fi

# Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

INSTALL_PATH="${INSTALL_DIR}/${BINARY_NAME}"

# Download the binary
echo "Downloading ${ASSET_NAME}..."
curl -fsSL "$DOWNLOAD_URL" -o "$INSTALL_PATH"

# Make it executable
chmod +x "$INSTALL_PATH"

echo "Installed to: $INSTALL_PATH"

# Check if install directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Warning: $INSTALL_DIR is not in your PATH."
    echo ""
    echo "Add it to your shell configuration file:"
    echo ""
    echo "  For bash (~/.bashrc):"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "  For zsh (~/.zshrc):"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
fi

echo ""
echo "doclist $VERSION installed successfully!"
echo ""
echo "Usage: doclist <directory>"
