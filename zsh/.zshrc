() { # 初期設定
  typeset -r init_file="${ZDOTDIR}/zshrc.d/init.zsh"
  [[ -s ${init_file} ]] && source ${init_file}
}
() { # 環境変数の設定
  typeset -r env_file="${ZDOTDIR}/zshrc.d/env.zsh"
  [[ -s ${env_file} ]] && source ${env_file}
}

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>' # 区切りとして扱わない文字。
# 実行したプロセスの消費時間が3秒以上かかったら、消費時間の統計情報を表示する。
REPORTTIME=3
# 画面のロックと解除を無効(C-s,C-q)
setopt no_flow_control
# beep音停止
setopt no_beep
setopt no_list_beep
setopt no_hist_beep
# コマンドの打ち損じを修正
setopt correct
# <C-d>でログアウトしないようにする。
setopt ignore_eof
# リダイレクトで上書き禁止(>)。上書きをする場合は>|を使う。
setopt noclobber
() { # fishのようなsyntax-highlighting
  typeset -r highlighting='/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
  [[ -s ${highlighting} ]] && source ${highlighting}
}

# _fzf_cd_widget(), vim() で用いる。無視するディレクトリを絶対パスで指定する。
typeset -r ignore_absolute_pathes=(
  ${HOME}/Downloads
  ${HOME}/.cache/dein/repos
  ${HOME}/.cache/dein/.cache
  ${HOME}/.cache/pip
  ${HOME}/.cache/jedi
  ${HOME}/.cache/yarn
  ${HOME}/.cache/go-build
  ${HOME}/.cache/fontconfig
  ${HOME}/.cache/neosnippet
  ${HOME}/.cache/typescript/2.6
  ${HOME}/.cache/chromium
  ${HOME}/.config/chromium
  ${HOME}/.config/pulse
  ${HOME}/.config/VirtualBox
  ${HOME}/.config/fcitx
  ${HOME}/.config/Code
  ${HOME}/.config/undo
  ${HOME}/.node-gyp
  ${HOME}/.electron-gyp
  ${HOME}/.rustup
  ${HOME}/.cargo
  ${HOME}/.vscode/extensions
  ${HOME}/.WebStorm2018.1 
  ${HOME}/.npm/_cacache
  ${HOME}/.nvm/versions
  ${HOME}/.Trash
  ${GOPATH}/pkg
  ${GOPATH}/src/gopkg.in
  ${GOPATH}/src/github.com
  ${GOPATH}/src/golang.org
)

autoload -Uz colors && colors
() { # 左右promptの設定
  typeset -r prompt_file="${ZDOTDIR}/zshrc.d/prompt.zsh"
  [[ -s ${prompt_file} ]] && source ${prompt_file}
}
() { # tmuxの左のstatus_bar
  typeset -r tmux_file="${ZDOTDIR}/zshrc.d/tmux.zsh"
  [[ -s ${tmux_file} ]] && source ${tmux_file}
}
() { # 補完
  typeset -r completion_file="${ZDOTDIR}/zshrc.d/completion.zsh"
  [[ -s ${completion_file} ]] && source ${completion_file}
}
() { # 履歴
  typeset -r history_file="${ZDOTDIR}/zshrc.d/history.zsh"
  [[ -s ${history_file} ]] && source ${history_file}
}
() { # vi(insert-mode: emacs)
  typeset -r keybind_file="${ZDOTDIR}/zshrc.d/keybind.zsh"
  [[ -s ${keybind_file} ]] && source ${keybind_file}
}
() { # A command-line fuzzy finder(filter, 選択的interface)の設定
  typeset -r fzf_file="${ZDOTDIR}/zshrc.d/fzf.zsh"
  [[ -s ${fzf_file} ]] && source ${fzf_file}
}
() { # nvm(Node version manager)の設定
  typeset -r nvm_file="${ZDOTDIR}/zshrc.d/nvm.zsh"
  [[ -s ${nvm_file} ]] && source ${nvm_file}
}
() { # 関数の定義
  typeset -r functions_file="${ZDOTDIR}/zshrc.d/functions.zsh"
  [[ -s ${functions_file} ]] && source ${functions_file}
}
() { # aliasの定義
  typeset -r aliases_file="${ZDOTDIR}/zshrc.d/aliases.zsh"
  [[ -s ${aliases_file} ]] && source ${aliases_file}
}
