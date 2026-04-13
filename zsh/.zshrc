export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-$LANG}"
export LC_CTYPE="${LC_CTYPE:-$LANG}"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="apple"
CASE_SENSITIVE="true"
plugins=(git)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

[ -f "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

export NODE_PATH="${NODE_PATH:+$NODE_PATH:}/usr/local/lib/node_modules"
export TERM="${TERM:-xterm-256color}"
export CONDA_CHANGEPS1=false

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

if typeset -f toon >/dev/null 2>&1; then
  zstyle ':vcs_info:*' unstagedstr '*'
  zstyle ':vcs_info:*' stagedstr '+'
  zstyle ':vcs_info:*' actionformats '%b|%a%c%u'
  zstyle ':vcs_info:*' formats '%b%c%u'

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
    [[ -n "$CONDA_DEFAULT_ENV" ]] || return 0
    print -n "%F{186}(${CONDA_DEFAULT_ENV})%f "
  }

  prompt_vcs_segment() {
    [[ -n "$vcs_info_msg_0_" ]] || return 0
    print -n " %F{222}git:%f %F{252}${vcs_info_msg_0_}%f"
  }

  PROMPT=$'$(prompt_env_segment)%F{177}%f %F{117}%n@%m%f %F{159}%3~%f$(prompt_vcs_segment)\n%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%})❯%{$reset_color%} '
  RPROMPT='%F{252}%D{%H:%M:%S}%f'
fi

if [ -f "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[command]='fg=green'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
fi
