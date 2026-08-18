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

            -- Blend `fg` toward `bg`. Used to keep the separator chevrons as
            -- quiet grey structure instead of adopting a segment's accent
            -- colour. 0.0 = fg unchanged, 1.0 = invisible against bg.
            local MUTE = 0.62
            local function mute(fg, bg)
                if fg == nil or bg == nil then return fg end
                local function ch(v, shift)
                    return math.floor(v / shift) % 256
                end
                local r = ch(fg, 65536) + (ch(bg, 65536) - ch(fg, 65536)) * MUTE
                local g = ch(fg, 256)   + (ch(bg, 256)   - ch(fg, 256))   * MUTE
                local b = ch(fg, 1)     + (ch(bg, 1)     - ch(fg, 1))     * MUTE
                return math.floor(r) * 65536 + math.floor(g) * 256 + math.floor(b)
            end

            -- airline's "silver" theme, ported.
            --
            -- Taken from vim-airline-themes/autoload/airline/themes/silver.vim
            -- (the g:airline_theme this config used to set). Worth knowing:
            -- silver is a FLAT theme. Its three section colours N1/N2/N3 are
            -- byte-identical -- #414141 on #e1e1e1 -- so it never had per-
            -- segment backgrounds. Mode is carried purely in the foreground,
            -- which is why solid powerline wedges never looked right here:
            -- there are no two backgrounds for an arrow to transition between.
            --
            -- Fixed palette, deliberately not derived from the colorscheme.
            -- airline applied silver regardless of solarized/gruvbox or the
            -- light/dark switch in dot_nvimrc, so this does too.
            -- The mode is a foreground colour only, exactly as silver defines
            -- it -- one background across the entire bar. That means sep()
            -- never sees two different backgrounds, so every separator is a
            -- thin chevron; solid wedges are impossible on a flat bar by
            -- construction, not by choice.
            local SILVER = {
                bg          = 0xe1e1e1,
                fg          = 0x414141,
                modified    = 0xe25000, -- airline_c when the buffer is modified
                inactive_fg = 0xa1a1a1,
                inactive_bg = 0xdddddd,
                mode = {
                    Normal  = 0x414141, -- grey
                    Insert  = 0x0d935c, -- green
                    Visual  = 0x0000b3, -- blue
                    Replace = 0xb30000, -- red
                    Command = 0x414141,
                    Other   = 0x414141,
                },
            }

            -- The mode colour is the WHOLE bar's background, not just the mode
            -- block's, so every segment group needs a per-mode variant. Naming:
            -- SilverBar<Mode> for normal text, ...Mode for the mode label,
            -- ...Dim for separators, ...Mod for a dirty buffer.
            local TEXT = 0xe1e1e1
            local function apply_silver_theme()
                for m, bg in pairs(SILVER.mode) do
                    vim.api.nvim_set_hl(0, 'SilverBar' .. m,     { fg = TEXT, bg = bg })
                    vim.api.nvim_set_hl(0, 'SilverBarMode' .. m, { fg = TEXT, bg = bg, bold = true })
                    -- Separators sit between segments that now share a
                    -- background, so they are always thin. Blend the text
                    -- colour toward the bar so the divider stays quiet.
                    vim.api.nvim_set_hl(0, 'SilverBarDim' .. m,  { fg = mute(TEXT, bg), bg = bg })
                    -- silver's dirty-buffer accent, kept on every bar colour.
                    vim.api.nvim_set_hl(0, 'SilverBarMod' .. m,
                        { fg = SILVER.modified, bg = bg, bold = true })
                end
                -- Inactive windows: same family, dimmed, so splits do not
                -- flip to a different bar colour entirely.
                vim.api.nvim_set_hl(0, 'MiniStatuslineInactive',
                    { fg = SILVER.inactive_fg, bg = SILVER.mode.Normal })
                vim.api.nvim_set_hl(0, 'StatusLine',
                    { fg = TEXT, bg = SILVER.mode.Normal })
                vim.api.nvim_set_hl(0, 'StatusLineNC',
                    { fg = SILVER.inactive_fg, bg = SILVER.mode.Normal })
            end

            vim.api.nvim_create_autocmd('ColorScheme', {
                group = vim.api.nvim_create_augroup('statusline_silver', { clear = true }),
                callback = apply_silver_theme,
            })
            -- dot_nvimrc sets the colorscheme after this file is sourced, so
            -- also run once everything has settled.
            vim.api.nvim_create_autocmd('VimEnter', { callback = apply_silver_theme })

            -- No sep() helper any more. It existed to pick solid vs thin by
            -- comparing two segment backgrounds; with one background across
            -- the whole bar there is nothing to compare, so separators are
            -- always the thin glyph in SilverBarDim<Mode>.

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

                        -- Every group is per-mode, so the whole bar shares one
                        -- background. section_mode returns e.g.
                        -- "MiniStatuslineModeInsert"; take the suffix.
                        local m = mode_hl:gsub('^MiniStatuslineMode', '')
                        if SILVER.mode[m] == nil then m = 'Other' end
                        local BAR  = 'SilverBar' .. m
                        local DIM  = 'SilverBarDim' .. m
                        local MODE = 'SilverBarMode' .. m
                        -- silver tints the filename while the buffer is dirty.
                        local NAME = vim.bo.modified and ('SilverBarMod' .. m) or BAR

                        local thinL = '%#' .. DIM .. '#' .. LEFT_THIN
                        local thinR = '%#' .. DIM .. '#' .. RIGHT_THIN

                        -- Left half: mode > devinfo > filename, skipping any
                        -- empty segment so no stray separators are left behind.
                        local out = { '%#' .. MODE .. '# ' .. mode .. ' ' }
                        if devinfo ~= '' then
                            table.insert(out, thinL)
                            table.insert(out, '%#' .. BAR .. '# ' .. devinfo .. ' ')
                        end
                        table.insert(out, thinL)
                        table.insert(out, '%#' .. NAME .. '# ' .. filename .. ' ')

                        -- Filename group stretches to fill the middle.
                        table.insert(out, '%=')

                        -- Right half mirrors it, chevrons pointing back inwards.
                        if right ~= '' then
                            table.insert(out, thinR)
                            table.insert(out, '%#' .. BAR .. '# ' .. right .. ' ')
                        end
                        table.insert(out, thinR)
                        table.insert(out, '%#' .. MODE .. '# ' .. location .. ' ')

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
