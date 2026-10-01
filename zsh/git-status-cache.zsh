# git 状态快照：提示符不再每次扫工作区，只在两种时机刷新——
#   1) 进入一个新的仓库时自动算一次；
#   2) 手动刷新：Cmd+M 连按两次（终端把 Cmd+M 映射成 ESC[9001~），
#      或 Ctrl+X Ctrl+G，或执行 `git-refresh`（别名 `mgit`）。
# 分支名仍由 Starship 实时读取（只读 .git/HEAD，几乎零开销）。
# 结果放进 GITC_STATUS / GITC_SYNCED，由 starship.toml 的 env_var 模块显示。
# 注意：不联网，⇡⇣ 以最近一次 git fetch 为准。

typeset -g _gitc_root=""

_gitc_clear() { unset GITC_STATUS GITC_SYNCED; }

# 纯 zsh 向上找 .git，不起进程
_gitc_find_root() {
  local d=$PWD
  while :; do
    [[ -e $d/.git ]] && { REPLY=$d; return 0 }
    [[ $d == / ]] && return 1
    d=${d:h}
  done
}

_gitc_refresh() {
  _gitc_clear
  local out
  out=$(git status --porcelain=v2 --branch 2>/dev/null) || return
  local -i staged=0 modified=0 deleted=0 renamed=0 untracked=0 conflicted=0 ahead=0 behind=0 stashed=0
  local has_upstream=0 line xy
  for line in ${(f)out}; do
    case $line in
      '# branch.upstream '*) has_upstream=1 ;;
      '# branch.ab '*)
        local -a ab=(${=line})
        ahead=${ab[3]#+}; behind=${ab[4]#-} ;;
      '1 '*|'2 '*)
        xy=${line[3,4]}
        [[ ${xy[1]} != . ]] && staged+=1
        [[ ${xy[2]} == M ]] && modified+=1
        [[ ${xy[2]} == D || ${xy[1]} == D ]] && deleted+=1
        [[ $line == 2\ * ]] && renamed+=1 ;;
      'u '*) conflicted+=1 ;;
      '? '*) untracked+=1 ;;
    esac
  done
  stashed=$(git rev-list --walk-reflogs --count refs/stash 2>/dev/null || print 0)

  local s=""
  (( conflicted )) && s+="=$conflicted "
  (( stashed ))    && s+="\$$stashed "
  (( deleted ))    && s+="✘$deleted "
  (( renamed ))    && s+="»$renamed "
  (( modified ))   && s+="!$modified "
  (( staged ))     && s+="+$staged "
  (( untracked ))  && s+="?$untracked "
  if (( ahead && behind )); then s+="⇕⇡$ahead⇣$behind "
  elif (( ahead )); then s+="⇡$ahead "
  elif (( behind )); then s+="⇣$behind "
  fi
  [[ -n $s ]] && export GITC_STATUS=${s% }

  # ✓：工作区干净 + 有上游 + 不领先不落后（stash 不算改动）
  if (( has_upstream && !ahead && !behind && !staged && !modified && !deleted && !renamed && !untracked && !conflicted )); then
    export GITC_SYNCED=1
  fi
}

_gitc_precmd() {
  if _gitc_find_root; then
    [[ $REPLY == $_gitc_root ]] && return
    _gitc_root=$REPLY
    _gitc_refresh
  else
    _gitc_root=""
    _gitc_clear
  fi
}

_gitc_widget() {
  _gitc_refresh
  zle reset-prompt
}

git-refresh() { _gitc_refresh }
alias mgit=git-refresh

autoload -Uz add-zsh-hook
add-zsh-hook precmd _gitc_precmd
zle -N _gitc_widget
_gitc_noop() { :; }
zle -N _gitc_noop
bindkey '^X^G' _gitc_widget
bindkey '\e[9001~\e[9001~' _gitc_widget   # Cmd+M Cmd+M
bindkey '\e[9001~' _gitc_noop              # 单按 Cmd+M：0.4 s 内没第二下就忽略
