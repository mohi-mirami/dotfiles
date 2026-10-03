#!/bin/bash
# 新しい Mac のセットアップ。何度実行しても安全（冪等）。
set -euo pipefail

REPO="${DOTFILES_REPO:-mohi-mirami/dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }

# 1. Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  log "Xcode Command Line Tools をインストール（ダイアログに従ってください。時間がかかります）"
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
fi

# 2. Homebrew
if [ ! -x /opt/homebrew/bin/brew ]; then
  log "Homebrew をインストール"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update

# 3. dotfiles を取得
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  log "dotfiles を clone"
  git clone "https://github.com/$REPO.git" "$DOTFILES_DIR"
fi
cd "$DOTFILES_DIR"

# 4. アプリ一括インストール
log "brew bundle"
brew bundle --file="$DOTFILES_DIR/Brewfile" || echo "一部失敗しました（App Store 未サインインなら mas が失敗します）。後で再実行してください。"

# 5. oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "oh-my-zsh をインストール"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 6. dotfiles をホームにリンク（既存の実ファイルは退避）
log "dotfiles をリンク"
backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
(cd "$DOTFILES_DIR/home" && find . -type f) | while read -r f; do
  target="$HOME/${f#./}"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$backup/$(dirname "${f#./}")"
    mv "$target" "$backup/${f#./}"
    echo "退避: $target -> $backup/${f#./}"
  fi
done
stow --no-folding --dir="$DOTFILES_DIR" --target="$HOME" home

# 7. macOS 設定
log "macOS 設定を適用"
"$DOTFILES_DIR/scripts/macos-defaults.sh"

log "完了。残りの手動作業は README の「手動でやること」を参照してください。"
