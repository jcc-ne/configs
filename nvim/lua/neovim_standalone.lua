-- Plugins that are only loaded when not in VSCode
return {
    {'jcc-ne/vim-template', branch = 'dev'},
    {'python-mode/python-mode', ft = 'python'},
    {'Konfekt/FastFold', ft = 'python'},
    {'vimwiki/vimwiki', ft = 'markdown'},
    {'deoplete-plugins/deoplete-jedi', ft = 'python'},
    {'Shougo/deoplete.nvim', ft = 'python'},
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
