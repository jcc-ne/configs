-- Plugins that are only loaded when not in VSCode
return {
    {'jcc-ne/vim-template', branch = 'dev'},
    {'python-mode/python-mode', 
     ft = 'python',
     init = function()
        -- Create the python augroup
        vim.api.nvim_create_augroup("python_group", { clear = true })
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
                vim.g.pymode_lint = 1
                vim.g.pymode_lint_checker = "pyflakes, pep8"
                vim.g.pymode_lint_ignore = {"E501", "E712"}
                vim.g.pymode_lint_write = 1
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
    {'vimwiki/vimwiki', ft = 'markdown'},
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
     init = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "python",
            group = "python_group",
            callback = function()
                -- Deoplete settings
                vim.g['deoplete#enable_at_startup'] = 1
                vim.g['deoplete#sources#jedi#ignore_errors'] = true
                
                -- Add deoplete keymaps
                vim.api.nvim_set_keymap('n', '<leader>D', ':call deoplete#disable()<CR>', 
                    {noremap = true, silent = true})
                vim.api.nvim_set_keymap('n', '<leader>E', ':call deoplete#enable()<CR>', 
                    {noremap = true, silent = true})
            end
        })
     end
    },
    {
        'vim-airline/vim-airline',
        init = function()
            vim.g.airline_powerline_fonts = 1
            vim.g["airline#extensions#hunks#enabled"] = 0
            vim.g.airline_theme = 'powerlineish'
        end,
    },
    'vim-airline/vim-airline-themes',
    'airblade/vim-gitgutter',
    'epeli/slimux',
    'github/copilot.vim',
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
      dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-vsnip',
      },
    },
  
    {
      'scalameta/nvim-metals',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'mfussenegger/nvim-dap',
      },
      ft = {'scala', 'sbt', 'java', 'groovy'},
    },
  
    {
      'jose-elias-alvarez/null-ls.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
  
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
    ft = {'python', 'py', 'ipy'},
    }
  } 

-- Python filetype settings
vim.api.nvim_create_augroup("python_group", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.cmd('filetype plugin indent on')
        vim.cmd('syntax on')
    end,
    group = "python_group"
})

-- Add any additional Lua-based Python configurations here if needed 
