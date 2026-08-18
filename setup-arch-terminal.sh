#!/usr/bin/env bash

set -euo pipefail

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
RUNZSH=no CHSH=no KEEP_ZSHRC=no sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# -------------------------------
# Отключаем warning Powerlevel10k
# -------------------------------
if ! grep -q 'POWERLEVEL9K_INSTANT_PROMPT' "$HOME/.zshrc"; then
  sed -i '1i typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet' "$HOME/.zshrc"
fi

# -------------------------------
# Powerlevel10k
# -------------------------------
echo "==> Устанавливаем Powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"

# -------------------------------
# Плагины
# -------------------------------
echo "==> Устанавливаем плагины"

git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

if ! grep -q 'zsh-syntax-highlighting' "$HOME/.zshrc"; then
  sed -i 's/^plugins=.*/plugins=(git archlinux zsh-syntax-highlighting zsh-autosuggestions)/' "$HOME/.zshrc"
fi

# -------------------------------
# Aliases (modern replacements)
# -------------------------------
echo "==> Настраиваем modern CLI"

cat <<'EOF' >> "$HOME/.zshrc"

alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

alias cat='bat'
alias find='fd'
alias grep='rg'

eval "$(zoxide init zsh)"

[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

EOF

# -------------------------------
# Shell
# -------------------------------
echo "==> Меняем shell на Zsh"
chsh -s /bin/zsh "$USER" || true

# -------------------------------
# Powerlevel10k configure (first run)
# -------------------------------
echo "==> Запуск интерактивной настройки Powerlevel10k"
if command -v zsh >/dev/null 2>&1; then
  zsh -i -c 'p10k configure' || true
fi

echo "==> Готово! Перезапустите компьютер или выйдите из текущей сессии, чтобы изменения вступили в силу."

if [ -n "${BASH_VERSION:-}" ]; then
  exec zsh -l
fi
