# ~/.bashrc: executed by bash(1) for non-lgin shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  case "$TERM" in
  xterm* | rxvt*)
    export PS1="\[\e[1;32m\]\${VIRTUAL_ENV:+(\${VIRTUAL_ENV##*/}) }\[\e[1;33m\]\w\[\e[0m\]\n\[\e[1;36m\]❯\[\e[0m\] "
    ;;
  *)
    export PS1="\[\e[1;32m\]\${VIRTUAL_ENV:+(\${VIRTUAL_ENV##*/}) }\[\e[1;33m\]\w\[\e[0m\]\n\[\e[1;36m\]❯\[\e[0m\] "
    ;;
  esac
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  #alias fgrep='fgrep --color=auto'
  #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
export EZA_COLORS="da=38;5;244"
alias l='eza -l --icons=always --color=always --git'
alias la='ls -A'
alias ll='ls -l'
alias lc='ls -CF'
alias lt='tree -L 2'

alias zed='flatpak run dev.zed.Zed'
alias gst='git status'
alias ece='ssh kthaku02@ssh-ubuntu.ece.ubc.ca'

alias vim='nvim'
alias fetch='fetch --shading-mode sextants'

export PATH="/home/krish/altera_lite/25.1std/quartus/bin:$PATH"
export PATH="/home/krish/altera_lite/25.1std/questa_fse/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
PATH=$HOME/tools/sys161/bin:$HOME/tools/os161/bin:$PATH
PATH=$HOME/tools/sys161/bin:$HOME/tools/os161/bin:$PATH
PATH=$HOME/tools/sys161/bin:$HOME/tools/os161/bin:$PATH

export QSYS_ROOTDIR="/home/krish/altera_lite/25.1std/quartus/sopc_builder/bin"

# Added by Quartus Prime software
export SALT_LICENSE_SERVER="$SALT_LICENSE_SERVER;/home/krish/.altera.quartus/questa_lic.dat"

eval "$(direnv hook bash)"

export PATH="/home/krish/.local/bin:$PATH"
