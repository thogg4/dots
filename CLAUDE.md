# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A macOS dotfiles repo. Running `setup.sh` does a full machine bootstrap: installs Homebrew packages/casks, symlinks configs, and applies `defaults write` settings. It is designed to be run once on a fresh machine.

## How configs are applied

Every config is tracked in this repo and symlinked into place by `setup.sh`. Adding a new config means:
1. Create the file/directory here (e.g. `dots/foo/config`)
2. Add `rm -rf $HOME/.config/foo && ln -s $HOME/dots/foo $HOME/.config/foo` to `setup.sh`

Current symlinks:
- `nvim/` → `~/.config/nvim`
- `fish/` → `~/.config/fish`
- `ghostty/` → `~/.config/ghostty`
- `claude/skills/` → `~/.claude/skills` (personal Claude Code skills, one `<name>/SKILL.md` per skill)
- `claude/rules/` → `~/.claude/rules` (guideline docs referenced by skills, e.g. dev-workflow)
- `claude/settings.json` → `~/.claude/settings.json` (the rest of `~/.claude` is untracked runtime state)
- `gitconfig` → `~/.gitconfig`
- `gitmessage` → `~/.gitmessage`
- `run/config` → `~/.config/run/config`, `run/urls` → `~/.config/run/urls` (Run.app's config and saved urls; `run/Run.dmg` is installed to `/Applications` by `setup.sh` since it's not on Homebrew; `history` is per-machine runtime state and isn't tracked)

## Neovim architecture

Entry point is `nvim/init.lua`, which sets `<Leader>` to `\` and loads modules in order: `options` → `autocmds` → `plugins` → `keymaps`.

All plugins live in `nvim/lua/plugins.lua` as a single lazy.nvim spec. Plugin-specific keymaps are defined alongside their plugin in `plugins.lua`; only non-plugin keymaps go in `keymaps.lua`.

Key plugins and their bindings:
- **Telescope**: `<C-P>` files, `<Leader>f{g,b,h,d,r}` for grep/buffers/help/diagnostics/recent
- **Comment.nvim**: `<Leader>cc` toggle comment, `<Leader>uc` toggle uncomment
- **vim-test**: `<Leader>t` nearest, `<Leader>T` file, `<Leader>l` last — runs in toggleterm
- **LSP**: `gd` definition, `gr` references, `K` hover, `<Leader>ca` code action, `<Leader>rn` rename
- **Gitsigns**: `]g`/`[g` hunks, `<Leader>gp` preview, `<Leader>gb` blame
- **Trouble**: `<Leader>xx` diagnostics panel, `<Leader>xb` buffer diagnostics
- **Aerial**: `<Leader>a` code outline
- **Toggleterm**: `<C-T>` bottom terminal, `<Leader>c` close all; `<C-h/j/k/l>` navigates between editor and terminal splits
- **Claudecode**: `<C-Y>` Claude Code side pane via claudecode.nvim IDE integration — Claude sees open files, selections, and diagnostics (35% width, right side, runs `claude --permission-mode acceptEdits`, auto-opens at startup except for git commit/rebase edits); `<Leader>as` sends the visual selection to Claude

LSP servers are managed by Mason and auto-installed: `ruby-lsp`, `typescript-language-server`, `lua-language-server`, `elixir-ls`.

`lazy-lock.json` pins plugin versions — commit it when updating plugins (`:Lazy update` inside nvim).

## Shell (fish)

`fish/config.fish` is the main config. Key aliases: `m` = nvim, `c` = claude, `be` = bundle exec, `gs/ga/gc/gp` = git shortcuts.

## Ghostty terminal

Config at `ghostty/config`. Theme: `TokyoNight Night`. Background opacity 0.85, non-blinking block cursor.

## Run

Run.app (https://github.com/thogg4/run) is the launcher/app-switcher, replacing Raycast. It's not on Homebrew, so `setup.sh` installs it from the bundled `run/Run.dmg`. `run/config` and `run/urls` are tracked and symlinked into `~/.config/run/`; `history` is per-machine runtime state and isn't tracked. It owns the Cmd+Space hotkey (`launcher-hotkey` in `run/config`), which is why `setup.sh` disables macOS's Spotlight Cmd+Space/Cmd+Shift+Space shortcuts.
