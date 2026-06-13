-- =============================================================================
-- autocmds.lua — Autocommands (event-driven behaviour)
-- =============================================================================
--
-- Autocommands run Lua callbacks (or Vim commands) in response to events like
-- opening a file, saving, yanking text, or the window gaining focus.
--
-- augroup: groups related autocommands together. { clear = true } means
-- re-sourcing this file won't register the same autocommand twice.

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- -----------------------------------------------------------------------------
-- Restore cursor to last known position
-- Equivalent to the old init.vim "au BufReadPost *" block.
-- When you reopen a file, the cursor jumps back to where you left it.
-- -----------------------------------------------------------------------------
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function()
    -- '"  is the mark nvim writes when you close a file
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    -- Only restore if the saved line is still within the file (guard against
    -- files that were truncated since you last visited them)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Briefly highlight yanked text
-- A small visual confirmation that your yank worked. Flashes the IncSearch
-- highlight colour over the yanked region for 150ms.
-- -----------------------------------------------------------------------------
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- -----------------------------------------------------------------------------
-- Auto-reload files changed outside nvim
-- Works with opt.autoread = true (set in options.lua). Without this autocmd,
-- autoread only triggers on certain operations. FocusGained fires when the
-- terminal window/tab regains focus; BufEnter fires when switching buffers.
-- -----------------------------------------------------------------------------
autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup("auto_read", { clear = true }),
  command = "checktime", -- re-read the file from disk if it changed
})
