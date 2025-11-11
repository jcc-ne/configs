#! /usr/bin/env lua
--
-- python.lua
-- Copyright (C) 2022 janine <janine@Janine-MBP>
--
-- Distributed under terms of the GNU GPLv3 license.
--


require('dap-python').setup()
require('dap-python').test_runner = 'pytest'

require('telescope').load_extension('dap')

local api = vim.api
local cmd = vim.cmd

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<leader>dc', '<cmd>lua require"dap".continue()<CR>') 
map('n', '<leader>dsv', '<cmd>lua require"dap".step_over()<CR>') 
map('n', '<leader>dsi', '<cmd>lua require"dap".step_into()<CR>') 
map('n', '<leader>dso', '<cmd>lua require"dap".step_out()<CR>') 
map('n', '<leader>dt', '<cmd>lua require"dap".toggle_breakpoint()<CR>') 
map('n', '<leader>dsbr', '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>') 
map('n', '<leader>dsbm', '<cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>') 
map("n", "<leader>dr", [[<cmd>lua require"dap".repl.toggle()<CR>]])
map('n', '<leader>dro', '<cmd>lua require"dap".repl.open()<CR>') 
map('n', '<leader>drl', '<cmd>lua require"dap".repl.run_last()<CR>') 

-- telescope-dap
map('n', '<leader>dcc', '<cmd>lua require"telescope".extensions.dap.commands{}<CR>')
map('n', '<leader>dco', '<cmd>lua require"telescope".extensions.dap.configurations{}<CR>')
map('n', '<leader>dlb', '<cmd>lua require"telescope".extensions.dap.list_breakpoints{}<CR>')
map('n', '<leader>dv', '<cmd>lua require"telescope".extensions.dap.variables{}<CR>')
map('n', '<leader>df', '<cmd>lua require"telescope".extensions.dap.frames{}<CR>')


-- additional step in methods
map('n', '<leader>dn', '<cmd>lua require("dap-python").test_method()<CR>')
map('n', '<leader>dnn', '<cmd>lua require("dap-python").test_class()<CR>')
map('v', '<leader>ds <ESC>', '<cmd>lua require("dap-python").debug_selection()<CR>')
