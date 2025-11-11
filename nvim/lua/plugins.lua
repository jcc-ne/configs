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
  print("loading neovim settings...")
  require('neovim_settings')
else
  print("loading vscode settings...")
  require('vscode_settings')
end
