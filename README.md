# dots

macOS dotfiles and full machine bootstrap for a fresh install.

## What it does

Running `setup.sh` once on a clean machine will:

- Install **Homebrew** and upgrade any existing packages
- Install **rbenv**, the latest stable Ruby, and the `kamal` gem
- Install CLI tools (fish, fzf, ripgrep, ag, nvim, mas, libpq, …) and GUI apps via Homebrew casks (Firefox, Ghostty, Slack, 1Password, Raycast, OrbStack, Linear, Notion, Bruno, Postgres, Krisp, and more)
- Install Mac App Store apps via `mas`
- Symlink all configs into place (see below)
- Apply a comprehensive set of `defaults write` settings for macOS (Dock, Finder, keyboard, trackpad, screenshots, Bluetooth audio, Spotlight, Dictation, menu bar clock)
- Configure Raycast (import extensions/quicklinks/snippets from `raycast.json`)
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

**Fish** (`fish/config.fish`) — key aliases: `m` = nvim, `c` = claude, `be` = bundle exec, `gs/ga/gc/gp` = git shortcuts.

**Ghostty** (`ghostty/config`) — TokyoNight Night theme, 0.85 background opacity, non-blinking block cursor.

**Raycast** (`raycast.json`) — extensions (Linear, GitHub, 1Password, Messages, Format JSON), quicklinks, `@@` email snippet, and preferences. To update: export from Raycast → decrypt → overwrite `raycast.json` → commit (see CLAUDE.md for the exact commands).

## Adding a new config

1. Create the file or directory here (e.g. `dots/foo/config`)
2. Add a symlink step to `setup.sh`:
   ```sh
   rm -rf $HOME/.config/foo && ln -s $HOME/dots/foo $HOME/.config/foo
   ```
3. Commit both the config and the updated `setup.sh`
