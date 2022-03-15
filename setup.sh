#!/bin/sh

if ! brew --version > /dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/tim/.profile
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! brew ls --versions asdf > /dev/null; then
	brew install asdf
fi

if ! brew ls --versions fish > /dev/null; then
	brew install fish
fi

if ! brew ls --versions fzf > /dev/null; then
	brew install fzf
fi

if ! brew ls --versions the_silver_searcher > /dev/null; then
  brew install the_silver_searcher
fi

if ! brew ls --versions nvim > /dev/null; then
  brew install nvim
fi

touch $HOME/.config
rm -rf $HOME/.config/fish
ln -s $HOME/dots/fish $HOME/.config/fish

rm -rf $HOME/.vim
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
rm -rf $HOME/.config/nvim
ln -s $HOME/dots/nvim $HOME/.config/nvim
nvim +PluginInstall +qall

rm -rf $HOME/.asdfrc
ln -s $HOME/dots/asdfrc $HOME/.asdfrc

rm -rf $HOME/.gitconfig
ln -s $HOME/dots/gitconfig $HOME/.gitconfig

echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
