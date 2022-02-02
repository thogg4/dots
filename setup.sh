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

touch $HOME/.config
rm -rf $HOME/.config/fish
ln -s $HOME/dots/fish $HOME/.config/fish
source $HOME/.config/fish/config.fish
