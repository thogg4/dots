# fish
set fish_greeting

# system
alias m='nvim'
alias be='bundle exec'
alias fs='foreman start'
alias os='overmind start'
alias agr='ag --ruby'
alias c='claude'

# rails
alias rr='rake routes'


# git
alias gs='git status'
alias ga='git add -A'
alias gc='git commit'
alias gp='git pull'

# ruby
#set RUBYOPT -rbumbler/go

# get away from apple ctags
alias ctags="`brew --prefix`/bin/ctags"

# Heroku Toolbelt
#
#export PATH="/opt/homebrew/heroku/bin:$PATH"
#export PATH="/opt/homebrew/bin:$PATH"

# Change colors for ssh
#function tabc() {
  #NAME=$1; if [ -z "$NAME" ]; then NAME="Default"; fi
  #echo -e "\033]50;SetProfile=$NAME\a"
#}

#function colorssh() {
  #tabc SSH
  #ssh $*
  #tabc
#}

#alias ssh="colorssh"

function ctags
  set -l pref (brew --prefix)
  $pref/bin/ctags
end

if status --is-interactive
  eval (/opt/homebrew/bin/brew shellenv)
end

status --is-interactive; and rbenv init - --no-rehash fish | source
