#!/bin/sh

say "Setting up this computer"

if ! brew --version > /dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/tim/.profile
	eval "$(/usr/local/bin/brew shellenv)"
fi



say "Setting up asdf"
if ! brew ls --versions asdf > /dev/null; then
	brew install asdf
fi
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
rm -rf $HOME/.asdfrc
ln -s $HOME/dots/asdfrc $HOME/.asdfrc



say "Setting up neovim and searching"
if ! brew ls --versions fzf > /dev/null; then
	brew install fzf
fi

if ! brew ls --versions the_silver_searcher > /dev/null; then
  brew install the_silver_searcher
fi

if ! brew ls --versions nvim > /dev/null; then
  brew install nvim
fi
rm -rf $HOME/.vim
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
rm -rf $HOME/.config/nvim
ln -s $HOME/dots/nvim $HOME/.config/nvim
nvim +PluginInstall +qall

rm -rf $HOME/.gitconfig
ln -s $HOME/dots/gitconfig $HOME/.gitconfig



say "Setting up fish - this requires your password"
if ! brew ls --versions fish > /dev/null; then
	brew install fish
fi
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish
touch $HOME/.config
rm -rf $HOME/.config/fish
ln -s $HOME/dots/fish $HOME/.config/fish



say "Installing some apps"
brew install --cask discord
brew install  --cask google-chrome
brew install --cask iterm2
