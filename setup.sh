#!/bin/sh

if ! brew --version > /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew upgrade

if ! brew ls --versions rbenv > /dev/null; then
    brew install rbenv
    brew upgrade ruby-build
    echo 'eval "$(rbenv init -)"' >> $HOME/.zprofile
    eval "$(rbenv init -)"
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

mkdir $HOME/.config
mkdir $HOME/.claude

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

ln -s $HOME/dots/claude $HOME/.claude

if ! brew ls --versions fish > /dev/null; then
    brew install fish
fi
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
rm -rf $HOME/.config/fish
ln -s $HOME/dots/fish $HOME/.config/fish

brew install --cask discord
brew install --cask firefox
brew install --cask google-chrome
brew install --cask iterm2
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask raycast
brew install --cask microsoft-teams
brew install --cask microsoft-outlook
brew install --cask slack
brew install --cask orbstack
brew install --cask nikitabobko/tap/aerospace
brew install --cask jordanbaird-ice
brew install --cask claude-code
brew install wallpaper

osascript -e 'tell application "System Preferences" to quit'

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable “natural” scroll
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
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"

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

# Clean up dock apps
defaults write com.apple.dock persistent-apps -array
defaults delete com.apple.dock persistent-others

# Then set them up
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Firefox.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/iTerm.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Microsoft Outlook.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Microsoft Teams.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///System/Applications/Messages.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Slack.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"

defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-type</key><string>directory-tile</string><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://${HOME}/Downloads/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-type</key><string>directory-tile</string><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"

# Restart the Dock
killall Dock

# Setup login items
osascript -e 'tell application "System Events" to delete every login item'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Firefox.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/System/Applications/Messages.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/iTerm.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Slack.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Microsoft Teams.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Microsoft Outlook.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Raycast.app", hidden:false}'

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

wallpaper set wallpaper.jpg

# Configure iTerm2
/usr/libexec/PlistBuddy -c 'Set :"New Bookmarks":0:"Transparency" 0.15' ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c 'Set :"New Bookmarks":0:"Show Mark Indicators" 0' ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c 'Set :"New Bookmarks":0:"Use Separate Colors for Light and Dark Mode" 0' ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c 'Set :"New Bookmarks":0:"Unlimited Scrollback" 1' ~/Library/Preferences/com.googlecode.iterm2.plist

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

sudo reboot
