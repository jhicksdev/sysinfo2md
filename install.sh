#!/usr/bin/env bash
# Install sysinfo2md to ~/.local/bin

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/sysinfo2md.sh" "$INSTALL_DIR/sysinfo2md"
chmod +x "$INSTALL_DIR/sysinfo2md"

echo "Installed: $INSTALL_DIR/sysinfo2md"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo ""
    echo "Note: $INSTALL_DIR is not in your PATH."
    echo "Add this line to your ~/.zshrc (or ~/.bashrc):"
    echo ""
    echo '  export PATH="$HOME/.local/bin:$PATH"'
fi
