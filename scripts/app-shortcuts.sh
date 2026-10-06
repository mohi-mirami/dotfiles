#!/bin/bash
# アプリごとのキーボードショートカット（システム設定 → キーボード → アプリのショートカット）を復元する。
# 記号: @=Command, ~=Option, ^=Control, $=Shift。メニュー階層は ESC 文字（\e）で区切る。
set -euo pipefail

# --- Microsoft PowerPoint ---
ppt=com.microsoft.Powerpoint
if [ -d "$HOME/Library/Containers/$ppt" ]; then
  add() { defaults write "$ppt" NSUserKeyEquivalents -dict-add "$1" "$2"; }
  add $'\e挿入\eセクション' '@^m'
  add $'\e配置\e配置/整列\e右揃え' '^r'
  add $'\e配置\e配置/整列\e左揃え' '^l'
  add 'グリッド線' '^$g'
  add '上下に整列' '^v'
  add '上下中央揃え' '^m'
  add '上揃え' '^t'
  add '下揃え' '^b'
  add '左右に整列' '^h'
  add '左右中央揃え' '^c'
  add '正方形/長方形' '@~h'
  add '線' '@~l'
  add '置換...' '@^h'
  echo "PowerPoint のショートカットを設定しました（PowerPoint を再起動すると反映されます）。"
else
  echo "PowerPoint が未起動のためショートカットは未設定です。一度起動して終了してから、このスクリプトを再実行してください。"
fi
