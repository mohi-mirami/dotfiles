#!/bin/bash
# 現在の Dock のアプリの並びを dock-apps.txt に保存する。
set -euo pipefail
out="$(cd "$(dirname "$0")/.." && pwd)/dock-apps.txt"
defaults read com.apple.dock persistent-apps \
  | sed -nE 's/.*"_CFURLString" = "file:\/\/(.*)";/\1/p' \
  | python3 -c 'import sys, urllib.parse
for line in sys.stdin:
    print(urllib.parse.unquote(line.strip()).rstrip("/"))' > "$out"
echo "$(wc -l < "$out" | tr -d ' ') 個のアプリを $out に保存しました。"
