# Copy this file to ~/.zshrc and customize the project-specific block at the
# bottom if needed.

# Show system info once per new terminal session (e.g. a new Ghostty window),
# but not when a subshell (nested zsh, tmux pane, etc.) re-sources this file.
if [[ $- == *i* && -z "$FASTFETCH_SHOWN" ]] && (( $+commands[fastfetch] )); then
  fastfetch
  export FASTFETCH_SHOWN=1
fi

# Enable Powerlevel10k instant prompt. Keep this near the top of ~/.zshrc.
# Initialization code that may require console input must go above this block;
# everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Detect if we're in a dev container (Docker or Podman).
if [[ -f "/.dockerenv" ]] || \
   [[ -n "$REMOTE_CONTAINERS" ]] || \
   [[ -f "/run/.containerenv" ]]; then
  INSIDE_CONTAINER=true
else
  INSIDE_CONTAINER=false
fi

# Homebrew on Apple Silicon macOS.
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory used by zinit.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit if it is missing and git is available.
if [[ ! -d "$ZINIT_HOME" ]] && (( $+commands[git] )); then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit and plugins only when installed.
if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  zinit ice depth=1
  zinit light romkatv/powerlevel10k

  # Synchronous loading keeps Powerlevel10k instant prompt happy.
  zinit ice blockf
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light hlissner/zsh-autopair
  zinit light Aloxaf/fzf-tab

  # history-substring-search must load before syntax highlighting.
  zinit light zsh-users/zsh-history-substring-search
  zinit light zdharma-continuum/fast-syntax-highlighting

  zinit snippet OMZL::git.zsh
  zinit snippet OMZP::git
  zinit snippet OMZP::sudo
  zinit snippet OMZP::archlinux
  zinit snippet OMZP::aws
  zinit snippet OMZP::kubectl
  zinit snippet OMZP::kubectx
  zinit snippet OMZP::command-not-found

  autoload -Uz compinit
  if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi

  zinit cdreplay -q
fi

# To customize the prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# Fix Delete, Home, and End keys.
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# History substring search bindings.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Use terminfo for better terminal compatibility when available.
if (( ${+terminfo} )); then
  [[ -n "${terminfo[kdch1]}" ]] && bindkey "${terminfo[kdch1]}" delete-char
  [[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
  [[ -n "${terminfo[kend]}" ]] && bindkey "${terminfo[kend]}" end-of-line
fi

# History
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Additional useful options
setopt autocd
setopt interactive_comments
setopt extended_glob
setopt no_beep

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Environment variables and PATH
typeset -U path PATH
[[ -d "$HOME/.npm-global/bin" ]] && path=("$HOME/.npm-global/bin" $path)
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export VISUAL="${VISUAL:-nvim}"
export EDITOR="${EDITOR:-$VISUAL}"

# Aliases
alias vim='nvim'
alias c='clear'
alias restow='(cd "$DOTFILES" && ./install.sh -r)'

if (( $+commands[eza] )); then
  alias ls='eza --color=auto --group-directories-first'
else
  alias ls='ls --color'
fi

if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
elif (( $+commands[batcat] )); then
  alias cat='batcat --paging=never'
fi

alias please='sudo $(fc -ln -1)'
alias zshrc='${=EDITOR} ${ZDOTDIR:-$HOME}/.zshrc'

alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS}'

alias h='history'
alias hgrep='fc -El 0 | grep'

alias dud='du -d 1 -h'
(( $+commands[duf] )) || alias duf='du -sh *'

alias ...='../..'
alias ....='../../..'
alias .....='../../../..'
alias d='dirs -v | head -10'

# Global aliases for piping.
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L='| less'
alias -g NE='2> /dev/null'
alias -g NUL='> /dev/null 2>&1'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }

extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.tar.xz) tar xJf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *.rar) unrar x "$1" ;;
      *.zst) unzstd "$1" ;;
      *) echo "extract: unknown format '$1'" ;;
    esac
  else
    echo "extract: '$1' is not a valid file"
  fi
}

# Shell integrations
(( $+commands[fzf] )) && eval "$(fzf --zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"

my-aliases() {
  echo ""
  echo "  Your Shell Aliases"
  echo "  ------------------"
  awk '
    /^# [A-Za-z]/ {
      header=$0
      sub(/^# /, "", header)
    }
    /^alias/ {
      if (header != "") {
        print "\n" header
        header=""
      }
      sub(/^alias /, "")
      sub(/=/, "  ->  ")
      gsub(/'\''/, "")
      print "  " $0
    }
  ' ~/.zshrc
  echo ""
}

# Project-specific aliases and paths:
# Add hostnames, playbook paths, SSH shortcuts, or deployment helpers here.
# Example:
# export PLAYBOOK_DIR="$HOME/path/to/ansible-playbook"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
