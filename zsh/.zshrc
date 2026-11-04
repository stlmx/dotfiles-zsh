# Avoid stacking prompt hooks when ~/.zshrc is sourced repeatedly.
if [[ -n "${__DOTFILES_ZSHRC_LOADED:-}" ]]; then
  setopt promptsubst
  return
fi
typeset -g __DOTFILES_ZSHRC_LOADED=1

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-$LANG}"
export LC_CTYPE="${LC_CTYPE:-$LANG}"
export TERM="${TERM:-xterm-256color}"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

if [ -d /usr/local/lib/node_modules ]; then
  export NODE_PATH="${NODE_PATH:+$NODE_PATH:}/usr/local/lib/node_modules"
fi

export CONDA_CHANGEPS1=false
export VIRTUAL_ENV_DISABLE_PROMPT=1

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
CASE_SENSITIVE="true"
plugins=(git extract)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if [ -f "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if command -v conda >/dev/null 2>&1; then
  __conda_setup="$(conda shell.zsh hook 2>/dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  fi
  unset __conda_setup
fi

command -v conda >/dev/null 2>&1 && alias ca='conda activate'
command -v claude >/dev/null 2>&1 && alias cc='claude'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

prompt_os_symbol() {
  case "$OSTYPE" in
    darwin*) print -n "" ;;
    linux*) print -n "" ;;
    *) print -n "●" ;;
  esac
}

prompt_env_segment() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local env_name
    env_name="$(basename "$VIRTUAL_ENV")"
    if [[ "$env_name" == ".venv" ]]; then
      env_name="$(basename "$(dirname "$VIRTUAL_ENV")")"
    fi
    print -n "%F{186}(${env_name})%f "
    return 0
  fi

  [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]] || return 0
  print -n "%F{186}(${CONDA_DEFAULT_ENV})%f "
}

prompt_vcs_segment() {
  [[ -n "$vcs_info_msg_0_" ]] || return 0
  print -n " %F{222}git:%f %F{252}${vcs_info_msg_0_}%f"
}

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  autoload -Uz colors vcs_info
  colors
  setopt prompt_subst
  zstyle ':vcs_info:*' unstagedstr '*'
  zstyle ':vcs_info:*' stagedstr '+'
  zstyle ':vcs_info:*' actionformats '%b|%a%c%u'
  zstyle ':vcs_info:*' formats '%b%c%u'
  precmd_functions+=(vcs_info)

  PROMPT=$'$(prompt_env_segment)%F{177}$(prompt_os_symbol)%f %F{117}%n@%m%f %F{159}%3~%f$(prompt_vcs_segment)\n%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%})❯%{$reset_color%} '
  RPROMPT='%F{252}%D{%H:%M:%S}%f'
fi

# git 状态快照（mgit / Ctrl+X Ctrl+G / Cmd+M×2 刷新），见 git-status-cache.zsh
# 依次找：.zshrc 软链指向的目录 → $DOTFILES_ZSH_DIR → ~/dotfiles-zsh（~/.zshrc 是拷贝而非软链时也能找到）
() {
  local f
  for f in "${${(%):-%x}:A:h}" "${DOTFILES_ZSH_DIR:+$DOTFILES_ZSH_DIR/zsh}" "$HOME/dotfiles-zsh/zsh"; do
    [[ -n $f && -r $f/git-status-cache.zsh ]] && { source "$f/git-status-cache.zsh"; return }
  done
  print -u2 "[dotfiles-zsh] 未找到 git-status-cache.zsh，mgit 不可用；请在 ~/dotfiles-zsh 运行 ./sync.sh"
}

if [ -f "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[command]='fg=green'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
fi

setopt promptsubst

# >>> otty shell integration >>>
# Added by Otty — toggle in Settings > Shell > Shell Integration.
# Inert unless launched by Otty (it sets $OTTY_SHELL_INTEGRATION).
if [ -n "$ZSH_VERSION" ] && [ -n "$OTTY_SHELL_INTEGRATION" ] && [ -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi
# <<< otty shell integration <<<

# eza 代替 ls：图标、Git 状态、目录优先（没装 eza 的机器上保持原生 ls）
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lh --icons=auto --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto --git-ignore'
fi

# bat 代替 cat：语法高亮、行号、Git 改动标记（Ubuntu 上 apt 装的叫 batcat；都没装就保持原生 cat）
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  alias bat='batcat'
fi
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
  export BAT_THEME="ansi"
  alias cat='bat --paging=never'
fi

# fzf：Ctrl+R 模糊搜历史命令，Ctrl+T 模糊找文件（右边预览：文件用 bat，文件夹用 eza）
if command -v fzf >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview '[ -d {} ] && eza --tree --level=1 --icons=always --color=always {} || bat --color=always --style=numbers --line-range=:200 {}'"
  eval "$(fzf --zsh 2>/dev/null)"
fi

# zoxide：z 关键词 跳到常去的目录，zi 从列表里挑
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Yazi：终端里的文件管理器。用 y 启动，按 q 退出时终端跟着进到最后停留的目录（Q 退出则不跳）
if command -v yazi >/dev/null 2>&1; then
  function y() {
    local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
    command rm -f -- "$tmp"
  }
fi
