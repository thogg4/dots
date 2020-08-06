setopt PROMPT_SUBST

# system
alias m='nvim'
alias be='bundle exec'
alias download='scp -r thogg4@boiled.whatbox.ca:~/files/download/ .'
alias what='ssh thogg4@boiled.whatbox.ca'
alias audio="sudo kill -9 `ps ax|grep 'coreaudio[a-z]' | awk '{print $1}'`"
alias dm='docker-machine'
alias dc='docker-compose'
alias dmenv='eval "$(docker-machine env $1)"'
alias fs='foreman start'
alias agr='ag --ruby'

export CHARGIFY_NOTIFY_FRESH=1

# rails
alias rr='rake routes'

# git
alias gs='git status'
alias ga='git add -A'
alias gc='git commit'
alias gp='git pull'

# get away from apple ctags
alias ctags="`brew --prefix`/bin/ctags"


git_info ()
{
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    return 0
  fi

  git_branch=$(git branch 2>/dev/null | sed -n '/^\*/s/^\* //p')
  if git diff --quiet 2>/dev/null >&2; then
    git_color="%F{green}"
  else
    git_color="%F{red}"
  fi
  echo "$git_color|$git_branch| "
}

# prompt
PROMPT='%F{white}%1~ $(git_info)%F{white}> '

export PATH=$HOME/bin:./vendor/bundle/bin:$HOME/.rbenv/shims:$PATH

# Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# For Postgres
export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin:$PATH"

# nodeJS
export PATH="/usr/local/share/npm/bin:$PATH"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Change colors for ssh
function tabc() {
  NAME=$1; if [ -z "$NAME" ]; then NAME="Default"; fi
  echo -e "\033]50;SetProfile=$NAME\a"
}

function colorssh() {
  tabc SSH
  ssh $*
  tabc
}

alias ssh="colorssh"
export PATH="/usr/local/opt/node@6/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export ERL_AFLAGS="-kernel shell_history enabled"

export GOPATH=$HOME/go
export PATH="/usr/local/opt/node@10/bin:$PATH"
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

