#!/bin/sh

if ! brew --version > /dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! brew ls --versions rbenv > /dev/null; then
	brew install rbenv
fi

if ! brew ls --versions ruby-build > /dev/null; then
	brew install ruby-build
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

touch $HOME/.config
rm -rf $HOME/.config/fish
ln -s $HOME/dots/fish $HOME/.config/fish

rm -rf $HOME/.vim
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
rm -rf $HOME/.config/nvim
ln -s $HOME/dots/nvim $HOME/.config/nvim
nvim +PluginInstall +qall
