# dots

macOS dotfiles and full machine bootstrap for a fresh install.

## What it does

Running `setup.sh` once on a clean machine will:

- Install **Homebrew** and upgrade any existing packages
- Install **rbenv**, the latest stable Ruby, and the `kamal` gem
- Install CLI tools (fish, fzf, ripgrep, ag, nvim, mas, libpq, …) and GUI apps via Homebrew casks (Firefox, Ghostty, Slack, 1Password, OrbStack, Linear, Notion, Bruno, Postgres, and more; `.pkg` casks like Krisp are skipped, see below). You choose whether casks go in `~/Applications` or `/Applications`. The choice is set in `~/.homebrew/brew.env`, so later `brew install --cask` runs go there too. Changing it later doesn't move apps that are already installed. 1Password always goes in `/Applications`, since it won't launch anywhere else. It's skipped if `/Applications` isn't writable
- Install Run.app (launcher) into the same apps folder from the bundled `run/Run.dmg` — it's not on Homebrew
- Check Mac App Store apps via `mas` (installing them needs sudo, so missing ones are only reported)
- Symlink all configs into place (see below)
- Apply a comprehensive set of `defaults write` settings for macOS (Dock, Finder, keyboard, trackpad, screenshots, Bluetooth audio, Spotlight, Dictation, menu bar clock)
- Set Firefox as the default browser
- Set the desktop wallpaper
- Configure login items

## Configs managed here

| File/Dir | Symlinked to |
|---|---|
| `nvim/` | `~/.config/nvim` |
| `fish/` | `~/.config/fish` |
| `ghostty/` | `~/.config/ghostty` |
| `claude/` | `~/.claude` |
| `gitconfig` | `~/.gitconfig` |
| `gitmessage` | `~/.gitmessage` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `run/config`, `run/urls` | `~/.config/run/config`, `~/.config/run/urls` |
| `irbrc` | (manually placed) |
| `pryrc` | (manually placed) |

## Usage

```sh
git clone https://github.com/timhogg/dots ~/dots
cd ~/dots
./setup.sh
```

The script never uses sudo itself. On a fresh machine it asks whether Homebrew goes in `~/hb` or the default `/opt/homebrew`; for `/opt/homebrew`, Homebrew's installer asks for your password. `~/hb` needs no password, but Homebrew doesn't officially support it, and some packages (such as neovim, node and openssl) build from source there when `~/hb` is longer than `/opt/homebrew`. If the Xcode Command Line Tools are missing, it opens Apple's installer for them and skips Homebrew until you rerun. Steps that need sudo print a `[skip] … needs sudo` line and move on:
- App Store apps
- `.pkg` casks (Teams, Outlook, Krisp)
- adding fish to `/etc/shells`. When that's skipped, Ghostty launches fish through a gitignored `ghostty/local` instead, so fish isn't your login shell but every terminal opens in it.

Most steps are idempotent — re-running is safe.

The first time it runs, it asks whether apps go in `~/Applications` or `/Applications`, then before each section (Homebrew, Ruby, SSH key, config symlinks, apps, `gh` login, fish login shell, Sink, macOS preferences) and skips any you decline. Answers are saved to `.setup-approvals` (gitignored, one `section=yes|no` line each; `home_applications=yes` means `~/Applications`, `home_homebrew=yes` means `~/hb`), so later runs don't ask again. Delete a line, or the whole file, to be asked again. Later sections rely on tools from earlier ones (most need Homebrew; `gh` login, the fish login shell and the macOS preferences need apps), so only decline those on a machine that already has them.

## Key tools and their configs

**Neovim** (`nvim/`) — entry point is `nvim/init.lua`. Plugins managed by lazy.nvim, all defined in `nvim/lua/plugins.lua`. LSP servers (ruby-lsp, typescript-language-server, lua-language-server, elixir-ls) auto-installed by Mason on first launch.

**Fish** (`fish/config.fish`) — key aliases: `m` = nvim, `c` = claude, `be` = bundle exec, `gs/ga/gc/gp` = git shortcuts. `h` (`fish/functions/h.fish`) starts herdr with a space for every directory in `~/work`, skipping ones that already have a space.

**Ghostty** (`ghostty/config`) — TokyoNight Night theme, 0.85 background opacity, non-blinking block cursor.

**herdr** (`herdr/config.toml`) — agent multiplexer, installed via Homebrew. Dracula theme, prefix `ctrl+\` (nvim's `\` leader plus ctrl, so it doesn't swallow `\` in panes). `cmd+shift+left/right` switch herdr tabs (taken over from Ghostty, whose own tabs still switch with `cmd+shift+[`/`]`). `cmd+shift+up/down` step through spaces (Ghostty unbinds its own prompt-jump on those keys so they reach herdr) and `shift+option+up/down` through agents. `cmd+k` clears the focused pane (Ghostty's own `cmd+k` clear is unbound). `cmd+t` opens a new herdr tab right away, without asking for a name (Ghostty's own `cmd+t` new tab is unbound).

**Run** (`run/config`, `run/urls`) — launcher app, installed from `run/Run.dmg` since it's not on Homebrew. Owns the Cmd+Space hotkey, so `setup.sh` disables Spotlight's Cmd+Space/Cmd+Shift+Space shortcuts.

## Adding a new config

1. Create the file or directory here (e.g. `dots/foo/config`)
2. Add a symlink step to the `symlinks` section of `setup.sh`:
   ```sh
   rm -rf $HOME/.config/foo && ln -s $HOME/dots/foo $HOME/.config/foo
   ```
3. Commit both the config and the updated `setup.sh`
