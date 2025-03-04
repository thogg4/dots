#!/bin/sh

say "Setting up this computer"

if ! brew --version > /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/tim/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew upgrade

say "Setting up rbenv"
if ! brew ls --versions rbenv > /dev/null; then
    brew install rbenv
    brew upgrade ruby-build
fi

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

mkdir $HOME/.config

rm -rf $HOME/.vim
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
rm -rf $HOME/.config/nvim
ln -s $HOME/dots/nvim $HOME/.config/nvim
nvim +PluginInstall +qall

rm -rf $HOME/.gitconfig
ln -s $HOME/dots/gitconfig $HOME/.gitconfig

rm -rf $HOME/.gitmessage
ln -s $HOME/dots/gitmessage $HOME/.gitmessage
git config --global commit.template $HOME/.gitmessage


say "Setting up fish - this requires your password"
if ! brew ls --versions fish > /dev/null; then
    brew install fish
fi
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
rm -rf $HOME/.config/fish
ln -s $HOME/dots/fish $HOME/.config/fish

say "Installing some apps. This might require a password"
brew install --cask discord
brew install --cask google-chrome
brew install --cask iterm2
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask alfred
brew install --cask microsoft-teams
brew install --cask slack

say "Setting system preferences"
osascript -e 'tell application "System Preferences" to quit'

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 13

# Save screenshots to downloads
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Set Downloads as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool false

# Use icon view in all Finder windows by default
# Four-letter codes for all view modes: `Nlsv`, `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "icnv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Autohide dock
defaults write com.apple.dock autohide -bool true

# Don't show recent applications
defaults write com.apple.dock show-recents -bool false

# Disable the Launchpad gesture (pinch with thumb and three fingers)
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# Enable Debug Menu in the Mac App Store
defaults write com.apple.appstore ShowDebugMenu -bool true

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

# Allow the App Store to reboot machine on macOS updates
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

# Enable trackpad draglock
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool true

# Speed up trackpad
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5

# Don't show notification center when swiping right with 2 fingers
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0

defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2

defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1

# Bluetooth trackpad
# Don't show notification center when swiping right with 2 fingers
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1

# Show seconds in menubar
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm:ss a"
defaults write com.apple.menuextra.clock ShowSeconds -bool true

# Set custom key mappings in iTerm2
defaults write com.googlecode.iterm2 GlobalKeyMap '<dict>
    <key>0x19-0x60000</key>
    <dict>
        <key>Action</key>
        <integer>39</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0x9-0x40000</key>
    <dict>
        <key>Action</key>
        <integer>32</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0xf700-0x300000</key>
    <dict>
        <key>Action</key>
        <integer>7</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0xf701-0x300000</key>
    <dict>
        <key>Action</key>
        <integer>6</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0xf702-0x320000-0x7b</key>
    <dict>
        <key>Action</key>
        <integer>2</integer>
        <key>Label</key>
        <string></string>
        <key>Text</key>
        <string></string>
        <key>Version</key>
        <integer>0</integer>
    </dict>
    <key>0xf703-0x320000-0x7c</key>
    <dict>
        <key>Action</key>
        <integer>0</integer>
        <key>Label</key>
        <string></string>
        <key>Text</key>
        <string></string>
        <key>Version</key>
        <integer>0</integer>
    </dict>
    <key>0xf729-0x100000</key>
    <dict>
        <key>Action</key>
        <integer>5</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0xf72b-0x100000</key>
    <dict>
        <key>Action</key>
        <integer>4</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0xf72c-0x100000</key>
    <dict>
        <key>Action</key>
        <integer>9</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0xf72c-0x20000</key>
    <dict>
        <key>Action</key>
        <integer>9</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0xf72d-0x100000</key>
    <dict>
        <key>Action</key>
        <integer>8</integer>
        <key>Text</key>
        <string></string>
    </dict>
    <key>0xf72d-0x20000</key>
    <dict>
        <key>Action</key>
        <integer>8</integer>
        <key>Text</key>
        <string></string>
    </dict>
  </dict>'
