# dotfiles

MacBook Pro → MacBook Air 移行用の dotfiles と移行手順。
GNU Stow + Brewfile + `defaults` スクリプトの最小構成にしています。

## 要件整理

| 項目 | 内容 | 方法 |
| --- | --- | --- |
| トラックパッド | タップでクリック / 軌跡の速さ最速 / クリック弱い | 自動 (`scripts/macos-defaults.sh`) |
| キーボード | Caps Lock → Control / 標準のファンクションキー | 自動 (同上) |
| 外観 | ダークモード | 自動 (同上) |
| PowerPoint | 独自ショートカット13個（`scripts/app-shortcuts.sh`） | 自動（PowerPoint を一度起動した後） |
| iTerm2 | 設定を `iterm2/` フォルダから読み込む | 自動（iTerm を終了した状態で実行） |
| Dock | 自動的に隠す / 並びを `dock-apps.txt` から復元 | 自動 (同上) |
| ディスプレイ | スペースを拡大 | **手動** |
| ユーザ辞書 | メアドなど | **手動** (旧 Mac から書き出し) |
| App Store | アカウント新規作成・サインイン | **手動** |
| Xcode CLT / Homebrew | インストール、PATH、`brew update` | 自動 (`setup.sh`) |
| アプリ | Clipy, Rectangle, Slack, Cursor, Notion, Discord, Claude, Notion Calendar, Hyper, Chrome, VS Code, Antigravity, Microsoft Office, Teams | 自動 (`Brewfile`) |
| Brew 以外のアプリ | LINE, Spark (App Store) / Messenger (Web) / Gemini | 自動 (`mas`) / 手動 |
| シェル | oh-my-zsh, `.zshrc`, `.zprofile` | 自動 |
| Git | `.gitconfig`, SSH 鍵, GitHub 認証 | 一部手動 |

## 構成

```
setup.sh                  # 新しい Mac で最初に実行する
Brewfile                  # アプリ一覧
scripts/macos-defaults.sh # macOS 設定
home/                     # $HOME にシンボリックリンクされるファイル
  .zshrc  .zprofile  .gitconfig  .config/git/ignore
```

## 移行手順

### 0. 旧 Mac (MacBook Pro) でやること

1. **ユーザ辞書の書き出し**: システム設定 → キーボード → テキスト入力「ユーザ辞書…」→ 全選択 (⌘A) してデスクトップへドラッグ → `ユーザ辞書.plist` ができる。AirDrop などで新 Mac に渡す（メアドを含むのでこのリポジトリには入れない）
2. 旧 Mac にしかない設定を取り込む場合: `~/.zshrc`、`~/.hyper.js`、`~/.gitconfig` などを `home/` にコピーして commit / push
3. 現状のアプリ一覧を確認したい場合: `brew bundle dump --file=/tmp/Brewfile`
4. 各アプリのログイン情報・2 要素認証が新 Mac で使えることを確認（LINE のトーク履歴引き継ぎなど）

### 1. 新 Mac (MacBook Air) 初期設定（手動）

1. 起動して新規の設定を済ませる
2. App Store のアカウントを新規作成してサインイン（LINE / Spark のインストールに必要）

### 2. セットアップスクリプト実行（自動）

ターミナルで以下を実行。途中でパスワード入力やリターンキーを求められます。

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mohi-mirami/dotfiles/main/setup.sh)"
```

やっていること:

1. `xcode-select --install`（時間がかかる）
2. Homebrew インストール → PATH 設定 → `brew update`
3. このリポジトリを `~/dotfiles` に clone
4. `brew bundle` で Brewfile のアプリを一括インストール
5. oh-my-zsh インストール
6. `home/` 配下を `$HOME` にリンク（既存ファイルは `~/.dotfiles-backup/` に退避）
7. macOS 設定を適用

終わったら一度ログアウト → ログインして設定を反映。

### 3. 手動でやること

- [ ] **ディスプレイ**: システム設定 → ディスプレイ →「スペースを拡大」
- [ ] **ユーザ辞書**: システム設定 → キーボード → ユーザ辞書 に `ユーザ辞書.plist` をドラッグ
- [ ] **Caps Lock → Control の確認**: 効いていなければ システム設定 → キーボード → キーボードショートカット → 修飾キー で設定
- [ ] **Messenger**: Mac 版アプリは提供終了のため <https://www.messenger.com> を利用
- [ ] **各アプリにログイン**: Slack, Notion, Discord, Claude, Cursor, LINE, Spark
- [ ] **Clipy / Rectangle**: 起動してアクセシビリティ権限を許可、ログイン時に起動を ON

### 4. Git 環境

```sh
# 名前とメール（公開リポジトリに入れないため .local に書く）
cat > ~/.gitconfig.local <<'EOF'
[user]
	name = Your Name
	email = you@example.com
EOF

# GitHub 認証（SSH 鍵の生成と登録までやってくれる）
gh auth login   # GitHub.com → SSH → 鍵を新規生成 → ブラウザで認証

# 確認
ssh -T git@github.com

# dotfiles の remote を SSH に切り替え
cd ~/dotfiles && git remote set-url origin git@github.com:mohi-mirami/dotfiles.git
```

## 日常の運用

```sh
# アプリを追加したら Brewfile に追記して
brew bundle --file=~/dotfiles/Brewfile

# 設定ファイルを増やす: home/ に置いて
cd ~/dotfiles && stow --no-folding --target="$HOME" home

# Dock の並びを保存（次の Mac でも同じ並びになる）
~/dotfiles/scripts/dock-save.sh && cd ~/dotfiles && git add dock-apps.txt && git commit -m "Save Dock layout" && git push

# macOS 設定の再適用
~/dotfiles/scripts/macos-defaults.sh
```
