# dots

macOS dotfiles and full machine bootstrap for a fresh install.

## What it does

Running `setup.sh` once on a clean machine will:

- Install **Homebrew** and upgrade any existing packages
- Install **rbenv**, the latest stable Ruby, and the `kamal` gem
- Install CLI tools (fish, fzf, ripgrep, ag, nvim, mas, libpq, …) and GUI apps via Homebrew casks (Firefox, Ghostty, Slack, 1Password, OrbStack, Linear, Notion, Bruno, Postgres, Krisp, and more)
- Install Run.app (launcher) from the bundled `run/Run.dmg` — it's not on Homebrew
- Install Mac App Store apps via `mas`
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

The script asks for your sudo password once at the start and validates it before proceeding. Most steps are idempotent — re-running is safe.

## Key tools and their configs

**Neovim** (`nvim/`) — entry point is `nvim/init.lua`. Plugins managed by lazy.nvim, all defined in `nvim/lua/plugins.lua`. LSP servers (ruby-lsp, typescript-language-server, lua-language-server, elixir-ls) auto-installed by Mason on first launch.

**Fish** (`fish/config.fish`) — key aliases: `m` = nvim, `c` = claude, `be` = bundle exec, `gs/ga/gc/gp` = git shortcuts. `h` (`fish/functions/h.fish`) starts herdr with a space for every directory in `~/work`, skipping ones that already have a space.

**Ghostty** (`ghostty/config`) — TokyoNight Night theme, 0.85 background opacity, non-blinking block cursor.

**herdr** (`herdr/config.toml`) — agent multiplexer, installed via Homebrew. Dracula theme, prefix `ctrl+\` (nvim's `\` leader plus ctrl, so it doesn't swallow `\` in panes). `cmd+shift+left/right` switch herdr tabs (taken over from Ghostty, whose own tabs still switch with `cmd+shift+[`/`]`). `cmd+shift+up/down` step through agents (Ghostty unbinds its own prompt-jump on those keys so they reach herdr) and `shift+option+up/down` through spaces. `cmd+k` clears the focused pane (Ghostty's own `cmd+k` clear is unbound).

**Run** (`run/config`, `run/urls`) — launcher app, installed from `run/Run.dmg` since it's not on Homebrew. Owns the Cmd+Space hotkey, so `setup.sh` disables Spotlight's Cmd+Space/Cmd+Shift+Space shortcuts.

## Adding a new config

1. Create the file or directory here (e.g. `dots/foo/config`)
2. Add a symlink step to `setup.sh`:
   ```sh
   rm -rf $HOME/.config/foo && ln -s $HOME/dots/foo $HOME/.config/foo
   ```
3. Commit both the config and the updated `setup.sh`
