-- =============================================================================
-- plugins.lua — Plugin manager (lazy.nvim) + all plugin specs
-- =============================================================================
--
-- lazy.nvim is the modern Neovim plugin manager. Key advantages over Vundle:
--   - Lazy-loading: plugins only load when needed (on keypress, filetype, command)
--     which keeps startup time fast even with many plugins
--   - Lock file (lazy-lock.json): reproducible installs across machines
--   - Built-in UI: run :Lazy to see plugin status, update, clean, etc.
--   - No separate install step needed in setup.sh — it bootstraps itself
--
-- Each plugin spec can be:
--   "author/repo"                       — load on startup
--   { "author/repo", ... }              — load with options
--   { "author/repo", lazy = true, ... } — only load when triggered
--
-- Lazy-loading triggers:
--   keys  = { ... }     — load when one of these keymaps is pressed
--   cmd   = "..."       — load when this Ex command is run
--   event = "..."       — load on a Neovim event (BufReadPost, InsertEnter, etc.)
--   ft    = "..."       — load for a specific filetype

-- -----------------------------------------------------------------------------
-- Bootstrap: clone lazy.nvim if it isn't installed yet
-- On first launch this clones lazy.nvim into ~/.local/share/nvim/lazy/lazy.nvim
-- and on subsequent launches it just prepends the path.
-- -----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- vim.uv is preferred in nvim 0.10+; fall back to vim.loop for older versions
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath) -- add lazy.nvim to the runtime path so it can be required

-- =============================================================================
-- Plugin specifications
-- =============================================================================
require("lazy").setup({

  -- ---------------------------------------------------------------------------
  -- COLORSCHEME — tokyonight
  -- ---------------------------------------------------------------------------
  -- lazy = false + priority = 1000 ensures this loads first, before any other
  -- plugin, so there's no flash of the default theme during startup.
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",    -- variants: "storm" | "moon" | "night" | "day"
        transparent = true, -- make the Normal background transparent so the
        -- terminal's own background shows through
      })
      vim.cmd("colorscheme tokyonight-night")
      -- Explicitly clear the background highlight groups so transparent = true
      -- works correctly (some terminals need this nudge)
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- TREESITTER — syntax highlighting, indentation, folding
  -- ---------------------------------------------------------------------------
  -- Replaces: vim-ruby, vim-javascript, vim-elixir, vim-markdown, vim-coffee-
  --           script, vim-less, mustache.vim, vim-slim (for highlighting)
  --
  -- Treesitter parses source code into a concrete syntax tree (CST) and uses
  -- that tree for highlighting, indentation, and text objects. This is far more
  -- accurate than regex-based syntax files, especially for embedded languages
  -- (e.g. Ruby heredocs, JS in HTML).
  --
  -- build = ":TSUpdate" compiles the parsers after install/update.
  -- Parsers live in ~/.local/share/nvim/lazy/nvim-treesitter/parser/
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" }, -- lazy-load: only after a file opens
    config = function()
      -- nvim-treesitter removed the 'configs' submodule in its rewrite.
      -- The new API is require("nvim-treesitter").setup(); highlight and
      -- indent are now enabled by default when parsers are installed.
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc",
          "ruby", "javascript", "typescript", "tsx",
          "elixir", "heex",
          "html", "css", "scss",
          "json", "yaml", "toml",
          "markdown", "markdown_inline",
          "bash", "fish",
          "coffee",
        },
        auto_install = true, -- auto-install a parser for any filetype you open
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- LSP — Language Server Protocol (nvim 0.11+ native API)
  -- ---------------------------------------------------------------------------
  -- nvim 0.11 added vim.lsp.config / vim.lsp.enable as a first-class API,
  -- replacing the old require('lspconfig').server.setup() pattern. We use
  -- that new API directly here to avoid the deprecation warning.
  --
  -- mason.nvim     — TUI to install/manage LSP servers (:Mason to open)
  -- fidget.nvim    — shows LSP indexing progress in the bottom-right corner
  --
  -- Mason installs server binaries into ~/.local/share/nvim/mason/bin/ and
  -- adds that directory to PATH, so we can reference servers by name (e.g.
  -- "ruby-lsp") without hard-coding the full path.
  --
  -- Keymaps active inside any LSP-attached buffer:
  --   gd              — go to definition
  --   gD              — go to declaration
  --   gr              — list all references
  --   gi              — go to implementation
  --   K               — hover docs (press again to focus the hover window)
  --   <Leader>rn      — rename symbol across the whole project
  --   <Leader>ca      — code actions (auto-fix, extract variable, etc.)
  --   <Leader>e       — show diagnostic for current line in a float
  --   [d / ]d         — jump to previous/next diagnostic
  {
    "williamboman/mason.nvim",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- teaches nvim-cmp about LSP completion items
      "j-hui/fidget.nvim",    -- LSP progress indicator
    },
    config = function()
      -- Show LSP startup/indexing progress as a small widget in the corner
      require("fidget").setup({})

      -- Mason: install servers via :Mason, or auto-install below
      require("mason").setup()

      -- Auto-install servers that aren't present yet.
      -- mason-registry.refresh() ensures the package list is up to date
      -- before we try to look up packages by name.
      local registry = require("mason-registry")
      local mason_packages = {
        "ruby-lsp",                   -- Ruby (successor to solargraph)
        "typescript-language-server", -- TypeScript / JavaScript
        "lua-language-server",        -- Lua (for editing this config)
        "elixir-ls",                  -- Elixir
      }
      registry.refresh(function()
        for _, name in ipairs(mason_packages) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)

      -- LSP keymaps: registered via LspAttach so they're buffer-local and only
      -- active when a server is actually running for that file. This is the
      -- modern replacement for the on_attach callback pattern.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
        callback = function(args)
          local opts = { noremap = true, silent = true, buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })

      -- Extend the default LSP client capabilities with whatever nvim-cmp
      -- can handle (snippet expansion, labelDetails, etc.)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- vim.lsp.config(name, cfg): set per-server config (cmd, filetypes,
      -- root detection, settings). Merged with any existing defaults.
      -- vim.lsp.enable(name): tell nvim to auto-start this server when a
      -- matching filetype opens in a matching project root.

      vim.lsp.config("ruby_lsp", {
        cmd = { "ruby-lsp" },
        filetypes = { "ruby", "eruby" },
        root_markers = { "Gemfile", ".ruby-version", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = {
          "javascript", "javascriptreact", "javascript.jsx",
          "typescript", "typescriptreact", "typescript.tsx",
        },
        root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("elixirls", {
        cmd = { "elixir-ls" },
        filetypes = { "elixir", "eelixir", "heex", "surface" },
        root_markers = { "mix.exs", ".git" },
        capabilities = capabilities,
      })

      -- lua_ls: suppress false "undefined global 'vim'" warning in nvim config
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      -- Start the servers (they auto-attach when a matching file opens)
      vim.lsp.enable({ "ruby_lsp", "ts_ls", "elixirls", "lua_ls" })

      -- How diagnostics (errors/warnings) appear in the buffer:
      vim.diagnostic.config({
        virtual_text = true,      -- show error text inline at the end of the line
        signs = true,             -- error icons in the sign column (gutter)
        underline = true,         -- underline the offending text
        update_in_insert = false, -- don't update while typing (avoids flickering squiggles)
        severity_sort = true,     -- errors on top, hints at the bottom
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- COMPLETION — nvim-cmp
  -- ---------------------------------------------------------------------------
  -- nvim-cmp is the completion engine. Sources are separate plugins that feed
  -- it with completion candidates from different places:
  --
  --   cmp-nvim-lsp      — completions from the LSP server (methods, types, etc.)
  --   cmp-buffer        — words already in open buffers
  --   cmp-path          — file paths (great in command line mode)
  --   LuaSnip           — snippet engine (replaces snipmate)
  --   cmp_luasnip       — bridges LuaSnip into nvim-cmp
  --   friendly-snippets — large collection of VS Code-compatible snippets for
  --                       Ruby, JS, HTML, etc. (loaded by LuaSnip automatically)
  --
  -- Keymaps in the completion menu:
  --   <C-Space>  — manually trigger completion
  --   <Tab>      — select next item OR jump to next snippet placeholder
  --   <S-Tab>    — select previous item OR jump to previous snippet placeholder
  --   <CR>       — confirm the selected item
  --   <C-b>/<C-f> — scroll the docs popup up/down
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- lazy-load: only when you enter insert mode
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      -- Load VS Code-format snippets (from friendly-snippets and any others)
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        -- How to expand a snippet when confirmed from the completion menu
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),            -- scroll docs up
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),             -- scroll docs down
          ["<C-Space>"] = cmp.mapping.complete(),                 -- force-open menu
          ["<CR>"]      = cmp.mapping.confirm({ select = true }), -- confirm top item
          -- Tab: advance through completion items OR through snippet placeholders
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump() -- expand snippet or jump to next placeholder
            else
              fallback()               -- default Tab behaviour (indent)
            end
          end, { "i", "s" }),
          -- S-Tab: reverse direction
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        -- Sources listed in priority order (LSP first, then snippets, etc.)
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP completions (highest priority)
          { name = "luasnip" },  -- snippet completions
          { name = "buffer" },   -- words from open buffers
          { name = "path" },     -- filesystem paths
        }),
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- TELESCOPE — fuzzy finder
  -- ---------------------------------------------------------------------------
  -- Replaces: fzf + fzf.vim
  --
  -- telescope-fzf-native.nvim compiles a C extension that uses the same
  -- fuzzy-matching algorithm as fzf, making Telescope just as fast.
  -- build = "make" compiles it after install (requires make and a C compiler).
  --
  -- Keymaps:
  --   <C-P>        — project files (git root, like old :ProjectFiles)
  --   <Leader>fg   — live grep (ripgrep) across the project
  --   <Leader>fb   — open buffer list
  --   <Leader>fh   — search help tags
  --   <Leader>fd   — list diagnostics
  --   <Leader>fr   — recently opened files
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",         -- lazy-load: only when :Telescope is called OR a keymap fires
    dependencies = {
      "nvim-lua/plenary.nvim", -- utility library required by telescope
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      {
        "<C-P>",
        function()
          -- Try to find the git root; fall back to cwd if not in a repo
          local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
          require("telescope.builtin").find_files({
            cwd = (root and root ~= "") and root or vim.fn.getcwd(),
          })
        end,
        desc = "Project files",
      },
      { "<Leader>fg", function() require("telescope.builtin").live_grep() end,   desc = "Live grep" },
      { "<Leader>fb", function() require("telescope.builtin").buffers() end,     desc = "Buffers" },
      { "<Leader>fh", function() require("telescope.builtin").help_tags() end,   desc = "Help" },
      { "<Leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
      { "<Leader>fr", function() require("telescope.builtin").oldfiles() end,    desc = "Recent files" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "bottom_pane",  -- panel opens at the bottom
          layout_config = { height = 0.5 }, -- takes up half the screen height
          file_ignore_patterns = { "%.git/", "node_modules/" },
        },
      })
      -- Load the fzf extension for faster fuzzy matching
      telescope.load_extension("fzf")
    end,
  },

  -- ---------------------------------------------------------------------------
  -- GIT
  -- ---------------------------------------------------------------------------

  -- vim-fugitive: the classic Git integration. Still the best option for
  -- staging hunks (:Gitsigns stage_hunk), writing commit messages (:G commit),
  -- viewing diffs (:Gdiffsplit), and resolving merge conflicts (:Gvdiffsplit).
  "tpope/vim-fugitive",

  -- gitsigns: shows git change indicators (+, ~, _) in the sign column next
  -- to each modified line. Also enables hunk-level staging without leaving nvim.
  -- Keymaps (buffer-local, only when inside a git repo):
  --   ]g / [g        — jump to next/previous hunk
  --   <Leader>gp     — preview hunk diff in a float
  --   <Leader>gb     — blame the current line (shows author + commit)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "]g", gs.next_hunk, opts)
          vim.keymap.set("n", "[g", gs.prev_hunk, opts)
          vim.keymap.set("n", "<Leader>gp", gs.preview_hunk, opts)
          vim.keymap.set("n", "<Leader>gb", gs.blame_line, opts)
        end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- STATUS LINE — lualine
  -- ---------------------------------------------------------------------------
  -- Replaces: vim-airline + vim-airline-themes
  --
  -- lualine is a fast, highly configurable status line written in Lua.
  -- nvim-web-devicons provides the file-type icons in the status line.
  -- The config below mirrors the old airline behaviour:
  --   - hide the git branch section (lualine_b = {})
  --   - show only filetype in the right section
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          section_separators = "",   -- no powerline-style arrows
          component_separators = "", -- no separators between components either
        },
        sections = {
          lualine_b = {},             -- hide branch/diff/diagnostics (keep it minimal)
          lualine_x = { "filetype" }, -- only show filetype on the right side
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- WHICH-KEY — keybinding discovery
  -- ---------------------------------------------------------------------------
  -- When you press <Leader> (or any prefix) and pause, which-key shows a
  -- popup listing all available next keys and their descriptions.
  -- The desc = "..." values in our keymap definitions appear here.
  -- Great for discovering what mappings exist without reading this file.
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- load after everything else (doesn't need to be early)
    opts = {},
  },

  -- ---------------------------------------------------------------------------
  -- COMMENTING — Comment.nvim
  -- ---------------------------------------------------------------------------
  -- Replaces: NERDCommenter
  --
  -- Uses treesitter to detect the correct comment syntax for the current
  -- language, including embedded languages (e.g. JS inside an ERB template).
  --
  -- Keymaps:
  --   <Leader>cc   — comment current line / selection
  --   <Leader>uc   — uncomment current line / selection
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup({
        toggler  = { line = "<Leader>cc" },
        opleader = { line = "<Leader>c" },
        mappings = { basic = true, extra = false },
      })
      -- <Leader>uc mirrors <Leader>cc (both toggle, so uc uncomments commented lines)
      vim.keymap.set("n", "<Leader>uc", "<Leader>cc", { remap = true, silent = true, desc = "Uncomment line" })
      vim.keymap.set("x", "<Leader>uc", "<Leader>c", { remap = true, silent = true, desc = "Uncomment selection" })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- AUTO-PAIRS — closes brackets/quotes as you type
  -- ---------------------------------------------------------------------------
  -- When you type ( it automatically inserts ), and places the cursor inside.
  -- The cmp integration means if you confirm a completion that ends with (,
  -- the closing ) is handled intelligently without doubling up.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" }, -- ensure cmp is loaded before we hook into it
    config = function()
      require("nvim-autopairs").setup({})
      -- Tell nvim-cmp to call autopairs after a completion is confirmed,
      -- so function completions like foo( get a matching ) automatically
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ---------------------------------------------------------------------------
  -- INDENT GUIDES — indent-blankline
  -- ---------------------------------------------------------------------------
  -- Draws a thin │ line at each indent level so nested code is easier to scan.
  -- Especially helpful in Ruby blocks and deeply nested JS/JSON.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl", -- the module name changed in v3
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" } },
  },

  -- ---------------------------------------------------------------------------
  -- DIAGNOSTICS PANEL — trouble.nvim
  -- ---------------------------------------------------------------------------
  -- Replaces: Syntastic's location list
  --
  -- Opens a panel at the bottom listing all LSP diagnostics (errors, warnings,
  -- hints) across the project or just the current buffer. More useful than the
  -- built-in quickfix list because it's always in sync with the LSP.
  --
  -- Keymaps:
  --   <Leader>xx   — toggle project-wide diagnostics panel
  --   <Leader>xb   — toggle buffer-local diagnostics only
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<Leader>xx", "<cmd>Trouble diagnostics toggle<CR>",              desc = "Diagnostics panel" },
      { "<Leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
    },
    opts = {},
  },

  -- ---------------------------------------------------------------------------
  -- CODE OUTLINE — aerial.nvim
  -- ---------------------------------------------------------------------------
  -- Replaces: tagbar
  --
  -- Opens a sidebar listing the current file's symbols (classes, methods,
  -- functions) powered by treesitter and/or LSP. Click or press <CR> on
  -- an entry to jump there. Faster and more accurate than ctags-based tagbar.
  --
  -- Keymaps:
  --   <Leader>a   — toggle the outline sidebar
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    cmd = "AerialToggle",
    keys = { { "<Leader>a", "<cmd>AerialToggle!<CR>", desc = "Toggle code outline" } },
    opts = {},
  },

  -- ---------------------------------------------------------------------------
  -- TERMINAL — toggleterm.nvim
  -- ---------------------------------------------------------------------------
  -- Replaces: kassio/neoterm + vimlab/split-term
  --
  -- Opens a terminal in a horizontal split at the bottom. You can have multiple
  -- terminals (numbered 1, 2, 3...) and toggle them independently.
  --
  -- Keymaps:
  --   <C-T>        — toggle the terminal open/closed
  --   <Esc>        — exit terminal mode back to normal mode (defined in keymaps.lua)
  --   <Leader>c    — close all terminals
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { { "<C-T>", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle terminal" } },
    config = function()
      require("toggleterm").setup({
        size = 15,            -- height of the terminal split in rows
        direction = "horizontal",
        shell = vim.o.shell,  -- use whatever shell is set in $SHELL
        auto_scroll = true,   -- scroll to the bottom as output appears
        close_on_exit = true, -- close the terminal buffer when the shell exits
      })
      vim.keymap.set("n", "<Leader>c", ":ToggleTermToggleAll<CR>",
        { silent = true, desc = "Close all terminals" })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- TESTING — vim-test
  -- ---------------------------------------------------------------------------
  -- Same plugin as before, but now using toggleterm as the test runner backend
  -- instead of neoterm. Tests run in the terminal split below.
  --
  -- Keymaps:
  --   <Leader>t   — run the test nearest to the cursor
  --   <Leader>T   — run all tests in the current file
  --   <Leader>l   — re-run the last test
  {
    "vim-test/vim-test",
    dependencies = { "akinsho/toggleterm.nvim" },
    keys = {
      { "<Leader>t", "<cmd>TestNearest<CR>", desc = "Test nearest" },
      { "<Leader>T", "<cmd>TestFile<CR>",    desc = "Test file" },
      { "<Leader>l", "<cmd>TestLast<CR>",    desc = "Test last" },
    },
    config = function()
      vim.g["test#strategy"] = "toggleterm"                -- run tests in toggleterm
      vim.g["test#ruby#cucumber#options"] = "-r features/" -- load step definitions
    end,
  },

  -- ---------------------------------------------------------------------------
  -- FORMATTING — conform.nvim
  -- ---------------------------------------------------------------------------
  -- Replaces: ALE fixers
  --
  -- Runs a formatter on save automatically. Each formatter must be available
  -- on your PATH (or installed by mason). conform runs async so it doesn't
  -- block your workflow.
  --
  -- formatters_by_ft: map filetype → list of formatters (tried in order)
  -- lsp_fallback = true: if no external formatter is found, fall back to the
  -- LSP's built-in formatting (e.g. ruby_lsp can format Ruby files)
  --
  -- To install the formatters:
  --   npm install -g prettier
  --   gem install rubocop
  --   brew install stylua
  --   (or use :Mason to install them through mason)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- trigger before every save
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          ruby       = { "rubocop" },
          lua        = { "stylua" },
        },
        format_on_save = {
          timeout_ms = 500,    -- give the formatter 500ms before giving up
          lsp_fallback = true, -- fall back to LSP formatting if no formatter found
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- LINTING — nvim-lint
  -- ---------------------------------------------------------------------------
  -- Replaces: ALE linters + Syntastic
  --
  -- Runs linters asynchronously after you save. Linting errors appear as
  -- diagnostics (same as LSP errors) so they show up in the sign column,
  -- as virtual text, and in the Trouble panel.
  --
  -- Note: ruby_lsp already provides diagnostics for Ruby, but rubocop here
  -- catches style issues that the LSP doesn't report.
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint" },
        ruby       = { "rubocop" },
      }
      -- Run linting every time a buffer is saved
      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- SURROUND — nvim-surround
  -- ---------------------------------------------------------------------------
  -- NEW: not in the old config but very popular addition.
  --
  -- Add, change, or delete surrounding characters (quotes, brackets, tags, etc.)
  --
  -- Usage in normal mode:
  --   ysiw"   — surround the current word with double quotes
  --   yss"    — surround the entire line with double quotes
  --   cs"'    — change surrounding " to '
  --   ds"     — delete surrounding "
  --   ysiw(   — surround word with parentheses (with spaces inside)
  --   ysiw)   — surround word with parentheses (no spaces inside)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- ---------------------------------------------------------------------------
  -- LANGUAGE / FRAMEWORK PLUGINS
  -- ---------------------------------------------------------------------------

  -- vim-rails: the classic Rails plugin. Provides:
  --   :Emodel, :Econtroller, :Eview, etc. — jump between Rails files
  --   :Rails       — run Rails commands in a subshell
  --   gf           — "go to file" is Rails-aware (follows routes, partials, etc.)
  "tpope/vim-rails",

  -- vim-eunuch: shell commands as Vim commands (:Rename, :Move, :Delete, :Chmod)
  -- Much more convenient than shelling out for file operations.
  "tpope/vim-eunuch",

  -- vim-slim: syntax highlighting for Slim templates (HTML templating language)
  -- Treesitter doesn't have a Slim parser yet so we still need this.
  "slim-template/vim-slim",

  -- vim-gh-line: open the current file/line in GitHub.
  -- <Leader>gh opens the current line in the browser.
  "ruanyl/vim-gh-line",

}, {
  -- lazy.nvim manager options
  ui = { border = "rounded" },                  -- rounded border in the :Lazy UI popup
  checker = { enabled = true, notify = false }, -- check for plugin updates silently
  -- run :Lazy update when you want to apply them
})
