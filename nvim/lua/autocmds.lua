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

-- -----------------------------------------------------------------------------
-- :q in the last editor window quits nvim, terminal panes included
-- Without this, quitting the last file window leaves a terminal (e.g. the
-- Claude pane) as the sole window, and toggleterm then swaps the file buffer
-- back into it — which looks like :q closed the terminal split instead of the
-- one the cursor was in. Closing the terminal windows first makes the :q apply
-- to the whole session. With other file windows open, :q behaves as normal.
-- -----------------------------------------------------------------------------
autocmd("QuitPre", {
  group = augroup("quit_with_terminals", { clear = true }),
  callback = function()
    if vim.bo.buftype == "terminal" then return end
    local term_wins = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local is_float = vim.api.nvim_win_get_config(win).relative ~= ""
      if win ~= vim.api.nvim_get_current_win() and not is_float then
        if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
          table.insert(term_wins, win)
        else
          return -- another file window remains; let :q close just this split
        end
      end
    end
    for _, win in ipairs(term_wins) do
      vim.api.nvim_win_close(win, true)
    end
  end,
})
