-- =============================================================================
-- keymaps.lua — Non-plugin keymaps
-- =============================================================================
--
-- Plugin-specific keymaps (telescope, vim-test, toggleterm, LSP, gitsigns)
-- are defined alongside their plugins in plugins.lua so they stay co-located
-- with the plugin that provides the action.
--
-- vim.keymap.set(mode, lhs, rhs, opts)
--   mode  — "n" normal, "i" insert, "v" visual, "t" terminal, or a table of modes
--   lhs   — the key sequence to map
--   rhs   — what to execute (string = Vim command/keys, function = Lua callback)
--   opts  — { silent = true } suppresses the command echo in the status line
--           { desc = "..." } shows up in which-key and :map listings

local map = vim.keymap.set

-- -----------------------------------------------------------------------------
-- Movement — sane behaviour with soft-wrap
-- By default j/k move by screen lines (gj/gk), not logical lines.
-- This means long wrapped lines feel natural to navigate.
-- We remap the arrow keys too so they're consistent.
-- -----------------------------------------------------------------------------
map({ "n", "v" }, "j", "gj", { silent = true })
map({ "n", "v" }, "k", "gk", { silent = true })
map({ "n", "v" }, "<Down>", "gj", { silent = true })
map({ "n", "v" }, "<Up>", "gk", { silent = true })
map("i", "<Down>", "<C-o>gj", { silent = true }) -- <C-o> runs one normal command from insert mode
map("i", "<Up>", "<C-o>gk", { silent = true })

-- Jump 10 lines at a time with Shift+Arrow (faster scrolling)
map({ "n", "v" }, "<S-Down>", "10j", { silent = true })
map({ "n", "v" }, "<S-Up>", "10k", { silent = true })
map("i", "<S-Down>", "<Esc>10ji", { silent = true }) -- Esc to normal, jump, back to insert
map("i", "<S-Up>", "<Esc>10ki", { silent = true })

-- Q: reflow (hard-wrap) the current paragraph or visual selection to textwidth
-- gqap = reflow paragraph; gq = reflow visual selection
map("n", "Q", "gqap", { silent = true })
map("v", "Q", "gq", { silent = true })

-- -----------------------------------------------------------------------------
-- Split navigation — Ctrl+Arrow to move between windows
-- Matches the old init.vim behaviour. More ergonomic than <C-w>hjkl when
-- you're already using arrow keys for movement.
-- -----------------------------------------------------------------------------
map("n", "<C-Right>", "<C-w>l", { silent = true }) -- move to window on the right
map("n", "<C-Left>", "<C-w>h", { silent = true })  -- move to window on the left
map("n", "<C-Up>", "<C-w>k", { silent = true })    -- move to window above
map("n", "<C-Down>", "<C-w>j", { silent = true })  -- move to window below

-- Split creation — <C-A> as a prefix (mirrors the old <C-A> + <C-W> combo)
map("n", "<C-A>", "<C-w>", { silent = true })         -- pass through to <C-w> commands
map("n", '<C-A>"', ":sp<CR>", { silent = true })       -- horizontal split
map("n", "<C-A>:", ":vsp<CR>", { silent = true })      -- vertical split

-- -----------------------------------------------------------------------------
-- Terminal — escape terminal mode with Esc
-- In a :terminal buffer, <C-\><C-N> exits to normal mode.
-- This maps Esc to do the same so muscle memory works.
-- (Terminal-specific keymaps use mode "t")
-- -----------------------------------------------------------------------------
map("t", "<Esc>", "<C-\\><C-N>", { silent = true })

-- -----------------------------------------------------------------------------
-- Ruby debugger helpers
-- <Leader>b  — insert a binding.pry on the line below and save
-- <Leader>B  — remove ALL binding.pry lines from the file (cleanup before commit)
-- -----------------------------------------------------------------------------
map("i", "<Leader>b", "<Esc>obinding.pry<Esc>:w<CR>", { silent = true,
  desc = "Insert binding.pry below (insert mode)" })
map("n", "<Leader>b", "obinding.pry<Esc>:w<CR>", { silent = true,
  desc = "Insert binding.pry below" })
map("n", "<Leader>B", function()
  vim.cmd(":%s/binding.pry//gi") -- case-insensitive global substitution
end, { silent = true, desc = "Remove all binding.pry" })

-- -----------------------------------------------------------------------------
-- Strip trailing whitespace — manual (run when you want it, not on every save)
-- winsaveview/winrestview preserves the cursor position and scroll state so
-- the buffer doesn't visually jump after the substitution.
-- -----------------------------------------------------------------------------
map("n", "<Leader>s", function()
  local save = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//ge]]) -- \s\+ = one or more whitespace, $ = end of line, e = no error if no match
  vim.fn.winrestview(save)
end, { desc = "Strip trailing whitespace" })

-- -----------------------------------------------------------------------------
-- Format JSON — pipe buffer through jq
-- -----------------------------------------------------------------------------
map("n", "<Leader>jq", ":%!jq .<CR>", { silent = true, desc = "Format JSON with jq" })

-- -----------------------------------------------------------------------------
-- Clear search highlight
-- After searching, pressing Esc in normal mode removes the lingering highlights.
-- (opt.hlsearch is off by default, but this handles the case where you
-- temporarily enabled it or used :set hlsearch manually.)
-- -----------------------------------------------------------------------------
map("n", "<Esc>", ":nohlsearch<CR>", { silent = true })
