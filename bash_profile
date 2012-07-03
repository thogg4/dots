alias m='vi'
alias cell='cd ~/Dropbox/rails/cellar/'
alias goo='cd ~/Google\ Drive/'


# aliases for git
alias gs='git status -s'
alias gp='git pull'



# Setup some colors to use later in interactive shell or scripts
export COLOR_NC='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[1;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'

alias colorslist="set | egrep 'COLOR_\w*'" # Lists all the colors, uses vars in .bashrc_non-interactive


# Prompts ----------------------------------------------------------

# old, big prompt
# export PS1="\[${COLOR_RED}\]\u@\h \[${COLOR_WHITE}\]\w \[${COLOR_NC}\] \n> "

# jekyll
export PS1="\n\[${COLOR_RED}\]\W\[${COLOR_NC}\] > "

# bindle
# export PS1="\[${COLOR_GREEN}\]\W\[${COLOR_NC}\] > "






[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
