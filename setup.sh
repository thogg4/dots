#!/bin/sh
# =============================================================================
# setup.sh — Full machine bootstrap for a fresh macOS install.
# Run once after cloning this repo. Safe to re-run (most steps are idempotent).
# =============================================================================

# -----------------------------------------------------------------------------
# Homebrew
# Install if missing, then upgrade everything that's already installed.
# The arm64 prefix is /opt/homebrew; shellenv wires up PATH/MANPATH/etc.
# -----------------------------------------------------------------------------
if ! brew --version > /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew upgrade

# -----------------------------------------------------------------------------
# rbenv — Ruby version manager
# ruby-build is the plugin that lets rbenv install specific Ruby versions.
# We upgrade ruby-build separately so new Ruby versions stay available.
# -----------------------------------------------------------------------------
if ! brew ls --versions rbenv > /dev/null; then
    brew install rbenv
    brew upgrade ruby-build
    echo 'eval "$(rbenv init -)"' >> $HOME/.zprofile
    eval "$(rbenv init -)"
fi

# -----------------------------------------------------------------------------
# Config directory and Claude directory
# mkdir is intentionally without -p so it fails loudly if something unexpected
# is already at that path (e.g. a file instead of a directory).
# -----------------------------------------------------------------------------
mkdir $HOME/.config
mkdir $HOME/.claude

# -----------------------------------------------------------------------------
# Neovim config — symlink the whole nvim/ directory
# Wipe any existing config first so the symlink is clean on re-runs.
# lazy.nvim bootstraps itself on first launch; no separate install needed.
# -----------------------------------------------------------------------------
rm -rf $HOME/.config/nvim
ln -s $HOME/dots/nvim $HOME/.config/nvim

# -----------------------------------------------------------------------------
# Git config
# .gitconfig holds user identity, push/pull defaults, and the commit template.
# .gitmessage is the commit template referenced by gitconfig.
# The `git config` call writes the absolute path into .gitconfig so it works
# even before the symlink is in place on a fresh clone.
# -----------------------------------------------------------------------------
rm -rf $HOME/.gitconfig
ln -s $HOME/dots/gitconfig $HOME/.gitconfig

rm -rf $HOME/.gitmessage
ln -s $HOME/dots/gitmessage $HOME/.gitmessage
git config --global commit.template $HOME/.gitmessage

# Claude Code settings (slash commands, hooks, MCP config, etc.)
ln -s $HOME/dots/claude $HOME/.claude

# -----------------------------------------------------------------------------
# Package installs
# CLI tools first, then GUI apps via --cask.
# fzf        — fuzzy finder (used standalone and by some nvim plugins)
# ag         — silver searcher, fast code search
# ripgrep    — used by Telescope live_grep inside neovim
# wallpaper  — CLI to set the desktop wallpaper (used later in this script)
# defaultbrowser — CLI to set the default browser without a UI prompt
# aerospace  — tiling window manager (tap required, not in core Homebrew)
# jordanbaird-ice — menu bar management
# orbstack   — lightweight Docker/Linux VM alternative to Docker Desktop
# -----------------------------------------------------------------------------
brew install fish
brew install fzf
brew install the_silver_searcher
brew install ripgrep
brew install nvim
brew install --cask discord
brew install --cask firefox
brew install --cask google-chrome
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
brew install --cask ghostty
brew install wallpaper
brew install defaultbrowser

# -----------------------------------------------------------------------------
# Fish shell
# Add fish to /etc/shells so chsh accepts it, then make it the login shell.
# Symlink the whole fish/ directory (config.fish, functions/, conf.d/).
# -----------------------------------------------------------------------------
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
rm -rf $HOME/.config/fish
ln -s $HOME/dots/fish $HOME/.config/fish

# -----------------------------------------------------------------------------
# macOS System Preferences — close the GUI so defaults writes take effect
# cleanly without the app overwriting them on quit.
# -----------------------------------------------------------------------------
osascript -e 'tell application "System Preferences" to quit'

# — Security ——————————————————————————————————————————————————————————————————
# Suppress the "Are you sure you want to open this application?" Gatekeeper
# dialog for apps downloaded from the internet.
defaults write com.apple.LaunchServices LSQuarantine -bool false

# — Trackpad ——————————————————————————————————————————————————————————————————
# Tap to click (applies to both the current user and the login screen).
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Use "natural" scroll direction: false = old-school (scroll up = content moves up).
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# — Audio —————————————————————————————————————————————————————————————————————
# Raise the Bluetooth audio codec bitpool floor so headphones use a higher
# quality codec instead of dropping to the lowest common denominator.
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# — Keyboard ——————————————————————————————————————————————————————————————————
# KeyRepeat: delay between repeated keys when held (lower = faster).
# InitialKeyRepeat: pause before repetition starts.
# These values are lower than the UI allows.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 13

# Disable Spotlight's Cmd-Space and Cmd-Shift-Space shortcuts (keys 64/65)
# so Raycast can own that hotkey without conflict.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '<dict><key>enabled</key><false/></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 '<dict><key>enabled</key><false/></dict>'

# — Screenshots ———————————————————————————————————————————————————————————————
defaults write com.apple.screencapture location -string "${HOME}/Downloads"
defaults write com.apple.screencapture type -string "png"

# — Finder ————————————————————————————————————————————————————————————————————
# Open new windows to Downloads instead of the default "Recents" view.
# PfLo = "Path from Location" (a custom folder), as opposed to PfHm (home).
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"

# false = hide extensions (only show them on hover). Set true to always show.
defaults write NSGlobalDomain AppleShowAllExtensions -bool false

# Default view: icon (icnv). Others: list (Nlsv), column (clmv), gallery (glyv).
defaults write com.apple.finder FXPreferredViewStyle -string "icnv"

# Skip the "Are you sure?" prompt when emptying Trash.
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# — Dock ——————————————————————————————————————————————————————————————————————
# "scale" shrinks the window into the app icon rather than doing a genie effect.
defaults write com.apple.dock mineffect -string "scale"

# Minimise into the app's icon instead of a separate Dock tile.
defaults write com.apple.dock minimize-to-application -bool true

# Auto-hide the Dock; it slides in on hover.
defaults write com.apple.dock autohide -bool true

# Don't show the "Recent Applications" section at the right end of the Dock.
defaults write com.apple.dock show-recents -bool false

# Disable the pinch-to-Launchpad trackpad gesture.
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Reset the persistent-apps list completely, then rebuild it in order.
# persistent-apps = pinned app icons; persistent-others = folder/stack tiles.
defaults write com.apple.dock persistent-apps -array
defaults delete com.apple.dock persistent-others

defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Firefox.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Ghostty.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Microsoft Outlook.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Microsoft Teams.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///System/Applications/Messages.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Slack.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"

# Dock stacks: Downloads folder and /Applications as right-side tiles.
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-type</key><string>directory-tile</string><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://${HOME}/Downloads/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-type</key><string>directory-tile</string><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"

# Apply all Dock changes.
killall Dock

# — Login items ———————————————————————————————————————————————————————————————
# Clear existing login items, then add the ones we want.
# hidden:false = the app window is visible at login (not launched in background).
osascript -e 'tell application "System Events" to delete every login item'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Firefox.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/System/Applications/Messages.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Ghostty.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Slack.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Microsoft Teams.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Microsoft Outlook.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Raycast.app", hidden:false}'

# — App Store —————————————————————————————————————————————————————————————————
defaults write com.apple.appstore WebKitDeveloperExtras -bool true  # WebKit devtools in App Store
defaults write com.apple.appstore ShowDebugMenu -bool true           # Debug menu in App Store

# — Software Update ———————————————————————————————————————————————————————————
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true  # Check daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1          # 1 = daily (default is weekly)
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1           # Download in background
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1       # Auto-install security patches
defaults write com.apple.commerce AutoUpdate -bool true                    # Auto-update App Store apps
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true     # Allow reboot for OS updates

# — Trackpad gestures —————————————————————————————————————————————————————————
# Drag with lock: lets you drag windows by tapping twice and locking the drag.
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool true

# Trackpad speed (0–3 range; 2.5 is faster than the UI maximum of ~2).
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5

# Disable notification centre swipe (2-finger from right edge).
# 0 = disabled, 1 = swipe with 2 fingers, 2 = swipe with 3 fingers.
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0

# 4-finger vertical: Mission Control (2) / Exposé.
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
# 4-finger horizontal: switch between full-screen apps.
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
# 3-finger horizontal: swipe between pages / back-forward in apps.
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1

# Same settings mirrored for Bluetooth trackpad (separate pref domain).
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1

# Set Firefox as the default browser (requires `brew install defaultbrowser`).
defaultbrowser firefox

# — Raycast ———————————————————————————————————————————————————————————————————
# Apply preferences that aren't stored in the raycast.json export.
# set_plist tries Add first (for a fresh plist) then falls back to Set.
RAYCAST_PLIST="$HOME/Library/Preferences/com.raycast.macos.plist"
set_plist() {
    /usr/libexec/PlistBuddy -c "Add :$1 $2 $3" "$RAYCAST_PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :$1 $3" "$RAYCAST_PLIST"
}
# Command-49 = Cmd+Space (key code 49 is spacebar).
set_plist "raycastGlobalHotkey"                 string  "Command-49"
set_plist "raycastPreferredWindowMode"          string  "default"
set_plist "raycastShouldFollowSystemAppearance" integer 1
set_plist "useHyperKeyIcon"                     integer 0

# Kill Raycast so it picks up the new plist values on next launch.
killall Raycast 2>/dev/null || true

# Import extensions, quicklinks, snippets, and remaining preferences from the
# tracked raycast.json. The import format is gzipped JSON with a .rayconfig
# extension. We generate it on the fly so only the canonical .json is committed.
gzip --keep --suffix .rayconfig "$HOME/dots/raycast.json"
open -a Raycast --args import "$HOME/dots/raycast.json.rayconfig"

# — Menu bar clock ————————————————————————————————————————————————————————————
# Show day, date, time with seconds in the menu bar clock.
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm:ss a"
defaults write com.apple.menuextra.clock ShowSeconds -bool true

# Set desktop wallpaper (requires `brew install wallpaper`).
wallpaper set wallpaper.jpg

# Let the wallpaper get set
sleep 5

# — Ghostty terminal ——————————————————————————————————————————————————————————
# Symlink the whole ghostty/ directory so all config is tracked here.
rm -rf $HOME/.config/ghostty
ln -s $HOME/dots/ghostty $HOME/.config/ghostty

sudo reboot
