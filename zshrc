# ================================================================
# Zsh Configuration
# Fedora-focused, fast, modern, and reload-safe
# ================================================================


# ================================================================
# 01. Interactive shell
# ================================================================

[[ -o interactive ]] || return


# ================================================================
# 02. Environment
# ================================================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"

export PAGER="less"
export LESS="-R"

export PATH="$HOME/.local/bin:$PATH"

typeset -U path PATH
typeset -U fpath


# ================================================================
# 03. Zsh options
# ================================================================

setopt AUTO_CD

setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

setopt INTERACTIVE_COMMENTS

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

setopt NO_BEEP
setopt NO_FLOW_CONTROL

setopt NUMERIC_GLOB_SORT
setopt EXTENDED_GLOB

setopt AUTO_PARAM_SLASH
setopt MARK_DIRS

# Prevent accidental overwrite with >
setopt NO_CLOBBER


# ================================================================
# 04. History
# ================================================================

HISTFILE="$HOME/.zsh_history"

HISTSIZE=200000
SAVEHIST=200000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS

setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

setopt EXTENDED_HISTORY


# ================================================================
# 05. Cache
# ================================================================

ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"

[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"


# ================================================================
# 06. Completion
# ================================================================

# IMPORTANT:
# Do not manually replace the system fpath.
# A correctly installed Zsh already has its standard completion
# directories in fpath.

autoload -Uz compinit 2>/dev/null

ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump"

if (( $+functions[compinit] )); then

    # Rebuild/check the dump if it is missing or older than 24h.
    if [[ ! -s "$ZSH_COMPDUMP" ||
          -n "$ZSH_COMPDUMP"(#qN.mh+24) ]]; then

        compinit -i -d "$ZSH_COMPDUMP" 2>/dev/null

    else

        # Fast path.
        compinit -C -d "$ZSH_COMPDUMP" 2>/dev/null

    fi

fi


# ================================================================
# 07. Completion styles
# ================================================================

zstyle ':completion:*' menu select

zstyle ':completion:*' auto-description 'specify: %d'

zstyle ':completion:*' verbose yes

zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*'

zstyle ':completion:*' group-name ''

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

zstyle ':completion:*:descriptions' \
    format '%F{blue}-- %d --%f'

zstyle ':completion:*:warnings' \
    format '%F{red}Nothing found%f'

zstyle ':completion:*:*:kill:*' \
    menu yes select

zstyle ':completion:*:*:*:processes' \
    command 'ps -au$USER'

if [[ -n "$LS_COLORS" ]]; then
    zstyle ':completion:*' list-colors \
        "${(s.:.)LS_COLORS}"
fi


# ================================================================
# 08. Word navigation
# ================================================================

autoload -Uz select-word-style
select-word-style bash


# ================================================================
# 09. Hooks
# ================================================================

autoload -Uz add-zsh-hook

hook_replace() {
    local hook="$1"
    local function="$2"

    add-zsh-hook -d "$hook" "$function" 2>/dev/null
    add-zsh-hook "$hook" "$function"
}


# ================================================================
# 10. Colors / Git
# ================================================================

autoload -Uz colors vcs_info

colors

setopt PROMPT_SUBST

zstyle ':vcs_info:*' enable git

zstyle ':vcs_info:git:*' formats \
    '%F{8}on%f %F{yellow}%b%f'

zstyle ':vcs_info:git:*' actionformats \
    '%F{8}on%f %F{red}%b*%f'


# ================================================================
# 11. Prompt
# ================================================================

venv_prompt() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        print -n "%F{8}via%f %F{magenta}${VIRTUAL_ENV:t}%f "
    fi
}


prompt_vcs() {
    vcs_info
}


prompt_spacer() {
    print ''
}


prompt_exit_status() {
    local exit_code=$?

    if (( exit_code != 0 )); then
        RPROMPT="%F{red}✗ ${exit_code}%f"
    else
        RPROMPT=''
    fi
}


hook_replace precmd prompt_vcs
hook_replace precmd prompt_spacer
hook_replace precmd prompt_exit_status


prompt_path() {
    local path="${PWD/#$HOME/home}"

    if [[ "$path" == /* ]]; then
        local -a parts
        parts=("${(@s:/:)path}")

        if (( ${#parts[@]} > 2 )); then
            print -n "${parts[-2]}/${parts[-1]}"
        else
            print -n "$path"
        fi
    else
        print -n "$path"
    fi
}

PROMPT='%F{8}╭─%f %F{green}%B%n%b%f%F{8}@%f%F{green}%m%f %F{8}in%f %F{cyan}%B$(prompt_path)%b%f $(venv_prompt)${vcs_info_msg_0_}
%F{8}╰─%f%(?.%F{cyan}.%F{red})❯%f '


# ================================================================
# 12. Terminal title
# ================================================================

case "$TERM" in

    xterm*|rxvt*|alacritty*|foot*|konsole*|kitty*|ghostty*)

        zsh_title_precmd() {
            print -Pn "\e]0;%~\a"
        }

        zsh_title_preexec() {
            print -Pn "\e]0;%n@%m: $1\a"
        }

        hook_replace precmd zsh_title_precmd
        hook_replace preexec zsh_title_preexec

        ;;

esac


# ================================================================
# 13. Keyboard
# ================================================================

bindkey -e

# Ctrl + Left
bindkey '^[[1;5D' backward-word

# Ctrl + Right
bindkey '^[[1;5C' forward-word

# Home
bindkey '^[[H' beginning-of-line

# End
bindkey '^[[F' end-of-line

# Delete
bindkey '^[[3~' delete-char

# Ctrl + Backspace
bindkey '^H' backward-kill-word


# ================================================================
# 14. History search
# ================================================================

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search


autoload -Uz history-search-end

zle -N history-search-end

bindkey '^[[1;5A' history-search-end
bindkey '^[[1;5B' history-search-end


# ================================================================
# 15. Edit command line
# ================================================================

autoload -Uz edit-command-line

zle -N edit-command-line

bindkey '^x^e' edit-command-line


# ================================================================
# 16. Double ESC = sudo
# ================================================================

sudo-command-line() {

    [[ -z "$BUFFER" ]] && zle up-history

    if [[ "$BUFFER" == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi

}

zle -N sudo-command-line

bindkey '\e\e' sudo-command-line


# ================================================================
# 17. Autosuggestions
# ================================================================

if [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then

    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

ZSH_AUTOSUGGEST_STRATEGY=(
    history
    completion
)

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=48

bindkey '^\' autosuggest-accept


# ================================================================
# 18. zoxide
# ================================================================

if command -v zoxide >/dev/null 2>&1; then

    eval "$(zoxide init zsh)"

fi


# ================================================================
# 19. fzf
# ================================================================

if [[ -r /usr/share/fzf/shell/completion.zsh ]]; then
    source /usr/share/fzf/shell/completion.zsh
fi

if [[ -r /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
fi

export FZF_DEFAULT_OPTS="
--height 40%
--layout=reverse
--border
"

if command -v fd >/dev/null 2>&1; then

    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

fi

if command -v bat >/dev/null 2>&1; then

    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :300 {}'"

fi

if (( $+commands[fzf] )); then
    bindkey '^R' fzf-history-widget
fi


# ================================================================
# 20. eza
# ================================================================

if command -v eza >/dev/null 2>&1; then

    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lah --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --icons --level=2'

else

    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'

fi


# ================================================================
# 21. zsh-history-substring-search
# ================================================================

if [[ -r "$HOME/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then

    source "$HOME/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down

fi


# ================================================================
# 22. fzf-tab
# ================================================================

if [[ -r "$HOME/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" ]]; then

    source "$HOME/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"

fi


# ================================================================
# 23. forgit
# ================================================================

if [[ -r "$HOME/.config/zsh/plugins/forgit/forgit.plugin.zsh" ]]; then

    source "$HOME/.config/zsh/plugins/forgit/forgit.plugin.zsh"

fi

# ================================================================
# 24. Syntax highlighting
# ================================================================

if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then

    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

fi


# ================================================================
# 25. General aliases
# ================================================================

alias cls='clear'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias -- -='cd -'

alias mkdir='mkdir -pv'

alias grep='grep --color=auto'
alias diff='diff --color=auto'

alias df='df -h'
alias du='du -h'
alias free='free -h'


# ================================================================
# 26. Safety
# ================================================================

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'


# ================================================================
# 27. Fedora
# ================================================================

alias update='sudo dnf upgrade --refresh'
alias install='sudo dnf install'
alias remove='sudo dnf remove'
alias search='dnf search'
alias clean='sudo dnf autoremove && sudo dnf clean all'
alias dnfhistory='dnf history'


# ================================================================
# 28. Python
# ================================================================

alias py='python3'

alias pipi='python -m pip install'
alias pipu='python -m pip install --upgrade'
alias piplist='python -m pip list'
alias pipshow='python -m pip show'

alias venv='python3 -m venv'


# Remove old alias from previous versions.
unalias activate 2>/dev/null

activate() {

    if [[ -f "./.venv/bin/activate" ]]; then

        source "./.venv/bin/activate"

    elif [[ -f "./venv/bin/activate" ]]; then

        source "./venv/bin/activate"

    else

        echo "No .venv or venv found in current directory."
        return 1

    fi

}


mkvenv() {

    local directory="${1:-.venv}"

    if [[ -e "$directory" ]]; then

        echo "Already exists: $directory"
        return 1

    fi

    python3 -m venv "$directory" || return 1

    source "$directory/bin/activate"

    echo "Created and activated: $directory"

}


pyinfo() {

    echo "Python : $(python --version 2>&1)"
    echo "Path   : $(command -v python)"

    if python -m pip --version >/dev/null 2>&1; then
        echo "Pip    : $(python -m pip --version)"
    else
        echo "Pip    : unavailable"
    fi

    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "Venv   : $VIRTUAL_ENV"
    else
        echo "Venv   : none"
    fi

}


pywhere() {

    command -v python
    command -v python3

}


# ================================================================
# 29. Git
# ================================================================

alias gs='git status'
alias gst='git status --short --branch'

alias ga='git add'
alias gaa='git add --all'

alias gc='git commit'
alias gcm='git commit -m'

alias gp='git push'
alias gpl='git pull'

alias gf='git fetch --all --prune'

alias gb='git branch'
alias gba='git branch -a'

alias gsw='git switch'
alias gswc='git switch -c'

alias gco='git checkout'

alias gd='git diff'
alias gdc='git diff --cached'

alias gl='git log --oneline --graph --decorate'
alias glog='git log --oneline --graph --decorate --all'

alias gr='git restore'
alias gru='git restore --staged'


if command -v delta >/dev/null 2>&1; then

    alias gdd='git diff | delta'
    alias gdcached='git diff --cached | delta'

fi


# ================================================================
# 30. Git functions
# ================================================================

groot() {

    git rev-parse --show-toplevel 2>/dev/null

}


croot() {

    local root

    root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        echo "Not inside a Git repository."
        return 1
    }

    cd "$root" || return 1

}


gbranch() {

    git branch --show-current

}


gstat() {

    git status --short --branch

}


gfetch() {

    git fetch --all --prune

}


# ================================================================
# 31. Navigation
# ================================================================

up() {

    local n="${1:-1}"

    if ! [[ "$n" =~ '^[0-9]+$' ]] || (( n < 1 )); then

        echo "usage: up [number]"
        return 1

    fi

    local target="."

    for (( i=0; i<n; i++ )); do
        target+="/.."
    done

    cd "$target" || return 1

}


# ================================================================
# 32. Directories / files
# ================================================================

mkcd() {

    if [[ -z "$1" ]]; then

        echo "usage: mkcd directory"
        return 1

    fi

    mkdir -p -- "$1" && cd -- "$1"

}


backup() {

    if [[ -z "$1" ]]; then

        echo "usage: backup file"
        return 1

    fi

    cp -- "$1" "$1.backup"

}


# ================================================================
# 33. Archives
# ================================================================

extract() {

    if [[ ! -f "$1" ]]; then

        echo "File not found: $1"
        return 1

    fi

    case "$1" in

        *.tar.bz2)
            tar xjf "$1"
            ;;

        *.tar.gz|*.tgz)
            tar xzf "$1"
            ;;

        *.tar.xz)
            tar xJf "$1"
            ;;

        *.tar.zst)
            tar --zstd -xf "$1"
            ;;

        *.tar)
            tar xf "$1"
            ;;

        *.zip)
            unzip "$1"
            ;;

        *.7z)

            if command -v 7z >/dev/null 2>&1; then
                7z x "$1"
            else
                echo "7z is not installed."
                return 1
            fi

            ;;

        *.rar)

            if command -v unrar >/dev/null 2>&1; then
                unrar x "$1"
            else
                echo "unrar is not installed."
                return 1
            fi

            ;;

        *.gz)
            gunzip "$1"
            ;;

        *.bz2)
            bunzip2 "$1"
            ;;

        *.xz)
            unxz "$1"
            ;;

        *.zst)
            unzstd "$1"
            ;;

        *)
            echo "Unsupported archive."
            return 1
            ;;

    esac

}


compress() {

    if (( $# < 2 )); then

        echo "usage: compress archive.tar.gz file1 [file2 ...]"
        return 1

    fi

    local archive="$1"

    shift

    case "$archive" in

        *.tar.gz|*.tgz)
            tar czf "$archive" "$@"
            ;;

        *.tar.bz2)
            tar cjf "$archive" "$@"
            ;;

        *.tar.xz)
            tar cJf "$archive" "$@"
            ;;

        *.tar.zst)
            tar --zstd -cf "$archive" "$@"
            ;;

        *.zip)
            zip -r "$archive" "$@"
            ;;

        *)
            echo "Unsupported archive format."
            return 1
            ;;

    esac

}


# ================================================================
# 34. Processes
# ================================================================

psg() {

    if [[ -z "$1" ]]; then

        echo "usage: psg process"
        return 1

    fi

    ps aux | grep -i -- "$1" | grep -v grep

}


pinfo() {

    if [[ -z "$1" ]]; then

        echo "usage: pinfo process"
        return 1

    fi

    pgrep -af -- "$1"

}


pkillp() {

    if [[ -z "$1" ]]; then

        echo "usage: pkillp process"
        return 1

    fi

    echo "Matching processes:"
    pgrep -af -- "$1"

    if ! pgrep -f -- "$1" >/dev/null 2>&1; then

        echo "No matching process found."
        return 1

    fi

    printf "Kill matching processes? [y/N] "
    read -r answer

    if [[ "$answer" == [yY] ]]; then

        pkill -f -- "$1"

    else

        echo "Cancelled."
        return 1

    fi

}


ports() {

    ss -tulnp

}


# ================================================================
# 35. Clipboard
# ================================================================

copy() {

    if command -v wl-copy >/dev/null 2>&1; then

        wl-copy

    elif command -v xclip >/dev/null 2>&1; then

        xclip -selection clipboard

    elif command -v xsel >/dev/null 2>&1; then

        xsel --clipboard --input

    else

        echo "No clipboard tool found."
        return 1

    fi

}


paste() {

    if command -v wl-paste >/dev/null 2>&1; then

        wl-paste

    elif command -v xclip >/dev/null 2>&1; then

        xclip -selection clipboard -o

    elif command -v xsel >/dev/null 2>&1; then

        xsel --clipboard --output

    else

        echo "No clipboard tool found."
        return 1

    fi

}


# ================================================================
# 36. Weather
# ================================================================

weather() {

    if ! command -v curl >/dev/null 2>&1; then

        echo "curl is not installed."
        return 1

    fi

    curl -s "wttr.in/${1:-}"

}


# ================================================================
# 37. Trash
# ================================================================

if command -v trash-put >/dev/null 2>&1; then

    alias tp='trash-put'
    alias tl='trash-list'
    alias trestore='trash-restore'

fi


# ================================================================
# 38. Global aliases
# ================================================================

alias -g G='| grep'
alias -g L='| less'
alias -g NUL='>/dev/null 2>&1'
alias -g C='| copy'


# ================================================================
# 39. System
# ================================================================

alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'


# ================================================================
# 40. Zsh configuration
# ================================================================

unalias zshconfig 2>/dev/null

zshconfig() {

    "${EDITOR:-vim}" "$HOME/.zshrc"

}


reload() {

    source "$HOME/.zshrc"

}


# ================================================================
# 41. Fedora command-not-found
# ================================================================

if [[ -x /usr/libexec/pk-command-not-found ]]; then

    command_not_found_handler() {
        /usr/libexec/pk-command-not-found "$@"
    }

fi


# ================================================================
# 42. nvm lazy loading
# ================================================================

if [[ -d "$HOME/.nvm" ]]; then

    export NVM_DIR="$HOME/.nvm"

    _nvm_lazy_load() {

        if [[ -s "$NVM_DIR/nvm.sh" ]]; then

            source "$NVM_DIR/nvm.sh"

            if [[ -s "$NVM_DIR/bash_completion" ]]; then
                source "$NVM_DIR/bash_completion"
            fi

            return 0

        fi

        echo "nvm.sh not found."
        return 1

    }


    nvm() {

        _nvm_lazy_load || return
        command nvm "$@"

    }


    node() {

        _nvm_lazy_load || return
        command node "$@"

    }


    npm() {

        _nvm_lazy_load || return
        command npm "$@"

    }


    npx() {

        _nvm_lazy_load || return
        command npx "$@"

    }

fi


# ================================================================
# 43. pyenv
# ================================================================

if [[ -d "$HOME/.pyenv" ]]; then

    export PYENV_ROOT="$HOME/.pyenv"

    [[ -d "$PYENV_ROOT/bin" ]] &&
        export PATH="$PYENV_ROOT/bin:$PATH"

    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init - zsh)"
    fi

fi


# ================================================================
# 44. direnv
# ================================================================

if command -v direnv >/dev/null 2>&1; then

    eval "$(direnv hook zsh)"

fi


# ================================================================
# 45. bat / man
# ================================================================

if command -v bat >/dev/null 2>&1; then

    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"

fi


# ================================================================
# 46. LESS colors
# ================================================================

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'


# ================================================================
# 47. Local configuration
# ================================================================

ZSH_LOCAL_DIR="$XDG_CONFIG_HOME/zsh/conf.d"

if [[ -d "$ZSH_LOCAL_DIR" ]]; then

    for _zsh_local_file in "$ZSH_LOCAL_DIR"/*.zsh(N); do

        source "$_zsh_local_file"

    done

    unset _zsh_local_file

fi

unset ZSH_LOCAL_DIR


# ================================================================
# 48. ZLE
# ================================================================

KEYTIMEOUT=1


# ================================================================
# END
# ================================================================