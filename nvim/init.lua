-- =============================================================================
-- init.lua — Neovim entry point
-- =============================================================================
--
-- This file is the first thing Neovim reads. It sets the leader key (must
-- happen before any plugins load, otherwise plugin keymaps use the wrong
-- leader), then loads each module in order.
--
-- Module load order matters:
--   1. options  — set vim.opt values first so plugins inherit correct settings
--   2. autocmds — register autocommands before plugins can fire events
--   3. plugins  — bootstrap lazy.nvim and load all plugins
--   4. keymaps  — non-plugin keymaps last so they can safely override anything
--                 plugins register during their setup

-- Leader key: \ (backslash) — same as the old init.vim default.
-- Set BEFORE plugins so lazy-loaded plugin keymaps use this leader.
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

require("options")  -- vim.opt settings (indentation, UI, search, etc.)
require("autocmds") -- autocommands (cursor restore, yank highlight, etc.)
require("plugins")  -- lazy.nvim bootstrap + all plugin specs
require("keymaps")  -- non-plugin keymaps (movement, splits, debugger, etc.)
