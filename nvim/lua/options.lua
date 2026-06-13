-- =============================================================================
-- options.lua — Neovim core settings (vim.opt)
-- =============================================================================
--
-- This is the Lua equivalent of the "set" lines in the old init.vim.
-- vim.opt works like a Lua table and supports :append(), :remove(), etc.

local opt = vim.opt

-- -----------------------------------------------------------------------------
-- Indentation
-- -----------------------------------------------------------------------------

opt.autoindent = true   -- copy indent from previous line when starting a new one
opt.smartindent = true  -- add extra indent when entering a block (after { etc.)
opt.expandtab = true    -- <Tab> inserts spaces, not a tab character
opt.shiftwidth = 2      -- number of spaces used for each indent level (>> and <<)
opt.softtabstop = 2     -- how many spaces <Tab>/<BS> count as in insert mode
opt.tabstop = 4         -- how wide a real \t character appears (for files that have them)
opt.wrap = false        -- don't soft-wrap long lines — scroll horizontally instead
opt.textwidth = 120     -- hard-wrap (insert newline) at 120 chars with 'gq' or formatoptions
opt.virtualedit = "block" -- allow cursor to move past end-of-line in visual block mode
-- 'n' in formatoptions recognises numbered/bulleted lists and indents them correctly
opt.formatoptions:append("n")

-- -----------------------------------------------------------------------------
-- User Interface
-- -----------------------------------------------------------------------------

opt.number = true       -- show absolute line numbers in the gutter
opt.ruler = true        -- show cursor position (row, col) in the status line
opt.showcmd = false     -- don't show partial command in the last line (reduces noise)
opt.cmdheight = 1       -- height of the command line at the bottom (1 is fine with fidget.nvim)
opt.laststatus = 2      -- always show the status line (0=never, 1=only splits, 2=always)
opt.signcolumn = "yes"  -- always show the sign column (left gutter for LSP/git icons)
                        -- prevents the text from jumping left/right as signs appear
opt.cursorline = true   -- highlight the entire line the cursor is on
opt.wildmenu = true     -- show completion menu in command mode (e.g. :e <Tab>)
opt.wildmode = { "list:longest", "full" } -- first Tab completes to longest common match,
                                           -- second Tab cycles through all matches
opt.backspace = "indent,eol,start" -- allow <BS> to delete autoindent, end-of-line, and
                                    -- chars before insert started (makes BS behave normally)
-- shortmess flags suppress various informational messages:
--   I = skip the :intro splash screen on startup
--   c = don't show "match 1 of N" messages from completion
opt.shortmess:append("I")
opt.shortmess:append("c")
opt.report = 0          -- always report the number of lines changed by a command (even 1)
opt.startofline = false -- keep cursor column when jumping (G, gg, Ctrl-D, etc.)
opt.splitbelow = true   -- new horizontal splits open below the current window
opt.splitright = true   -- new vertical splits open to the right
opt.termguicolors = true -- use 24-bit RGB colors (required by tokyonight and most themes)
opt.mouse = ""          -- disable mouse entirely (opt.mouse = "a" would enable all modes)
-- unnamedplus makes all yank/delete/paste operations use the system clipboard (+),
-- so you can paste from nvim into other apps without explicit "+y
opt.clipboard:append("unnamedplus")

-- -----------------------------------------------------------------------------
-- Search
-- -----------------------------------------------------------------------------

opt.incsearch = true    -- show search matches as you type (incremental search)
opt.hlsearch = false    -- don't keep all matches highlighted after searching
                        -- (use :noh or <Esc> to clear highlights if you add hlsearch)
opt.showmatch = true    -- briefly jump to matching bracket when you type a closing one
opt.matchtime = 5       -- how long (in tenths of a second) to show the match
opt.ignorecase = true   -- case-insensitive search by default
opt.smartcase = true    -- override ignorecase: if you type a capital, match becomes case-sensitive

-- -----------------------------------------------------------------------------
-- Performance / timing
-- -----------------------------------------------------------------------------

opt.ttimeoutlen = 10    -- milliseconds to wait for a key sequence after Esc
                        -- low value means Esc feels instant in insert mode
opt.timeoutlen = 300    -- milliseconds to wait for a mapped key sequence (e.g. <Leader>t)
opt.updatetime = 250    -- ms of inactivity before CursorHold fires and swap file is written
                        -- lower = faster gitsigns/LSP hover triggers

-- -----------------------------------------------------------------------------
-- File handling
-- -----------------------------------------------------------------------------

opt.swapfile = false    -- don't create .swp files (annoying with version control)
opt.autoread = true     -- automatically re-read a file if it changes on disk and has no
                        -- unsaved changes (works with the FocusGained autocmd in autocmds.lua)
opt.undofile = true     -- persist undo history across sessions
opt.undodir = vim.fn.stdpath("data") .. "/undo"
                        -- store undo files in ~/.local/share/nvim/undo (XDG-compliant,
                        -- unlike the old config's ~/.vim/backups)

-- -----------------------------------------------------------------------------
-- Visual aids
-- -----------------------------------------------------------------------------

opt.visualbell = true   -- flash the screen instead of beeping
opt.errorbells = false  -- don't beep on errors
opt.list = true         -- show invisible characters (tabs, trailing spaces, non-breaking spaces)
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
                        -- how to render each invisible character type

-- -----------------------------------------------------------------------------
-- Folding — powered by treesitter (defined in plugins.lua)
-- -----------------------------------------------------------------------------

opt.foldenable = false  -- start with all folds open (press 'zi' to toggle folding globally)
opt.foldlevel = 99      -- open folds up to 99 levels deep when folding IS enabled
opt.foldmethod = "expr" -- use a custom expression to decide fold boundaries
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- built-in since nvim 0.10, no plugin needed
                        -- use treesitter AST to find fold boundaries (much smarter than
                        -- indent-based folding — understands Ruby blocks, JS functions, etc.)
