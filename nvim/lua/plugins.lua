#! /usr/bin/env lua
--
-- plugins.lua
-- Copyright (C) 2022 janine <janine@Janine-MBP>
--
-- Distributed under terms of the GNU GPLv3 license.
--

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy
vim.g.mapleader = ","

-- Create the python augroup before loading plugins
vim.api.nvim_create_augroup("python_group", { clear = true })

-- Initialize lazy with plugins
require("lazy").setup({
  -- Always loaded plugins
  vim.tbl_extend('keep', {}, require('always_loaded_plugins') or {}),

  -- Load plugins for standalone Neovim (non-VSCode)
  vim.tbl_extend('keep', {},
    not vim.g.vscode and require('neovim_standalone') or {}
  ),
}, {
  defaults = {
    lazy = false, 
  }
})

if not vim.g.vscode then
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
-- The below configuration makes use of the following plugins:
--
-- - https://github.com/hrsh7th/nvim-cmp
--   - hrsh7th/cmp-nvim-lsp for lsp completion sources
--   - hrsh7th/cmp-vsnip for snippet sources
--   - hrsh7th/vim-vsnip for snippet sources
--
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

local metals_config = require("metals").bare_config()
metals_config.settings = {
  showImplicitArguments = true,
  excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
  gradleScript="/Users/janine/gradlew",
  -- gradleScript="/opt/homebrew/bin/gradle",
}
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



-- local python_group = api.nvim_create_augroup("python_group", { clear = true })
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
end
