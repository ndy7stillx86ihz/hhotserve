#!/bin/bash

set -e

REPO_URL="https://github.com/ndy7stillx86ihz/hhotserve.git"
INSTALL_DIR="$HOME/.local/opt/hhotserve"
BIN_DIR="$HOME/.local/bin"

error_msg() {
    echo -e "\e[31m$1\e[0m" >&2
    exit 1
}

success_msg() {
    echo -e "\e[32m$1\e[0m"
}

warn_msg() {
    echo -e "\e[33m$1\e[0m"
}

if ! command -v apt &> /dev/null; then
    error_msg "This script is intended for Debian-based systems. Exiting."
fi

if ! command -v python3 &> /dev/null; then
    read -p "Python3 is not installed. Do you want to install it? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        sudo apt update && sudo apt install python3 -y
    else
        error_msg "Python3 is required. Exiting."
    fi
fi

if ! python3 -c "import watchdog" &> /dev/null; then
    read -p "watchdog is not installed. Do you want to install it? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        sudo apt update && sudo apt install python3-watchdog -y
    else
        error_msg "watchdog python dependency is required. Exiting."
    fi
fi

if ! command -v git &> /dev/null; then
    read -p "git is not installed. Do you want to install it? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        sudo apt update && sudo apt install git -y
    else
        error_msg "git is required. Exiting."
    fi
fi

if [[ -d "$INSTALL_DIR" ]]; then
    warn_msg "Previous installation found. Updating..."
    cd "$INSTALL_DIR" && git pull
else
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone "$REPO_URL" "$INSTALL_DIR"
    rm -r "$INSTALL_DIR/.git"
fi

cd "$INSTALL_DIR" || error_msg "Failed to access installation directory"
chmod +x hhotserve.py

mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/hhotserve.py" "$BIN_DIR/hhotserve"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    for shell_rc in ~/.bashrc ~/.zshrc; do
        if [[ -f "$shell_rc" ]]; then
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$shell_rc"
        fi
    done
    warn_msg "Added ~/.local/bin to PATH. Please restart your terminal or run 'source ~/.bashrc'."
fi

success_msg "Installation complete. You can run the program using the command 'hhotserve'."

if command -v hhotserve &> /dev/null; then
    success_msg "✓ 'hhotserve' command is ready to use!"
else
    warn_msg "Please restart your terminal or run 'source ~/.bashrc' to use 'hhotserve'."
fi