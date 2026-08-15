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
            require('mini.statusline').setup({ use_icons = true })

            -- ---- diff signs (was vim-gitgutter) ------------------------
            require('mini.diff').setup({
                view = { style = 'sign', signs = { add = '+', change = '~', delete = '-' } },
            })
            -- gitgutter's <F3> was GitGutterBufferToggle. mini.diff's overlay
            -- is the more useful toggle: it shows the actual reference text
            -- inline rather than just the sign column.
            vim.keymap.set('n', '<F3>', function() require('mini.diff').toggle_overlay(0) end,
                { desc = 'Toggle diff overlay' })

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
  {'SirVer/ultisnips'},
  {'honza/vim-snippets'},
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
