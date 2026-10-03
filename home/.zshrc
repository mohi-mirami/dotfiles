export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# マシン固有・非公開の設定
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
