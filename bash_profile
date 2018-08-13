alias m='vi'
alias goo='cd ~/Google\ Drive/'
alias be='bundle exec'
alias download='scp -r thogg4@boiled.whatbox.ca:~/files/download/ .'
alias what='ssh thogg4@boiled.whatbox.ca'
alias audio="sudo kill -9 `ps ax|grep 'coreaudio[a-z]' | awk '{print $1}'`"
alias dm='docker-machine'
alias dc='docker-compose'
alias dmenv='eval "$(docker-machine env $1)"'
alias fs='foreman start'

export CHARGIFY_NOTIFY_FRESH=1

#cd() {
#  builtin cd $*
#  if test -f "${PWD}/docker-machine.sh"; then source docker-machine.sh; fi
#}
#eval "$(docker-machine env machine)"
export POSTGRES_HOST='machine'

# for rails
alias rr='rake routes'


# for git
alias gs='git status'
alias ga='git add -A'
alias gc='git commit'
alias gp='git pull'

# Setup some colors to use later in interactive shell or scripts
export COLOR_NC='\[\e[0m\]' # No Color
export COLOR_WHITE='\[\e[1;37m\]'
export COLOR_BLACK='\[\e[0;30m\]'
export COLOR_BLUE='\[\e[0;34m\]'
export COLOR_LIGHT_BLUE='\[\e[1;34m\]'
export COLOR_GREEN='\[\e[0;32m\]'
export COLOR_LIGHT_GREEN='\[\e[1;32m\]'
export COLOR_CYAN='\[\e[0;36m\]'
export COLOR_LIGHT_CYAN='\[\e[1;36m\]'
export COLOR_RED='\[\e[0;31m\]'
export COLOR_LIGHT_RED='\[\e[1;31m\]'
export COLOR_PURPLE='\[\e[0;35m\]'
export COLOR_LIGHT_PURPLE='\[\e[1;35m\]'
export COLOR_BROWN='\[\e[0;33m\]'
export COLOR_YELLOW='\[\e[1;33m\]'
export COLOR_GRAY='\[\e[1;30m\]'
export COLOR_LIGHT_GRAY='\[\e[0;37m\]'

alias colorslist="set | egrep 'COLOR_\w*'" # Lists all the colors, uses vars in .bashrc_non-interactive

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  c_git_clean='\[\e[0;32m\]'
  c_git_dirty='\[\e[0;31m\]'
else
  c_git_clean=
  c_git_dirty=
fi
# Function to assemble the Git parsingart of our prompt.

git_prompt ()
{
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    return 0
  fi
  git_branch=$(git branch 2>/dev/null | sed -n '/^\*/s/^\* //p')
  if git diff --quiet 2>/dev/null >&2; then
    git_color="$c_git_clean"
  else
    git_color="$c_git_dirty"
  fi
  echo " $git_color+$git_branch+"
}

# Prompts ----------------------------------------------------------
PROMPT_COMMAND='PS1="\n${COLOR_WHITE}\W${COLOR_NC}$(git_prompt) ${COLOR_WHITE}> "'


export PATH=$HOME/bin:./vendor/bundle/bin:$HOME/.rbenv/shims:$PATH

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export PATH="/usr/local/bin:$PATH"

### For Postgres
export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin:$PATH"

### For NodeJs
export PATH="/usr/local/share/npm/bin:$PATH"

### For rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
