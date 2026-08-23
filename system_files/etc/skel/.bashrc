# Mevya Bash configuration.
# Keep the system defaults first, then apply the interactive shell setup.

case $- in
    *i*) ;;
    *) return ;;
esac

if [[ -r /etc/bashrc ]]; then
    . /etc/bashrc
fi

shopt -s histappend cmdhist lithist checkwinsize

HISTCONTROL=ignoreboth
HISTSIZE=20000
HISTFILESIZE=40000
HISTTIMEFORMAT='%F %T  '

export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--RFX}"

alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias cls='clear'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status --short --branch'
alias gl='git log --oneline --decorate --graph -15'

__mevya_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return 0
    printf '  git:%s' "$branch"
}

# Keep the prompt independent of the terminal emulator; the branch segment is
# evaluated when Bash expands PS1 instead of replacing PROMPT_COMMAND.
PS1='\[\e[38;5;146m\]\u\[\e[38;5;103m\]@\[\e[38;5;110m\]\h \[\e[38;5;103m\]\w$(__mevya_git_branch)\[\e[0m\]\n\[\e[38;5;146m\]❯\[\e[0m\] '
