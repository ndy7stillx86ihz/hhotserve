#!/bin/bash
if ! command -v apt &> /dev/null; then
    echo -e "\e[33mThis script is intended for Debian-based systems. Exiting.\e[0m"
    exit 1
fi
if ! command -v python3 &> /dev/null; then
    read -p "Python3 is not installed. Do you want to install it? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
      sudo apt install python3 -y
    else
echo -e "\e[33mPython3 is required. Exiting.\e[0m"
        exit 1
    fi
fi
if ! command -v watchmedo &> /dev/null; then
    read -p "watchdog is not installed. Do you want to install it? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
      sudo apt install python3-watchdog -y
    else
        echo -e "\e[33mwatchdog python dependency is required. Exiting.\e[0m"
        exit 1
    fi
fi
if ! command -v git &> /dev/null; then
    read -p "git is not installed. Do you want to install it? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
      sudo apt install git -y
    else
        echo -e "\e[33mgit is required. Exiting.\e[0m"
        exit 1
    fi
fi

mkdir -p ~/.local/opt/hhotserve
cd ~/.local/opt/hhotserve || exit
git clone https://github.com/ndy7stillx86ihz/hhotserve.git
cd hhotserve || exit
chmod +x hhotserve.py
ln -s "$HOME"/.local/opt/hhotserve/hhotserve.py ~/.local/bin/hhotserve

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    echo "Added ~/.local/bin to PATH. Please restart your terminal or run 'source ~/.bashrc' or 'source ~/.zshrc'."
fi

echo -e "\e[32mInstallation complete. You can run the program using the command 'hhotserve'.\e[0m"