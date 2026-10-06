#!/bin/bash
# macOS のシステム設定を一括適用する。
set -euo pipefail

# --- トラックパッド ---
# タップでクリック
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# 軌跡の速さ: 最速 (0〜3)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3
# クリック: 弱い (0=弱い, 1=中, 2=強い)
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

# --- キーボード ---
# F1, F2 などを標準のファンクションキーとして使用
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Caps Lock -> Control（ログイン時に hidutil で適用する LaunchAgent）
plist="$HOME/Library/LaunchAgents/local.capslock-to-control.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.capslock-to-control</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$plist"

# --- 外観 ---
# ダークモード
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null \
  || defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# --- Dock ---
# 自動的に表示/非表示
defaults write com.apple.dock autohide -bool true
# 並び順を dock-apps.txt（scripts/dock-save.sh で保存）から復元
dock_list="$(cd "$(dirname "$0")/.." && pwd)/dock-apps.txt"
if [ -s "$dock_list" ] && command -v dockutil >/dev/null 2>&1; then
  dockutil --remove all --no-restart >/dev/null
  while IFS= read -r app; do
    [ -e "$app" ] && dockutil --add "$app" --section apps --no-restart >/dev/null
  done < "$dock_list"
  dockutil --add "$HOME/Downloads" --view fan --display stack --section others --no-restart >/dev/null
fi
killall Dock 2>/dev/null || true

echo "macOS 設定を適用しました。トラックパッド等が反映されない場合は一度ログアウトしてください。"
