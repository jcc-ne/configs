-- Plugins that are only loaded when not in VSCode
return {
    {'jcc-ne/vim-template', branch = 'dev'},
    {'christoomey/vim-tmux-navigator'},
    {'astral-sh/ruff', ft='python'},
    -- python-mode and FastFold removed: linting is handled by ruff + pylsp
    -- (pymode_lint was already 0), and folding now comes from treesitter's
    -- incremental foldexpr, which is what FastFold existed to work around.
    {'vimwiki/vimwiki', cmd = 'VimwikiMakeDiaryNote',
      init = function()
        -- Vimwiki configuration
        vim.g.vimwiki_global_ext = 0
        vim.g.vimwiki_list = {
          {
            path = '~/vimwiki/text/work',
            path_html = '~/vimwiki/html/work',
            syntax = 'markdown',
            ext = '.md',
            auto_toc = 1,
            auto_tags = 1,
            index = 'index'
          },
          {
            path = '~/.task/wiki/',
            syntax = 'markdown',
            ext = '.md',
            auto_toc = 1,
            auto_tags = 1,
            index = 'index'
          },
          {
            path = '~/vimwiki/text/fin',
            path_html = '~/vimwiki/html/fin',
            syntax = 'markdown',
            ext = '.md',
            auto_toc = 1,
            auto_tags = 1,
            index = 'index'
          },
          {
            path = '~/vimwiki/text/general',
            path_html = '~/vimwiki/html/general',
            syntax = 'markdown',
            ext = '.md',
            auto_toc = 1,
            index = 'index',
            template_path = '~/vimwiki/templates/',
            template_default = 'def_template',
            template_ext = '.html'
          },
          {
            path = '~/vimwiki/text/arc_2015',
            ext = '.wiki',
            auto_toc = 1
          }
        }
     end
    },
    -- deoplete.nvim + deoplete-jedi removed: unmaintained, required the
    -- python3 remote-plugin host, and raced nvim-cmp and pylsp on the same
    -- buffers. Completion is now Neovim's built-in (see neovim_settings.lua).
    -- mini.nvim replaces vim-airline + vim-airline-themes (statusline),
    -- vim-gitgutter (diff), and which-key.nvim (clue). One repo, four modules.
    {
        'echasnovski/mini.nvim',
        version = false,
        config = function()
            -- ---- statusline (was vim-airline) --------------------------
            -- Shows branch + diff summary (fed by mini.diff below),
            -- diagnostics, filename, fileinfo and location, like airline did.
            --
            -- Powerline styling: mini.statusline has no separator option, so
            -- the arrows are built here. Each arrow is its own highlight group
            -- whose fg is the previous segment's bg and whose bg is the next
            -- one's, which is what makes the transition look solid. The mode
            -- group changes colour per mode, so the separator groups are keyed
            -- by mode and memoized, not rebuilt on every redraw.
            local statusline = require('mini.statusline')

            -- Powerline separators, written as explicit UTF-8 byte escapes:
            -- these are Private Use Area codepoints and do not survive being
            -- copied through most tooling as literal characters.
            --   U+E0B0 EE 82 B0 solid right   U+E0B1 EE 82 B1 thin right
            --   U+E0B2 EE 82 B2 solid left    U+E0B3 EE 82 B3 thin left
            -- Same glyphs airline drew with powerline_fonts=1, so the patched
            -- font already in use covers them.
            local LEFT       = '\238\130\176'
            local LEFT_THIN  = '\238\130\177'
            local RIGHT      = '\238\130\178'
            local RIGHT_THIN = '\238\130\179'

            -- fg/bg of a highlight group, following links.
            local function hl_of(name)
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                if not ok or not hl then return {} end
                return hl
            end

            -- Readable text colour for a given background.
            local function contrast_on(rgb)
                local r = math.floor(rgb / 65536) % 256
                local g = math.floor(rgb / 256) % 256
                local b = rgb % 256
                -- Rec. 601 luma
                return (0.299 * r + 0.587 * g + 0.114 * b) > 140 and 0x000000 or 0xffffff
            end

            -- Give every mode a solid coloured block.
            --
            -- Most colorschemes (solarized8 included) define only
            -- MiniStatuslineModeNormal with a real background and tint just
            -- the foreground for Insert/Visual/Replace/Command, so there is
            -- nothing for a powerline arrow to separate. Where a mode's
            -- background is missing or equal to the statusline's, promote its
            -- foreground to the background and pick a readable fg. Runs on
            -- ColorScheme so it survives the light/dark switch in dot_nvimrc
            -- and the per-host gruvbox/solarized choice.
            local function ensure_mode_colors()
                local sl_bg = hl_of('StatusLine').bg
                for _, m in ipairs({ 'Normal', 'Insert', 'Visual', 'Replace', 'Command', 'Other' }) do
                    local name = 'MiniStatuslineMode' .. m
                    local h = hl_of(name)
                    if h.bg == nil or h.bg == sl_bg then
                        local base = h.fg or sl_bg
                        if base then
                            vim.api.nvim_set_hl(0, name,
                                { fg = contrast_on(base), bg = base, bold = true })
                        end
                    end
                end
            end

            vim.api.nvim_create_autocmd('ColorScheme', {
                group = vim.api.nvim_create_augroup('statusline_mode_colors', { clear = true }),
                callback = ensure_mode_colors,
            })
            -- dot_nvimrc sets the colorscheme after this file is sourced, so
            -- also run once everything has settled. Declared before sep_cache
            -- exists, hence the forward-declared invalidator.
            local invalidate_sep_cache
            vim.api.nvim_create_autocmd('VimEnter', {
                callback = function()
                    ensure_mode_colors()
                    invalidate_sep_cache()
                end,
            })

            -- Define a separator group between two segments and return the
            -- statusline escape that activates it.
            --
            -- Colorschemes often give adjacent segments the SAME background
            -- (solarized makes Devinfo/Filename/Fileinfo all identical). A
            -- solid arrow there would be fg == bg, i.e. invisible, so fall
            -- back to a thin separator in the segment's own foreground --
            -- which is exactly what airline did.
            --
            -- The statusline re-renders on every cursor move, so the result is
            -- memoized: the colours only change when the colorscheme does, and
            -- the mode is already part of the cache key (the mode highlight
            -- group is named per mode).
            --
            -- Measured: the four separators cost 11.6us/redraw uncached, so
            -- this is a small win. The real cost in this statusline is
            -- MiniStatusline.section_fileinfo() at ~340us of a ~370us redraw
            -- (its icon/filetype lookup) -- that is upstream, not from here.
            local sep_cache = {}
            invalidate_sep_cache = function() sep_cache = {} end
            vim.api.nvim_create_autocmd('ColorScheme', {
                group = vim.api.nvim_create_augroup('statusline_powerline', { clear = true }),
                callback = invalidate_sep_cache,
            })

            local function sep(from, to, dir)
                local key = dir .. from .. to
                local cached = sep_cache[key]
                if cached then return cached end

                local from_bg, to_bg = hl_of(from).bg, hl_of(to).bg
                local name = 'MiniStatuslinePL' .. dir .. from .. to
                local glyph
                if from_bg == to_bg then
                    glyph = dir == 'L' and LEFT_THIN or RIGHT_THIN
                    vim.api.nvim_set_hl(0, name, { fg = hl_of(from).fg, bg = from_bg })
                else
                    glyph = dir == 'L' and LEFT or RIGHT
                    vim.api.nvim_set_hl(0, name, {
                        fg = dir == 'L' and from_bg or to_bg,
                        bg = dir == 'L' and to_bg or from_bg,
                    })
                end
                local result = '%#' .. name .. '#' .. glyph
                sep_cache[key] = result
                return result
            end

            -- Must come before statusline.setup(). section_fileinfo() calls
            -- H.ensure_get_icon() on every redraw; with no _G.MiniIcons it
            -- falls through to pcall(require, 'nvim-web-devicons'), which is
            -- not installed. Failed requires are not cached in package.loaded,
            -- so that re-searched the whole package.path on every cursor move
            -- -- 381us of a ~450us redraw. Setting mini.icons up removes it.
            require('mini.icons').setup()
            -- Other plugins (diffview) look for nvim-web-devicons by name.
            MiniIcons.mock_nvim_web_devicons()

            statusline.setup({
                use_icons = true,
                content = {
                    active = function()
                        local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
                        local git         = statusline.section_git({ trunc_width = 40 })
                        local diff        = statusline.section_diff({ trunc_width = 75 })
                        local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
                        local lsp         = statusline.section_lsp({ trunc_width = 75 })
                        local filename    = statusline.section_filename({ trunc_width = 140 })
                        local fileinfo    = statusline.section_fileinfo({ trunc_width = 120 })
                        local location    = statusline.section_location({ trunc_width = 75 })
                        local search      = statusline.section_searchcount({ trunc_width = 75 })

                        local devinfo = table.concat(
                            vim.tbl_filter(function(s) return s ~= '' and s ~= nil end,
                                { git, diff, diagnostics, lsp }), ' ')
                        local right = table.concat(
                            vim.tbl_filter(function(s) return s ~= '' and s ~= nil end,
                                { search, fileinfo }), ' ')

                        -- Left half: mode > devinfo > filename, skipping any
                        -- empty segment so no stray arrows are left behind.
                        local left_groups = { { hl = mode_hl, text = mode } }
                        if devinfo ~= '' then
                            table.insert(left_groups, { hl = 'MiniStatuslineDevinfo', text = devinfo })
                        end
                        table.insert(left_groups, { hl = 'MiniStatuslineFilename', text = filename })

                        local out = {}
                        for i, g in ipairs(left_groups) do
                            table.insert(out, '%#' .. g.hl .. '# ' .. g.text .. ' ')
                            local nxt = left_groups[i + 1]
                            if nxt then table.insert(out, sep(g.hl, nxt.hl, 'L')) end
                        end
                        -- Filename group stretches to fill the middle.
                        table.insert(out, '%=')

                        -- Right half mirrors it, arrows pointing back inwards.
                        local right_groups = {}
                        if right ~= '' then
                            table.insert(right_groups, { hl = 'MiniStatuslineFileinfo', text = right })
                        end
                        table.insert(right_groups, { hl = mode_hl, text = location })

                        local prev = 'MiniStatuslineFilename'
                        for _, g in ipairs(right_groups) do
                            table.insert(out, sep(prev, g.hl, 'R'))
                            table.insert(out, '%#' .. g.hl .. '# ' .. g.text .. ' ')
                            prev = g.hl
                        end

                        return table.concat(out)
                    end,
                },
            })

            -- ---- diff signs (was vim-gitgutter) ------------------------
            require('mini.diff').setup({
                view = { style = 'sign', signs = { add = '+', change = '~', delete = '-' } },
            })
            -- gitgutter's <F3> was GitGutterBufferToggle. mini.diff's overlay
            -- is the more useful toggle: it shows the actual reference text
            -- inline rather than just the sign column.
            vim.keymap.set('n', '<F3>', function() require('mini.diff').toggle_overlay(0) end,
                { desc = 'Toggle diff overlay' })

            -- ---- snippets (was UltiSnips + vim-snippets) ---------------
            -- Your snippets live in nvim/snippets/*.json (converted from
            -- UltiSnips_local); friendly-snippets supplies the general
            -- library that honza/vim-snippets used to.
            local snippets = require('mini.snippets')
            snippets.setup({
                snippets = {
                    snippets.gen_loader.from_file(
                        vim.fn.stdpath('config') .. '/snippets/global.json'),
                    snippets.gen_loader.from_lang(),
                },
                -- UltiSnips triggers kept: <c-K> expand, <c-b>/<c-z> jump.
                mappings = {
                    expand = '<C-k>',
                    jump_next = '<C-b>',
                    jump_prev = '<C-z>',
                    stop = '<C-c>',
                },
            })

            -- ---- key hints (was which-key.nvim) ------------------------
            local clue = require('mini.clue')
            clue.setup({
                triggers = {
                    { mode = 'n', keys = '<Leader>' },
                    { mode = 'x', keys = '<Leader>' },
                    { mode = 'n', keys = 'g' },
                    { mode = 'x', keys = 'g' },
                    { mode = 'n', keys = 'z' },
                    { mode = 'x', keys = 'z' },
                    { mode = 'n', keys = '[' },
                    { mode = 'n', keys = ']' },
                    { mode = 'n', keys = '"' },
                    { mode = 'x', keys = '"' },
                    { mode = 'i', keys = '<C-r>' },
                    { mode = 'n', keys = '<C-w>' },
                },
                clues = {
                    clue.gen_clues.builtin_completion(),
                    clue.gen_clues.g(),
                    clue.gen_clues.marks(),
                    clue.gen_clues.registers(),
                    clue.gen_clues.windows(),
                    clue.gen_clues.z(),
                    { mode = 'n', keys = '<Leader>a', desc = '+claudecode' },
                    { mode = 'n', keys = '<Leader>d', desc = '+debug (dap)' },
                    { mode = 'n', keys = '<Leader>x', desc = '+diagnostics qflist' },
                    { mode = 'n', keys = '<Leader>w', desc = '+vimwiki' },
                },
                window = { delay = 300 },
            })
        end,
    },
    'epeli/slimux',
    'whiteinge/diffconflicts',
    {'majutsushi/tagbar', cmd = 'TagbarToggle'},
    {'lvht/tagbar-markdown', ft = 'markdown'},
    'mattn/calendar-vim',
    -- telescope.nvim + telescope-dap removed: fzf.vim is the finder in use, and
    -- the only real consumer was the DAP pickers in dbg/python.lua, which now
    -- use nvim-dap's own dap.ui.widgets.
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    -- nvim-cmp + cmp-nvim-lsp/cmp-buffer/cmp-path/cmp-nvim-ultisnips removed:
    -- Neovim 0.12 ships autotriggered completion via the 'autocomplete' option
    -- and vim.lsp.completion. Configured in neovim_settings.lua.
    -- which-key.nvim removed -- replaced by mini.clue above.
    {
      'scalameta/nvim-metals',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'mfussenegger/nvim-dap',
      },
      ft = {'scala', 'sbt', 'java', 'groovy'},
    },
  
    -- {
    --   'jose-elias-alvarez/null-ls.nvim',
    --   dependencies = { 'nvim-lua/plenary.nvim' },
    -- },
  
    -- lsp-zero.nvim and LuaSnip removed: servers are configured directly with
    -- vim.lsp.config/vim.lsp.enable in neovim_settings.lua, and nothing
    -- referenced LuaSnip. nvim-lspconfig stays -- it supplies the cmd and
    -- root_markers for ruff/pylsp/gopls that those calls merge on top of.
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- DAP related plugins
    'mfussenegger/nvim-dap',
    {
    -- On the `main` branch nvim-treesitter is just a parser installer, so the
    -- old rtp-reordering hack against 0.12's bundled queries is unnecessary.
    -- Highlighting stays off (as before); the parsers are here for foldexpr.
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({ 'python' })
    end,
  },
  {
      'mfussenegger/nvim-dap-python',
      dependencies = {
          'nvim-lua/plenary.nvim',
      },
      ft = {'python', 'py', 'ipy'}, 
  },
  {
      dir = '~/.fzf',
      build = function()
        -- To build: Run :Lazy build .fzf
        -- Check if fzf is already installed
        local fzf_path = vim.fn.expand('~/.fzf')
        local fzf_bin = fzf_path .. '/bin/fzf'

        if vim.fn.isdirectory(fzf_path) == 0 or vim.fn.executable(fzf_bin) == 0 then
          print("FZF not found, installing...")
          vim.fn.system('git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf')
          vim.fn.system('~/.fzf/install --all --no-bash --no-fish')
        else
          print("FZF already installed")
        end
      end
  },
  {
      'junegunn/fzf.vim',
      cmd = { 'FZF', 'FzFiles', 'FzGFiles', 'FzHistory', 'FzBuffers', 'FzRg', 'FzLines', 'FzBLines' },
      init = function()
          -- FZF mappings
          vim.g.fzf_command_prefix = 'Fz'
          vim.keymap.set('n', '<leader><leader>f', ':FzFiles<CR>')
          vim.keymap.set('n', '<leader>f', ':FzGFiles<CR>')
          vim.keymap.set('n', '<leader>h', ':FzHistory<CR>')
          vim.keymap.set('n', '<leader>b', ':FzBuffers<CR>')
          vim.keymap.set('n', '<leader>r', ':FzRg<CR>')
          vim.keymap.set('n', '<leader>l', ':FzLines<CR>')
          vim.keymap.set('n', '<leader><leader>l', ':FzBLines<CR>')

          -- Parent directory navigation with FZF
          vim.keymap.set('n', '<leader>2', ':FZF -m ../<CR>')
          vim.keymap.set('n', '<leader>3', ':FZF -m ../../<CR>')
          vim.keymap.set('n', '<leader>4', ':FZF -m ../../../<CR>')
          vim.keymap.set('n', '<leader>5', ':FZF -m ../../../../<CR>')

      end
  },
  {'sindrets/diffview.nvim'},
  -- UltiSnips + honza/vim-snippets removed. UltiSnips needed the python3
  -- remote host; mini.snippets is pure Lua. friendly-snippets is the
  -- LSP-format equivalent of honza's library (data only, no code).
  {'rafamadriz/friendly-snippets'},
  {
      "coder/claudecode.nvim",
      cmd = {'ClaudeCode', 'ClaudeCodeFocus', 'ClaudeCodeSend'},
      dependencies = { "folke/snacks.nvim" },
      opts = {
          terminal_cmd = "claude",
      },
      config = true,
      keys = {
          -- Your keymaps here
          { "<leader>a", nil, desc = "AI/Claude Code" },
          { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
          { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
          { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
          { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
          { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
          { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
          { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
          {
              "<leader>as",
              "<cmd>ClaudeCodeTreeAdd<cr>",
              desc = "Add file",
              ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
          },
          -- Diff management
          { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
          { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      },
  },
  { dir = '~/.vim/bundle/myBundle' },

  } 
