#!/usr/bin/env bash

set -e

echo "==> Обновляем систему"
sudo pacman -Syu --noconfirm

echo "==> Устанавливаем пакеты"
sudo pacman -S --noconfirm \
  zsh git curl wget unzip \
  lsd bat fd ripgrep zoxide fzf

# -------------------------------
# Чистая установка Oh My Zsh
# -------------------------------
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Удаляем старый Oh My Zsh"
    rm -rf "$HOME/.oh-my-zsh"
fi

if [ -f "$HOME/.zshrc" ]; then
    echo "==> Удаляем старый .zshrc"
    rm -f "$HOME/.zshrc"
fi

echo "==> Устанавливаем Oh My Zsh"
RUNZSH=no CHSH=no sh -c \
"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# -------------------------------
# Отключаем warning Powerlevel10k
# -------------------------------
sed -i '1i typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet' ~/.zshrc

# -------------------------------
# Powerlevel10k
# -------------------------------
echo "==> Устанавливаем Powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# -------------------------------
# Плагины
# -------------------------------
echo "==> Устанавливаем плагины"

git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

sed -i 's/^plugins=.*/plugins=(git archlinux zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# -------------------------------
# Aliases (modern replacements)
# -------------------------------
echo "==> Настраиваем modern CLI"

cat << 'EOF' >> ~/.zshrc

# modern replacements
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

alias cat='bat'
alias find='fd'
alias grep='rg'

# zoxide
eval "$(zoxide init zsh)"

# fzf keybindings
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

EOF

# -------------------------------
# Shell
# -------------------------------
echo "==> Меняем shell на Zsh"
chsh -s /bin/zsh || true

echo "==> Готово!"

if [ -n "$BASH_VERSION" ]; then
    exec zsh
fi
