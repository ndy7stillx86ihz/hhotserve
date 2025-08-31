#!/bin/bash

set -e

REPO_URL="https://github.com/ndy7stillx86ihz/hhotserve.git"
INSTALL_DIR="$HOME/.local/opt/hhotserve"
BIN_DIR="$HOME/.local/bin"

print_status() {
    local status="$1"
    local message="$2"
    case "$status" in
        "info")    echo -e "\e[34mℹ\e[0m  $message" ;;
        "success") echo -e "\e[32m✓\e[0m  $message" ;;
        "error")   echo -e "\e[31m✗\e[0m  $message" >&2 ;;
        "warn")    echo -e "\e[33m⚠\e[0m  $message" ;;
        "install") echo -e "\e[36m⬇\e[0m  Installing $message..." ;;
        "check")   echo -e "\e[37m○\e[0m  Checking $message..." ;;
    esac
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

run_silent() {
    local description="$1"
    shift
    print_status "install" "$description"
    if "$@" &>/dev/null; then
        printf "\r"
        print_status "success" "$description installed"
    else
        printf "\r"
        print_status "error" "Failed to install $description"
        exit 1
    fi
}

check_requirement() {
    local cmd="$1"
    local package="$2"
    local description="$3"
    local install_cmd="$4"

    print_status "check" "$description"

    if command -v "$cmd" &> /dev/null; then
        print_status "success" "$description found"
        return 0
    fi

    print_status "warn" "$description not found"
    read -p "$(echo -e "\e[33m?\e[0m")  Install $description? (y/n): " choice

    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        eval "run_silent \"$description\" $install_cmd"
    else
        print_status "error" "$description is required"
        exit 1
    fi
}

check_python_module() {
    local module="$1"
    local description="$2"

    print_status "check" "$description"

    if python3 -c "import $module" &> /dev/null; then
        print_status "success" "$description found"
        return 0
    fi

    print_status "warn" "$description not found"
    read -p "$(echo -e "\e[33m?\e[0m")  Install $description? (y/n): " choice

    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        run_silent "$description" python3 -m pip install --user "$module"
    else
        print_status "error" "$description is required"
        exit 1
    fi
}

check_existing_installation() {
    print_status "check" "Existing installation"

    if command -v hhotserve &> /dev/null || [[ -d "$INSTALL_DIR" ]]; then
        print_status "warn" "Previous installation detected"
        read -p "$(echo -e "\e[33m?\e[0m")  Remove existing installation and reinstall? (y/n): " choice

        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            print_status "install" "Removing previous installation"

            if [[ -L "$BIN_DIR/hhotserve" ]]; then
                rm -f "$BIN_DIR/hhotserve" &>/dev/null || true
            fi

            if [[ -d "$INSTALL_DIR" ]]; then
                rm -rf "$INSTALL_DIR" &>/dev/null || true
            fi

            print_status "success" "Previous installation removed"
        else
            print_status "error" "Installation cancelled"
            exit 1
        fi
    else
        print_status "success" "No previous installation found"
    fi
}

install_hhotserve() {
    print_status "install" "Downloading hhotserve"

    mkdir -p "$(dirname "$INSTALL_DIR")" &>/dev/null

    if git clone "$REPO_URL" "$INSTALL_DIR" &>/dev/null; then
        print_status "success" "hhotserve downloaded"
    else
        print_status "error" "Failed to download hhotserve"
        exit 1
    fi

    print_status "install" "Cleaning up repository files"
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        rm -rf "$INSTALL_DIR/.git" &>/dev/null
        print_status "success" "Repository cleanup completed"
    fi
}

setup_executable() {
    print_status "info" "Setting up executable"

    cd "$INSTALL_DIR" || {
        print_status "error" "Failed to access installation directory"
        exit 1
    }

    chmod +x hhotserve.py
    mkdir -p "$BIN_DIR"

    if ln -sf "$INSTALL_DIR/hhotserve.py" "$BIN_DIR/hhotserve" &>/dev/null; then
        print_status "success" "Executable created at $BIN_DIR/hhotserve"
    else
        print_status "error" "Failed to create executable"
        exit 1
    fi
}

setup_path() {
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        print_status "info" "Configuring PATH"

        local path_added=false
        for shell_rc in ~/.bashrc ~/.zshrc ~/.profile; do
            if [[ -f "$shell_rc" ]]; then
                if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$shell_rc" 2>/dev/null; then
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
                    path_added=true
                fi
            fi
        done

        if $path_added; then
            print_status "success" "PATH configured"
            print_status "warn" "Restart terminal or run 'source ~/.bashrc' to use 'hhotserve'"
        fi
    else
        print_status "success" "PATH already configured"
    fi
}

verify_installation() {
    print_status "check" "Installation verification"

    if [[ -x "$INSTALL_DIR/hhotserve.py" ]] && [[ -L "$BIN_DIR/hhotserve" ]]; then
        print_status "success" "Installation verified"

        if command -v hhotserve &> /dev/null; then
            print_status "success" "✓ 'hhotserve' command is ready to use!"
            print_status "info" "Run 'hhotserve --help' to see usage options"
        else
            print_status "warn" "Restart your terminal to use 'hhotserve' command"
        fi
    else
        print_status "error" "Installation verification failed"
        exit 1
    fi
}

main() {
    echo -e "\e[1;34m"
    echo "╔══════════════════════════════════════╗"
    echo "║        HHOTSERVE INSTALLER           ║"
    echo "║   HTTP Hot Reload Server Setup       ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "\e[0m"

    print_status "check" "System compatibility"
    if command -v apt &> /dev/null; then
        print_status "success" "Debian-based system detected"
    else
        print_status "error" "This script is intended for Debian-based systems"
        exit 1
    fi

    check_requirement "python3" "python3" "Python3" "sudo apt update && sudo apt install python3 -y"
    check_requirement "git" "git" "Git" "sudo apt update && sudo apt install git -y"

    if ! command -v pip3 &> /dev/null; then
        print_status "check" "pip3"
        print_status "warn" "pip3 not found"
        read -p "$(echo -e "\e[33m?\e[0m")  Install pip3? (y/n): " choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            run_silent "pip3" sudo apt update && sudo apt install python3-pip -y
        else
            print_status "error" "pip3 is required"
            exit 1
        fi
    else
        print_status "success" "pip3 found"
    fi

    check_python_module "watchdog" "Python watchdog module"

    check_existing_installation
    install_hhotserve
    setup_executable
    setup_path
    verify_installation

    echo
    print_status "success" "Installation completed successfully!"
    echo -e "\e[1;32m"
    echo "╔══════════════════════════════════════╗"
    echo "║            READY TO USE!             ║"
    echo "║                                      ║"
    echo "║  Usage: hhotserve [directory]        ║"
    echo "║  Help:  hhotserve --help             ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "\e[0m"
}