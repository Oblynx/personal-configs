# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias 'l=ls'
alias 'll=ls -al'

export VISUAL=vim
export EDITOR=vim

color_prompt=yes
PROMPT_DIRTRIM='2'
PS1='[\[\033[01;35m\]\u@\h\[\033[00m\]: \[\033[01;34m\]\w\[\033[00m\]]\$'

export PATH=$PATH:~/.local/bin

