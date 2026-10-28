#!/bin/sh
# =============================================================================
# setup.sh — Full machine bootstrap for a fresh macOS install.
# Run once after cloning this repo. Safe to re-run (most steps are idempotent).
# =============================================================================

# Runs without sudo. Steps that would need it print a "[skip] … needs sudo"
# line instead, and Homebrew refuses anything that would prompt for it. The one
# password prompt is Homebrew's own installer, if you put it in /opt/homebrew.
export HOMEBREW_NO_SUDO=1

# -----------------------------------------------------------------------------
# Approvals
# Each section below asks before it runs, the first time only. Answers are
# saved as key=yes/no lines in .setup-approvals (gitignored, per machine), so
# later runs don't ask again. Delete a line (or the file) to be asked again.
# -----------------------------------------------------------------------------
APPROVALS="$HOME/dots/.setup-approvals"
saved_answer() {
    grep "^$1=" "$APPROVALS" 2>/dev/null | cut -d= -f2
}
approved() {
    _answer="$(saved_answer "$1")"
    if [ -z "$_answer" ]; then
        printf "%s [y/N] " "$2"
        if ! read _reply < /dev/tty; then
            echo "Couldn't read an answer, stopping." >&2
            exit 1
        fi
        case "$_reply" in
            [yY]*) _answer=yes ;;
            *) _answer=no ;;
        esac
        echo "$1=$_answer" >> "$APPROVALS"
    fi
    [ "$_answer" = yes ] && return
    echo "Skipping $1."
    return 1
}

# -----------------------------------------------------------------------------
# App location
# Where Homebrew casks and Run.app go (also written to brew.env for casks);
# the apps and macos sections use $APPDIR.
# app_path finds an app there, falling back to /Applications for .pkg and App
# Store apps, and for casks installed before ~/Applications was chosen.
# -----------------------------------------------------------------------------
if approved home_applications "Install apps into ~/Applications instead of /Applications?"; then
    APPDIR="$HOME/Applications"
else
    APPDIR=/Applications
fi
echo "Apps go in $APPDIR."
app_path() {
    if [ -d "$APPDIR/$1.app" ]; then
        echo "$APPDIR/$1.app"
    else
        echo "/Applications/$1.app"
    fi
}

# brew.env makes every cask install use $APPDIR, including ones run by hand
# later. It can't expand variables, so the path is written out. Only that
# line is replaced, keeping any other settings. Casks installed before this
# keep their old location.
echo "Pointing Homebrew casks at $APPDIR..."
BREW_ENV="$HOME/.homebrew/brew.env"
mkdir -p "$HOME/.homebrew"
{ grep -v '^HOMEBREW_CASK_OPTS=' "$BREW_ENV" 2>/dev/null; echo "HOMEBREW_CASK_OPTS=--appdir=$APPDIR"; } > "$BREW_ENV.tmp"
mv "$BREW_ENV.tmp" "$BREW_ENV"

# -----------------------------------------------------------------------------
# Homebrew
# Goes in /opt/homebrew or ~/hb, asked once at install. ~/hb is a git clone,
# since the installer caps the prefix at /opt/homebrew's 13 bytes. Past that
# length bottles built for /opt/homebrew compile from source and brew doctor
# calls the setup unsupported (Tier 3). Put whichever exists on PATH first;
# shellenv wires up PATH/MANPATH/HOMEBREW_PREFIX.
# -----------------------------------------------------------------------------
for _prefix in /opt/homebrew "$HOME/hb"; do
    if [ -x "$_prefix/bin/brew" ]; then
        eval "$("$_prefix/bin/brew" shellenv)"
        break
    fi
done

if approved homebrew "Install Homebrew and upgrade installed packages?"; then
    if brew --version > /dev/null 2>&1; then
        echo "Homebrew already installed, upgrading packages..."
        brew upgrade
    elif ! xcode-select -p > /dev/null 2>&1; then
        # Both installs need git from the Command Line Tools, and the installer
        # only installs them itself with sudo. This opens Apple's dialog instead.
        xcode-select --install
        echo "  [skip] Homebrew — install the Command Line Tools in the dialog, then rerun setup.sh"
    else
        if approved home_homebrew "Install Homebrew into ~/hb instead of /opt/homebrew?"; then
            _prefix="$HOME/hb"
            echo "Cloning Homebrew into $_prefix..."
            git clone https://github.com/Homebrew/brew "$_prefix" &&
                "$_prefix/bin/brew" update --force --quiet
        else
            _prefix=/opt/homebrew
            echo "Installing Homebrew into $_prefix (the installer asks for your password)..."
            # The installer only asks for the password with HOMEBREW_NO_SUDO
            # unset and a TTY on stdin.
            env -u HOMEBREW_NO_SUDO /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/tty
        fi
        # Checked by result, since a failed download still exits 0 (bash -c "").
        if [ -x "$_prefix/bin/brew" ]; then
            echo "eval \"\$($_prefix/bin/brew shellenv)\"" >> "$HOME/.zprofile"
            eval "$("$_prefix/bin/brew" shellenv)"
        else
            echo "Homebrew install into $_prefix failed; later sections that need it will fail too." >&2
            echo "Rerun to try again, or delete the home_homebrew line from $APPROVALS to pick the other location (/opt/homebrew needs an admin account)." >&2
        fi
    fi
fi

# -----------------------------------------------------------------------------
# rbenv — Ruby version manager
# ruby-build is the plugin that lets rbenv install specific Ruby versions.
# We upgrade ruby-build separately so new Ruby versions stay available.
# -----------------------------------------------------------------------------
if approved ruby "Install rbenv, the latest Ruby, and the kamal gem?"; then
    if ! brew ls --versions rbenv > /dev/null; then
        echo "Installing rbenv..."
        brew install rbenv
        echo 'eval "$(rbenv init -)"' >> $HOME/.zprofile
        eval "$(rbenv init -)"
    else
        echo "rbenv already installed, upgrading..."
        brew upgrade rbenv ruby-build 2>/dev/null || true
    fi

    RUBY_VERSION="$(rbenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')"
    if ! rbenv versions --bare | grep -qx "$RUBY_VERSION"; then
        echo "Installing Ruby $RUBY_VERSION..."
        rbenv install "$RUBY_VERSION"
    else
        echo "Ruby $RUBY_VERSION already installed, skipping."
    fi
    echo "Setting Ruby $RUBY_VERSION as global..."
    rbenv global "$RUBY_VERSION"

    if gem list kamal -i > /dev/null 2>&1 && gem outdated | grep -q "^kamal "; then
        echo "Updating kamal gem..."
        gem update kamal
    elif gem list kamal -i > /dev/null 2>&1; then
        echo "kamal gem already up to date, skipping."
    else
        echo "Installing kamal gem..."
        gem install kamal
    fi
fi

# -----------------------------------------------------------------------------
# Base directories (config, Claude, SSH, work, and the apps folder)
# mkdir is intentionally without -p so it fails loudly if something unexpected
# is already at that path (e.g. a file instead of a directory).
# -----------------------------------------------------------------------------
for dir in "$HOME/.config" "$HOME/.claude" "$HOME/.ssh" "$HOME/work" "$APPDIR"; do
    if [ -d "$dir" ]; then
        echo "$dir already exists, skipping."
    else
        echo "Creating $dir..."
        mkdir "$dir"
    fi
done

# -----------------------------------------------------------------------------
# SSH key
# Generate a new ed25519 key if one doesn't already exist. ssh-keygen prompts
# for a passphrase interactively. The key is then added to the agent and to
# macOS Keychain (via ~/.ssh/config) so it's unlocked automatically on login.
# -----------------------------------------------------------------------------
if approved ssh "Generate an SSH key and add it to the macOS Keychain?"; then
    SSH_KEY="$HOME/.ssh/id_ed25519"
    if [ -f "$SSH_KEY" ]; then
        echo "SSH key already exists at $SSH_KEY, skipping."
    else
        echo "Generating SSH key..."
        ssh-keygen -t ed25519 -C "thogg4@gmail.com" -f "$SSH_KEY"

        if [ ! -f "$HOME/.ssh/config" ] || ! grep -q "UseKeychain" "$HOME/.ssh/config" 2>/dev/null; then
            echo "Adding UseKeychain config to ~/.ssh/config..."
            printf "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile %s\n" "$SSH_KEY" >> "$HOME/.ssh/config"
        fi

        eval "$(ssh-agent -s)" > /dev/null
        ssh-add --apple-use-keychain "$SSH_KEY"

        echo "Public key (add this to GitHub, etc.):"
        cat "$SSH_KEY.pub"
    fi
fi

# -----------------------------------------------------------------------------
# Config symlinks
# Tracked configs are linked into place here (Sink's is in its own section).
# Add new configs to this section.
# -----------------------------------------------------------------------------
if approved symlinks "Symlink configs from ~/dots into place (replaces existing configs)?"; then
    # — Neovim ——————————————————————————————————————————————————————————————————————
    # Symlink the whole nvim/ directory. Wipe any existing config first so the
    # symlink is clean on re-runs.
    # lazy.nvim bootstraps itself on first launch; no separate install needed.
    echo "Linking ~/.config/nvim -> ~/dots/nvim..."
    rm -rf $HOME/.config/nvim
    ln -s $HOME/dots/nvim $HOME/.config/nvim

    # — Git config ——————————————————————————————————————————————————————————————————
    # .gitconfig holds user identity, push/pull defaults, and the commit template.
    # .gitmessage is the commit template referenced by gitconfig.
    # The `git config` call writes the absolute path into .gitconfig so it works
    # even before the symlink is in place on a fresh clone.
    echo "Linking ~/.gitconfig -> ~/dots/gitconfig..."
    rm -rf $HOME/.gitconfig
    ln -s $HOME/dots/gitconfig $HOME/.gitconfig

    echo "Linking ~/.gitmessage -> ~/dots/gitmessage..."
    rm -rf $HOME/.gitmessage
    ln -s $HOME/dots/gitmessage $HOME/.gitmessage
    git config --global commit.template $HOME/.gitmessage

    # — Claude Code config ——————————————————————————————————————————————————————————
    # ~/.claude itself is NOT symlinked — Claude Code fills it with runtime state
    # (history, sessions, caches) that doesn't belong in git. Only skills/ and
    # settings.json are tracked and linked individually.
    echo "Linking ~/.claude/skills -> ~/dots/claude/skills..."
    rm -rf $HOME/.claude/skills
    ln -s $HOME/dots/claude/skills $HOME/.claude/skills

    echo "Linking ~/.claude/agents -> ~/dots/claude/agents..."
    rm -rf $HOME/.claude/agents
    ln -s $HOME/dots/claude/agents $HOME/.claude/agents

    echo "Linking ~/.claude/rules -> ~/dots/claude/rules..."
    rm -rf $HOME/.claude/rules
    ln -s $HOME/dots/claude/rules $HOME/.claude/rules

    echo "Linking ~/.claude/settings.json -> ~/dots/claude/settings.json..."
    rm -f $HOME/.claude/settings.json
    ln -s $HOME/dots/claude/settings.json $HOME/.claude/settings.json

    # — Run ————————————————————————————————————————————————————————————————————————
    # Config and saved urls are tracked here so they match across machines; history
    # is per-machine runtime state and stays local (same reasoning as ~/.claude above).
    echo "Linking ~/.config/run/{config,urls} -> ~/dots/run/..."
    mkdir -p $HOME/.config/run
    ln -sf $HOME/dots/run/config $HOME/.config/run/config
    ln -sf $HOME/dots/run/urls $HOME/.config/run/urls

    # — Ghostty terminal ——————————————————————————————————————————————————————————
    # Symlink the whole ghostty/ directory so all config is tracked here.
    echo "Linking ~/.config/ghostty -> ~/dots/ghostty..."
    rm -rf $HOME/.config/ghostty
    ln -s $HOME/dots/ghostty $HOME/.config/ghostty

    # — herdr (terminal agent multiplexer) ————————————————————————————————————————
    # Only config.toml is linked — ~/.config/herdr also holds sockets, logs, and
    # session state that stay per-machine.
    echo "Linking ~/.config/herdr/config.toml -> ~/dots/herdr/config.toml..."
    mkdir -p $HOME/.config/herdr
    ln -sf $HOME/dots/herdr/config.toml $HOME/.config/herdr/config.toml

    # — Fish ———————————————————————————————————————————————————————————————————————
    # Symlink the whole fish/ directory (config.fish, functions/, conf.d/).
    echo "Linking ~/.config/fish -> ~/dots/fish..."
    rm -rf $HOME/.config/fish
    ln -s $HOME/dots/fish $HOME/.config/fish
fi

# -----------------------------------------------------------------------------
# Apps
# CLI tools share one approval (cli_tools); every GUI app has its own
# (app_<name>: the app's name lowercased, spaces as _), which the macos section
# checks too (see has_app). mas and claude come with the CLI tools.
# -----------------------------------------------------------------------------
formula() {
    if brew list "$1" > /dev/null 2>&1; then
        echo "  [upgrade] $1"
        brew upgrade "$@"
    else
        echo "  [install] $1"
        brew install "$@"
    fi
}
cask() {
    _name="${1##*/}"
    if brew list --cask "$_name" > /dev/null 2>&1; then
        echo "  [upgrade] $_name"
        brew upgrade --cask "$@"
    else
        echo "  [install] $_name"
        brew install --cask "$@"
    fi
}
# .pkg casks run Apple's installer as root, so they're only reported.
pkg_cask() {
    if brew list --cask "$1" > /dev/null 2>&1; then
        echo "  [skip] $1 — already installed"
    else
        echo "  [skip] $1 — needs sudo"
    fi
}
# mas needs root to install App Store apps, so they're only reported too.
mas_install() {
    if ! command -v mas > /dev/null; then
        echo "  [skip] $2 — mas isn't installed (it comes with the CLI tools)"
    elif mas list | grep -q "^$1 "; then
        echo "  [skip] $2 — already installed"
    else
        echo "  [skip] $2 — needs sudo"
    fi
}

# — CLI tools ————————————————————————————————————————————————————————————————————
# fzf        — fuzzy finder (used standalone and by some nvim plugins)
# ag         — silver searcher, fast code search
# ripgrep    — used by Telescope live_grep inside neovim
# gh         — GitHub CLI (used by create-pr/dependabot-prs/review skills)
# worktrunk  — `wt` worktree CLI (required by the ruby-app-refactor skill)
# herdr      — AI coding agent multiplexer (config linked in the symlinks section)
# wallpaper  — CLI to set the desktop wallpaper (used later in this script)
# defaultbrowser — CLI to set the default browser without a UI prompt
# claude-code and 1password-cli are casks, but only install CLIs.
if approved cli_tools "Install and upgrade CLI tools (Homebrew formulae, Claude Code, 1Password CLI)?"; then
    echo "Installing CLI tools..."
    formula fish
    formula fzf
    formula the_silver_searcher
    formula ripgrep
    formula nvim
    formula mas
    formula gh
    formula worktrunk
    formula herdr
    formula libpq
    formula openssl@3
    formula libiconv
    formula freetds
    formula npm
    formula wallpaper
    formula defaultbrowser
    formula xcodegen
    cask claude-code
    cask 1password-cli
fi

# — Run (https://github.com/thogg4/run) —————————————————————————————————————————
# Not distributed via Homebrew, so it's installed from a bundled .dmg instead.
if approved app_run "Install Run.app?"; then
    if [ -d "$(app_path Run)" ]; then
        echo "  [skip] Run.app — already installed"
    else
        echo "  [install] Run.app"
        RUN_MOUNT="$(mktemp -d)"
        rmdir "$RUN_MOUNT"
        hdiutil attach "$HOME/dots/run/Run.dmg" -nobrowse -readonly -noverify -quiet -mountpoint "$RUN_MOUNT"
        cp -R "$RUN_MOUNT/Run.app" "$APPDIR/"
        hdiutil detach "$RUN_MOUNT" -quiet
    fi
fi

# — GUI apps —————————————————————————————————————————————————————————————————————
# aerospace  — tiling window manager (tap required, not in core Homebrew)
# ice        — menu bar management
# orbstack   — lightweight Docker/Linux VM alternative to Docker Desktop
approved app_discord "Install Discord?" && cask discord
approved app_firefox "Install Firefox?" && cask firefox
approved app_google_chrome "Install Google Chrome?" && cask google-chrome
# 1Password won't launch from anywhere but /Applications.
if approved app_1password "Install 1Password?"; then
    if [ -w /Applications ]; then
        cask 1password --appdir=/Applications
    else
        echo "  [skip] 1password — needs sudo"
    fi
fi
approved app_microsoft_teams "Install Microsoft Teams?" && pkg_cask microsoft-teams
approved app_microsoft_outlook "Install Microsoft Outlook?" && pkg_cask microsoft-outlook
approved app_slack "Install Slack?" && cask slack
approved app_orbstack "Install OrbStack?" && cask orbstack
approved app_aerospace "Install AeroSpace?" && cask nikitabobko/tap/aerospace
approved app_ice "Install Ice?" && cask jordanbaird-ice
approved app_ghostty "Install Ghostty?" && cask ghostty
approved app_krisp "Install Krisp?" && pkg_cask krisp
approved app_linear "Install Linear?" && cask linear-linear
approved app_notion "Install Notion?" && cask notion
approved app_bruno "Install Bruno?" && cask bruno
approved app_postgres "Install Postgres.app?" && cask postgres-unofficial

# — App Store apps ———————————————————————————————————————————————————————————————
approved app_bear "Install Bear (App Store)?" && mas_install 1091189122 "Bear"
if approved app_xcode "Install Xcode (App Store) and add its MCP server to Claude Code?"; then
    mas_install 497799835 "Xcode"
    if [ ! -d "$(app_path Xcode)" ]; then
        echo "  [skip] Xcode MCP — Xcode isn't installed"
    elif ! command -v claude > /dev/null; then
        echo "  [skip] Xcode MCP — claude isn't installed (it comes with the CLI tools)"
    else
        claude mcp add --transport stdio xcode -- xcrun mcpbridge
    fi
fi

# — Plannotator (plan/code review UI) ————————————————————————————————————————
if approved app_plannotator "Install Plannotator and its Claude Code plugin?"; then
    echo "Installing Plannotator..."
    if ! /bin/bash -c "$(curl -fsSL https://plannotator.ai/install.sh)"; then
        echo "Plannotator install script failed, skipping marketplace/plugin setup." >&2
    elif ! command -v claude > /dev/null; then
        echo "  [skip] Plannotator plugin — claude isn't installed (it comes with the CLI tools)"
    else
        if claude plugin marketplace list | grep -q "backnotprop/plannotator"; then
            echo "Plannotator marketplace already added, skipping."
        else
            echo "Adding Plannotator marketplace..."
            claude plugin marketplace add backnotprop/plannotator
        fi
        if claude plugin list | grep -q "plannotator@plannotator"; then
            echo "Plannotator plugin already installed, skipping."
        else
            echo "Installing Plannotator plugin..."
            claude plugin install -y plannotator@plannotator
        fi
    fi
fi

# -----------------------------------------------------------------------------
# GitHub CLI auth
# -----------------------------------------------------------------------------
if approved gh "Log in to the GitHub CLI if needed?"; then
    echo "Checking gh CLI authentication..."
    if gh auth status > /dev/null 2>&1; then
        echo "gh already authenticated, skipping."
    else
        echo "Authenticating gh CLI..."
        gh auth login
    fi
fi

# -----------------------------------------------------------------------------
# Fish shell
# Makes fish the login shell. chsh only accepts shells listed in /etc/shells,
# and adding one there needs sudo, so when fish isn't listed Ghostty is pointed
# at fish instead (through the gitignored ghostty/local include).
# Checks fish exists first, since it's installed with the apps section's CLI tools and
# chsh-ing to a missing binary would break login.
# -----------------------------------------------------------------------------
if approved shell "Make fish your login shell?"; then
    FISH="$HOMEBREW_PREFIX/bin/fish"
    if [ ! -x "$FISH" ]; then
        echo "fish isn't installed (it comes with the CLI tools in the apps section), leaving the login shell alone." >&2
    elif [ "$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')" = "$FISH" ]; then
        echo "  [skip] login shell — already fish"
    elif grep -qx "$FISH" /etc/shells; then
        echo "Setting fish as login shell..."
        chsh -s "$FISH"
    else
        echo "  [skip] login shell — adding fish to /etc/shells needs sudo"
        echo "Pointing Ghostty at fish instead..."
        printf 'command = %s\n' "$FISH" > "$HOME/dots/ghostty/local"
    fi
fi

# -----------------------------------------------------------------------------
# Sink (directory sync daemon)
# Its config link lives here rather than in the symlinks section because it
# goes with the launchd agents below.
# -----------------------------------------------------------------------------
if approved sink "Link the Sink config and load its launchd agents?"; then
    echo "Linking ~/.config/sink -> ~/dots/sink/config..."
    rm -rf $HOME/.config/sink
    ln -s $HOME/dots/sink/config $HOME/.config/sink

    echo "Installing sink launchd agents..."
    chmod +x $HOME/dots/sink/bin/sink
    sed "s|__HOME__|$HOME|g" $HOME/dots/sink/launch_agents/com.sink.server.plist.template \
      > $HOME/Library/LaunchAgents/com.sink.server.plist
    sed "s|__HOME__|$HOME|g" $HOME/dots/sink/launch_agents/com.sink.client.plist.template \
      > $HOME/Library/LaunchAgents/com.sink.client.plist
    sed "s|__HOME__|$HOME|g" $HOME/dots/sink/launch_agents/com.sink.reconcile.plist.template \
      > $HOME/Library/LaunchAgents/com.sink.reconcile.plist
    launchctl load -w $HOME/Library/LaunchAgents/com.sink.server.plist 2>/dev/null || true
    launchctl load -w $HOME/Library/LaunchAgents/com.sink.client.plist 2>/dev/null || true
    launchctl load -w $HOME/Library/LaunchAgents/com.sink.reconcile.plist 2>/dev/null || true
    echo "Sink loaded. Edit ~/.config/sink/config.yml to add sync_dirs."
fi

# -----------------------------------------------------------------------------
# macOS System Preferences — close the GUI so defaults writes take effect
# cleanly without the app overwriting them on quit.
# -----------------------------------------------------------------------------
if approved macos "Apply macOS preferences (defaults, Dock, login items, default browser, wallpaper)?"; then
    echo "Closing System Preferences..."
    osascript -e 'tell application "System Preferences" to quit'

    # — Security ——————————————————————————————————————————————————————————————————
    # Suppress the "Are you sure you want to open this application?" Gatekeeper
    # dialog for apps downloaded from the internet.
    echo "Applying macOS defaults: security..."
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # — Trackpad ——————————————————————————————————————————————————————————————————
    # Tap to click (applies to both the current user and the login screen).
    echo "Applying macOS defaults: trackpad tap-to-click..."
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Use "natural" scroll direction: false = old-school (scroll up = content moves up).
    echo "Applying macOS defaults: scroll direction..."
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # — Audio —————————————————————————————————————————————————————————————————————
    # Raise the Bluetooth audio codec bitpool floor so headphones use a higher
    # quality codec instead of dropping to the lowest common denominator.
    echo "Applying macOS defaults: Bluetooth audio quality..."
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    # — Keyboard ——————————————————————————————————————————————————————————————————
    # KeyRepeat: delay between repeated keys when held (lower = faster).
    # InitialKeyRepeat: pause before repetition starts.
    # These values are lower than the UI allows.
    echo "Applying macOS defaults: keyboard repeat rate..."
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 13

    # Disable Spotlight's Cmd-Space and Cmd-Shift-Space shortcuts (keys 64/65)
    # so Run can own that hotkey without conflict (see run/config's launcher-hotkey).
    echo "Applying macOS defaults: Spotlight shortcuts..."
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '<dict><key>enabled</key><false/></dict>'
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 '<dict><key>enabled</key><false/></dict>'

    # — Screenshots ———————————————————————————————————————————————————————————————
    echo "Applying macOS defaults: screenshots..."
    defaults write com.apple.screencapture location -string "${HOME}/Downloads"
    defaults write com.apple.screencapture type -string "png"

    # — Finder ————————————————————————————————————————————————————————————————————
    # Open new windows to Downloads instead of the default "Recents" view.
    # PfLo = "Path from Location" (a custom folder), as opposed to PfHm (home).
    echo "Applying macOS defaults: Finder..."
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
    echo "Applying macOS defaults: Dock..."
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

    # Succeeds when the app was approved in the apps section and is on disk.
    # Reads the saved answer rather than calling approved, so it never asks.
    has_app() {
        if [ "$(saved_answer "$1")" != yes ]; then
            echo "  [skip] $2 — not approved"
            return 1
        fi
        [ -d "$(app_path "$2")" ] && return
        echo "  [skip] $2 — not installed"
        return 1
    }
    # dock_path adds any .app; dock_app <key> <Name> adds a Homebrew/App Store
    # app only when has_app says so.
    dock_path() {
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://$1/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
    }
    dock_app() {
        has_app "$1" "$2" && dock_path "$(app_path "$2")"
    }
    dock_app app_bear Bear
    dock_app app_linear Linear
    dock_app app_firefox Firefox
    dock_app app_ghostty Ghostty
    dock_path "/System/Applications/Mail.app"
    dock_app app_microsoft_teams "Microsoft Teams"
    dock_path "/System/Applications/Messages.app"
    dock_app app_slack Slack

    # Dock stacks: Downloads folder and /Applications as right-side tiles
    # (/Applications even when apps go in ~/Applications, by choice).
    defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-type</key><string>directory-tile</string><key>tile-data</key><dict><key>arrangement</key><integer>3</integer><key>file-data</key><dict><key>_CFURLString</key><string>file://${HOME}/Downloads/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>showas</key><integer>2</integer></dict></dict>"
    defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-type</key><string>directory-tile</string><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>showas</key><integer>2</integer></dict></dict>"

    # Apply all Dock changes.
    echo "Restarting Dock..."
    killall Dock

    # — Login items ———————————————————————————————————————————————————————————————
    # Clear existing login items, then add the ones we want.
    # hidden:false = the app window is visible at login (not launched in background).
    echo "Setting login items..."
    osascript -e 'tell application "System Events" to delete every login item'
    # Same split as the Dock: login_path for any .app, login_item <key> <Name>
    # only when has_app says so.
    login_path() {
        osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$1\", hidden:false}"
    }
    login_item() {
        has_app "$1" "$2" && login_path "$(app_path "$2")"
    }
    login_item app_firefox Firefox
    login_path "/System/Applications/Messages.app"
    login_path "/System/Applications/Mail.app"
    login_item app_ghostty Ghostty
    login_item app_slack Slack
    login_item app_microsoft_teams "Microsoft Teams"
    login_item app_postgres Postgres
    login_item app_bear Bear
    login_item app_krisp Krisp
    login_item app_linear Linear
    login_item app_bruno Bruno
    login_item app_run Run

    # — App Store —————————————————————————————————————————————————————————————————
    echo "Applying macOS defaults: App Store..."
    defaults write com.apple.appstore WebKitDeveloperExtras -bool true  # WebKit devtools in App Store
    defaults write com.apple.appstore ShowDebugMenu -bool true           # Debug menu in App Store

    # — Software Update ———————————————————————————————————————————————————————————
    echo "Applying macOS defaults: Software Update..."
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true  # Check daily
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1          # 1 = daily (default is weekly)
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1           # Download in background
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1       # Auto-install security patches
    defaults write com.apple.commerce AutoUpdate -bool true                    # Auto-update App Store apps
    defaults write com.apple.commerce AutoUpdateRestartRequired -bool true     # Allow reboot for OS updates

    # — Trackpad gestures —————————————————————————————————————————————————————————
    # Drag with lock: lets you drag windows by tapping twice and locking the drag.
    echo "Applying macOS defaults: trackpad gestures..."
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

    # Set Firefox as the default browser (defaultbrowser comes with cli_tools).
    if has_app app_firefox Firefox; then
        echo "Setting Firefox as default browser..."
        defaultbrowser firefox
    fi

    # — Dictation ————————————————————————————————————————————————————————————————
    # Enable dictation triggered by pressing the Fn key.
    echo "Applying macOS defaults: dictation..."
    defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 1
    defaults write com.apple.HIToolbox AppleFnUsageType -int 1

    # — Menu bar clock ————————————————————————————————————————————————————————————
    echo "Applying macOS defaults: menu bar clock..."
    defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm:ss a"
    defaults write com.apple.menuextra.clock ShowSeconds -bool true

    # Set desktop wallpaper (requires `brew install wallpaper`).
    echo "Setting desktop wallpaper..."
    wallpaper set wallpaper.jpg

    # Let the wallpaper get set
    sleep 5
fi

printf "Reboot now? [y/N] "
read REPLY < /dev/tty
case "$REPLY" in
    y|Y) osascript -e 'tell application "System Events" to restart' ;;
esac
