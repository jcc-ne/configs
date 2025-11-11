-- Plugins that are only loaded when not in VSCode
return {
    {'jcc-ne/vim-template', branch = 'dev'},
    {'nvim-treesitter/nvim-treesitter-textobjects', ft = 'python'},
    {'astral-sh/ruff', ft='python'},
    {'python-mode/python-mode', 
     ft = {'python', 'py', 'ipy'},
     init = function()
        -- Create the python augroup
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "python",
            group = "python_group",
            callback = function()
                vim.cmd('filetype plugin indent on')
                vim.cmd('syntax on')
                
                -- Python-mode settings
                vim.g.pymode_folding = 1
                vim.g.pymode_folding_regex = '^\\s*\\%(class\\|def\\|async\\s\\+def\\|if\\|for\\)'
                vim.g.pymode_rope = 0
                vim.g.pymode_doc = 1
                vim.g.pymode_doc_key = 'K'
                vim.g.pymode_run = 1
                vim.g.pymode_run_key = 'R'
                vim.g.pymode_lint = 0
                -- vim.g.pymode_lint_checker = "pyflakes, pep8"
                -- vim.g.pymode_lint_ignore = {"E501", "E712"}
                -- vim.g.pymode_lint_write = 1
                vim.g.pymode_syntax = 1
                vim.g.pymode_syntax_all = 1
                vim.g.pymode_syntax_indent_errors = vim.g.pymode_syntax_all
                vim.g.pymode_syntax_space_errors = vim.g.pymode_syntax_all
                vim.g.pymode_breakpoint = 0
                vim.g.pymode_run = 0
            end
        })
     end
    },
    {'Konfekt/FastFold', ft = 'python'},
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
    {'deoplete-plugins/deoplete-jedi', 
     ft = 'python',
     init = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "python",
            group = "python_group",
            callback = function()
                -- Jedi settings
                vim.g.jedi_goto_assignments_command = "<leader>g"
                vim.g.jedi_goto_definitions_command = "<leader>d"
                vim.g.jedi_documentation_command = "K"
                vim.g.jedi_show_call_signatures = "1"
                vim.g.jedi_goto_stubs_command = "<leader><leader>s"
                vim.g.jedi_popup_on_dot = 0
                vim.g.jedi_completions_enabled = 0  -- use deoplete-jedi instead
            end
        })
     end
    },
    {'Shougo/deoplete.nvim',
     ft = 'python',
     config = function()
        -- Deoplete global settings
        vim.g['deoplete#enable_at_startup'] = 1
        vim.g['deoplete#sources#jedi#ignore_errors'] = true

        -- Function to set up keymaps for a Python buffer
        local function setup_deoplete_keymaps(bufnr)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', ':call deoplete#disable()<CR>',
                {noremap = true, silent = true})
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>E', ':call deoplete#enable()<CR>',
                {noremap = true, silent = true})
        end

        -- Set keymaps for current buffer (the one that triggered the load)
        setup_deoplete_keymaps(0)

        -- Create augroup to prevent duplicate autocmds on reload
        local deoplete_group = vim.api.nvim_create_augroup("deoplete_keymaps", { clear = true })

        -- Set up autocmd for future Python buffers
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "python",
            group = deoplete_group,
            callback = function(ev)
                setup_deoplete_keymaps(ev.buf)
            end
        })
     end
    },
    {
        'vim-airline/vim-airline',
        init = function()
            vim.g.airline_powerline_fonts = 1
            vim.g["airline#extensions#hunks#enabled"] = 1
            -- vim.g.airline_theme = 'base16'
            -- vim.g.airline_theme = 'deus'
            -- vim.g.airline_theme = 'monochrome'
            vim.g.airline_theme = 'silver'
            -- vim.g.airline_theme = 'nord_minimal'
        end,
    },
    'vim-airline/vim-airline-themes',
    'airblade/vim-gitgutter',
    'epeli/slimux',
    'whiteinge/diffconflicts',
    {'lvht/tagbar-markdown', ft = 'markdown'},
    'mattn/calendar-vim',
    'nvim-telescope/telescope.nvim',
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',  -- Load when entering insert mode
      dependencies = {
        'hrsh7th/cmp-nvim-lsp',     -- LSP completion
        'hrsh7th/cmp-buffer',       -- Buffer completion
        'hrsh7th/cmp-path',         -- Path completion
        'quangnguyen30192/cmp-nvim-ultisnips',  -- UltiSnips completion
      },
      config = function()
        local cmp = require('cmp')

        cmp.setup({
          ---- Snippet engine configuration
          --snippet = {
          --  expand = function(args)
          --    vim.fn["UltiSnips#Anon"](args.body)
          --  end,
          --},

          -- Completion sources (order determines priority)
          sources = cmp.config.sources({
            { name = 'nvim_lsp', priority = 1000 },
            { name = 'ultisnips', priority = 900 },
            { name = 'buffer', priority = 500, keyword_length = 3 },
            { name = 'path', priority = 300 },
          }),

          
          -- Formatting (adds icons and source names)
          formatting = {
            format = function(entry, vim_item)
              -- Kind icons
              -- vim_item.kind = string.format('%s %s', vim_item.kind, vim_item.kind)
              -- Source names
              vim_item.menu = ({
                nvim_lsp = "∘lsp",
                ultisnips = "∘snip",
                buffer = "∘buf",
                path = "∘path",
              })[entry.source.name]
              return vim_item
            end
          },
        })
      end
    },
  
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
  
    {
      'VonHeikemen/lsp-zero.nvim',
      dependencies = {
        'neovim/nvim-lspconfig',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'L3MON4D3/LuaSnip',
      },
    },
  
    -- DAP related plugins
    'mfussenegger/nvim-dap',
    'nvim-telescope/telescope-dap.nvim',
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
    },
    {'mfussenegger/nvim-dap-python',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    ft = {'python', 'py', 'ipy'}, },
    { dir = '~/.fzf'},
    {'junegunn/fzf.vim',
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


  } 
