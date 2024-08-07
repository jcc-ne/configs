#! /usr/bin/env lua
--
-- plugins.lua
-- Copyright (C) 2022 janine <janine@Janine-MBP>
--
-- Distributed under terms of the GNU GPLv3 license.
--


-------------------------------------------------------------------------------
-- These are example settings to use with nvim-metals and the nvim built-in
-- LSP. Be sure to thoroughly read the `:help nvim-metals` docs to get an
-- idea of what everything does. Again, these are meant to serve as an example,
-- if you just copy pasta them, then should work,  but hopefully after time
-- goes on you'll cater them to your own liking especially since some of the stuff
-- in here is just an example, not what you probably want your setup to be.
--
-- Unfamiliar with Lua and Neovim?
--  - Check out https://github.com/nanotee/nvim-lua-guide
--
-- The below configuration also makes use of the following plugins besides
-- nvim-metals, and therefore is a bit opinionated:
--
-- - https://github.com/hrsh7th/nvim-cmp
--   - hrsh7th/cmp-nvim-lsp for lsp completion sources
--   - hrsh7th/cmp-vsnip for snippet sources
--   - hrsh7th/vim-vsnip for snippet sources
--
-- - https://github.com/wbthomason/packer.nvim for package management
-- git clone --depth 1 https://github.com/wbthomason/packer.nvim\\n ~/.local/share/nvim/site/pack/packer/start/packer.nvim
-- :PackerCompile and :PackerInstall
-- - https://github.com/mfussenegger/nvim-dap (for debugging)
-------------------------------------------------------------------------------
local api = vim.api
local cmd = vim.cmd

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

----------------------------------
-- PLUGINS -----------------------
----------------------------------
cmd([[packadd packer.nvim]])
require("packer").startup(function(use)
  use({ "wbthomason/packer.nvim", opt = true })

  use({
    "hrsh7th/nvim-cmp",
    requires = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-vsnip" },
      -- { "hrsh7th/vim-vsnip" },
    },
  })
  use({
    "scalameta/nvim-metals",
    requires = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
  })

  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
  })

  use {
      'VonHeikemen/lsp-zero.nvim',
      requires = {
          -- LSP Support
          {'neovim/nvim-lspconfig'},
          {'williamboman/mason.nvim'},
          {'williamboman/mason-lspconfig.nvim'},

  --         -- Autocompletion
  --         {'hrsh7th/nvim-cmp'},
  --         {'hrsh7th/cmp-buffer'},
  --         {'hrsh7th/cmp-path'},
  --         -- {'saadparwaiz1/cmp_luasnip'},
  --         {'hrsh7th/cmp-nvim-lsp'},
  --         {'hrsh7th/cmp-nvim-lua'},

  --         -- Snippets
             {'L3MON4D3/LuaSnip'},
  --         -- {'rafamadriz/friendly-snippets'},
      }
  }
  -- DAP
  use { 'mfussenegger/nvim-dap' }
  use { 'nvim-telescope/telescope-dap.nvim' }
  use { 'nvim-treesitter/nvim-treesitter' }
  --  if seeing helper error > :TSInstall vimdoc
  use { 'mfussenegger/nvim-dap-python' } -- Python

  -- use({
  -- 'jcc-ne/chatgpt.nvim', branch = "dev",
  -- run = 'pip3 install -r requirements.txt'
  -- })
end)

----------------------------------
-- OPTIONS -----------------------
----------------------------------
-- global
vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }

local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
    })
end

-- vim.opt_global.shortmess:remove("F"):append("c")

-- LSP mappings
map("n", "<space>h", "<cmd>lua vim.diagnostic.hide()<CR>")
map("n", "<space>hh", "<cmd>lua vim.diagnostic.disable()<CR>")
map("n", "<space>s", "<cmd>lua vim.diagnostic.show()<CR>")
map("n", "<space>ss", "<cmd>lua vim.diagnostic.enable()<CR>")
map("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>")
map("n", "gD", "<cmd>lua vim.lsp.buf.definition()<CR>")
map("n", ",g", "<cmd>lua vim.lsp.buf.definition()<CR>")
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
map("n", "gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
map("n", "gws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>")
map("n", "<leader>cl", [[<cmd>lua vim.lsp.codelens.run()<CR>]])
map("n", "<leader>sh", [[<cmd>lua vim.lsp.buf.signature_help()<CR>]])
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
map("n", "<leader>fm", "<cmd>lua vim.lsp.buf.format()<CR>")
map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
map("n", "<leader>ws", '<cmd>lua require"metals".hover_worksheet()<CR>')
map("n", "<leader>aa", [[<cmd>lua vim.diagnostic.setqflist()<CR>]]) -- all workspace diagnostics
map("n", "<leader>ae", [[<cmd>lua vim.diagnostic.setqflist({severity = "E"})<CR>]]) -- all workspace errors
map("n", "<leader>aw", [[<cmd>lua vim.diagnostic.setqflist({severity = "W"})<CR>]]) -- all workspace warnings
map("n", "<leader>d", "<cmd>lua vim.diagnostic.setloclist()<CR>") -- buffer diagnostics only
map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev { wrap = false }<CR>")
map("n", "]d", "<cmd>lua vim.diagnostic.goto_next { wrap = false }<CR>")

-- Example mappings for usage with nvim-dap. If you don't use that, you can
-- skip these, also see dbg/python.lua
map("n", "<leader>dc", [[<cmd>lua require"dap".continue()<CR>]])
map("n", "<leader>dr", [[<cmd>lua require"dap".repl.toggle()<CR>]])
map("n", "<leader>dK", [[<cmd>lua require"dap.ui.widgets".hover()<CR>]])
map("n", "<leader>dt", [[<cmd>lua require"dap".toggle_breakpoint()<CR>]])
map("n", "<leader>dl", [[<cmd>lua require"dap".run_last()<CR>]])

-- completion related settings
-- This is similiar to what I use
local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "nvim_lsp" },
    { name = "vsnip" },
  },
  snippet = {
    expand = function(args)
      -- Comes from vsnip
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    -- None of this made sense to me when first looking into this since there
    -- is no vim docs, but you can't have select = true here _unless_ you are
    -- also using the snippet stuff. So keep in mind that if you remove
    -- snippets you need to remove this select
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    -- I use tabs... some say you should stick to ins-completion but this is just here as an example
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    -- ["<S-Tab>"] = function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   else
    --     fallback()
    --   end
    -- end,
  }),
})

----------------------------------
-- LSP Setup ---------------------
----------------------------------
local metals_config = require("metals").bare_config()

-- Example of settings
metals_config.settings = {
  showImplicitArguments = true,
  excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
  gradleScript="/Users/janine/gradlew",
  -- gradleScript="/opt/homebrew/bin/gradle",
}

-- *READ THIS*
-- I *highly* recommend setting statusBarProvider to true, however if you do,
-- you *have* to have a setting to display this in your statusline or else
-- you'll not see any messages from metals. There is more info in the help
-- docs about this
-- metals_config.init_options.statusBarProvider = "on"

-- Example if you are using cmp how to make sure the correct capabilities for snippets are set
local capabilities = vim.lsp.protocol.make_client_capabilities()
metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Debug settings if you're using nvim-dap
local dap = require("dap")

dap.configurations.scala = {
  {
    type = "scala",
    request = "launch",
    name = "RunOrTest",
    metals = {
      runType = "runOrTestFile",
      --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
    },
  },
  {
    type = "scala",
    request = "launch",
    name = "Test Target",
    metals = {
      runType = "testTarget",
    },
  },
}

metals_config.on_attach = function(client, bufnr)
  require("metals").setup_dap()
end

-- Autocmd that will actually be in charging of starting the whole thing
local nvim_metals_group = api.nvim_create_augroup("nvim-metals", { clear = true })
api.nvim_create_autocmd("FileType", {
  -- NOTE: You may or may not want java included here. You will need it if you
  -- want basic Java support but it may also conflict if you are using
  -- something like nvim-jdtls which also works on a java filetype autocmd.
  pattern = { "scala", "sbt", "java", "groovy" },
  callback = function()
     print("loading scala lsp settings...")
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})

api.nvim_create_user_command("NullLsToggle", function()
    -- you can also create commands to disable or enable sources
    require("null-ls").toggle({})
end, {})


-- local lsp = require('lsp-zero')
-- lsp.preset('recommended')
-- lsp.setup()
require("mason").setup()
require("mason-lspconfig").setup()

local null_ls = require('null-ls')
local diagnostics = null_ls.builtins.diagnostics

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = true,
})
-- add a function to toggle diagnostic text
virtual_text = {}
virtual_text.show = false
virtual_text.toggle = function()
    virtual_text.show = not virtual_text.show
    vim.diagnostic.config({
        virtual_text = virtual_text.show
    })
end

vim.api.nvim_set_keymap(
    'n',
    '<space>v',
    '<cmd>lua virtual_text.toggle()<CR>',
    {silent=true, noremap=true}
)

-- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " } ▼▲ 
local signs = { Error = "✗ ", Warn = " ", Hint = " ", Info = "⚑ " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end



local python_group = api.nvim_create_augroup("python_group", { clear = true })
api.nvim_create_autocmd("FileType", {
  pattern = { "python", "py", "ipy"},
  callback = function()
      print("loading python lsp settings...")
      null_ls.setup({
          on_attach = on_attach,
          sources = {
              -- diagnostics.flake8,
              -- diagnostics.mypy
          }
      })

      require("lspconfig").pylsp.setup({
          -- omnifunc = vim.lsp.omnifunc
          settings = {
              pylsp = {
                  plugins = {
                      mypy = { enabled = true, overrides = {'--ignore-missing-imports'}},
                      pylint = { enabled = true, args = {'--disable=C0301,C0116,C0115,C0103,logging-fstring-interpolation,unspecified-encoding'}},  
                      -- line-too-long, missing-docstring
                      flake8 = { enabled = false, ignore = {'E501', 'E231'}},
                      pycodestyle = { enabled = false, ignore ={'E501', 'E231'}},
                      pyflakes = { enabled = false },
                  }
              }
          }
      })
      require('dbg.python')

  end,
  group = python_group,
})

--  local nvim_lsp = require('lspconfig')
function setup_gopls()
  -- nvim_lsp.gopls.setup{}
  print("calling setup_gopls()...")
  require('lspconfig').gopls.setup({})
end

local go_group = api.nvim_create_augroup("go_lsp_group_my", { clear = true})
api.nvim_create_autocmd("FileType", {
  pattern = {"go"},
  callback = function() 
      print("loading go lsp settings...")
      setup_gopls()
  end,
  group = go_group,
})
vim.api.nvim_exec([[
  augroup go_lsp_group_my
    autocmd FileType go lua setup_gopls()
  augroup end
]], false)
