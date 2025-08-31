#!/bin/bash
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

echo "Installation complete. You can run the program using the command 'hhotserve'."