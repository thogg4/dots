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

## For Postgres
#export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin:$PATH"

## nodeJS
#export PATH="/usr/local/share/npm/bin:$PATH"

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
#export PATH="/usr/local/opt/node@6/bin:$PATH"

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#export ERL_AFLAGS="-kernel shell_history enabled"

#export GOPATH=$HOME/go
#export PATH="/usr/local/opt/node@10/bin:$PATH"
#export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

function ctags
  set -l pref (brew --prefix)
  $pref/bin/ctags
end

source /opt/homebrew/opt/asdf/libexec/asdf.fish

if status --is-interactive
  eval (/opt/homebrew/bin/brew shellenv)
end
