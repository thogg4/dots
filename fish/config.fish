# fish
set fish_greeting

# system
alias m='nvim'
alias be='bundle exec'
alias what='ssh thogg4@boiled.whatbox.ca'
alias fs='foreman start'
alias os='overmind start'
alias agr='ag --ruby'

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
#export PATH="/usr/local/heroku/bin:$PATH"
#export PATH="/usr/local/bin:$PATH"

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

source /usr/local/opt/asdf/libexec/asdf.fish

if status --is-interactive
  eval (/usr/local/bin/brew shellenv)
end
