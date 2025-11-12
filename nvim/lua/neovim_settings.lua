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
  -- print("loading scala lsp settings...")
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})

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
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.Error,
      [vim.diagnostic.severity.WARN]  = signs.Warn,
      [vim.diagnostic.severity.HINT]  = signs.Hint,
      [vim.diagnostic.severity.INFO]  = signs.Info,
    }
  }
})



-- Configure Python LSP servers
vim.lsp.config('ruff', {
    filetypes = { "python" },
    settings = {
        -- Ruff language server settings go here
        format = {
            ["quote-style"] = "double"
        }
    }
})
vim.lsp.enable('ruff')

vim.lsp.config('pylsp', {
    filetypes = { "python" },
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
vim.lsp.enable('pylsp')

-- Load Python debugger config on Python files
-- Use existing python_group created in plugins.lua (don't recreate with clear=true)
local python_group = "python_group"
api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
      require('dbg.python')
  end,
  group = python_group,
})

-- Configure Go LSP
vim.lsp.config('gopls', {
    filetypes = { "go" }
})
vim.lsp.enable('gopls')
