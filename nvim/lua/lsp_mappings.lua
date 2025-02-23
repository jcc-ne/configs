#! /usr/bin/env lua

--local function map(mode, lhs, rhs, opts)
--  local options = { noremap = true }
--  if opts then
--    options = vim.tbl_extend("force", options, opts)
--  end
--  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
--end

local map = vim.keymap.set
local keymap = vim.api.nvim_set_keymap
local api = vim.api
local cmd = vim.cmd


-- LSP mappings
map("n", "<space>h", "<cmd>lua vim.diagnostic.hide()<CR>")
map("n", "<space>hh", "<cmd>lua vim.diagnostic.disable()<CR>")
map("n", "<space>s", "<cmd>lua vim.diagnostic.show()<CR>")
map("n", "<space>ss", "<cmd>lua vim.diagnostic.enable()<CR>")
map("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>")
map("n", "gD", "<cmd>lua vim.lsp.buf.definition()<CR>")

local function notify(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
end

local function v_notify(cmd)
    return string.format("<cmd>call VSCodeNotifyVisual('%s', 1)<CR>", cmd)
end

if vim.g.vscode then
    map({"n", "v"}, "<leader>t", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
    map("n", "gd", "<cmd>call <SNR>5_vscodeGoToDefinition('revealDefinition')<CR>")

    -- keymap('n', '<Leader>xr', notify 'references-view.findReferences', { silent = true }) -- language references
    keymap('n', '<Leader>xd', notify 'workbench.actions.view.problems', { silent = true }) -- language diagnostics
    keymap('n', 'gr', notify 'editor.action.goToReferences', { silent = true })
    -- keymap('n', '<Leader>rn', notify 'editor.action.rename', { silent = true })
    keymap('n', '<Leader>fm', notify 'editor.action.formatDocument', { silent = true })
    keymap('n', '<Leader>ca', notify 'editor.action.refactor', { silent = true }) -- language code actions

    -- find inFiles, Files
    keymap('n', '<Leader>r', notify 'workbench.action.findInFiles', { silent = true }) -- use ripgrep to search files
    keymap('n', '<Leader>f', notify 'workbench.action.quickOpen', { silent = true }) -- find files

    -- toggle panels
    keymap('n', '<Leader>ts', notify 'workbench.action.toggleSidebarVisibility', { silent = true })
    keymap('n', '<Leader>th', notify 'workbench.action.toggleAuxiliaryBar', { silent = true }) -- toggle docview (help page)
    keymap('n', '<Leader>tp', notify 'workbench.action.togglePanel', { silent = true })
    keymap('n', '<Leader>tw', notify 'workbench.action.terminal.toggleTerminal', { silent = true }) -- terminal window

    keymap('n', '<Leader>fc', notify 'workbench.action.showCommands', { silent = true }) -- find commands

    keymap('v', '<Leader>fm', v_notify 'editor.action.formatSelection', { silent = true })
    keymap('v', '<Leader>ca', v_notify 'editor.action.refactor', { silent = true })
    keymap('v', '<Leader>fc', v_notify 'workbench.action.showCommands', { silent = true })

    -- harpoon keymaps
    map({"n", "v"}, "<leader>ha", "<cmd>lua require('vscode').action('vscode-harpoon.addEditor')<CR>")
    map({"n", "v"}, "<leader>ho", "<cmd>lua require('vscode').action('vscode-harpoon.editorQuickPick')<CR>")
    map({"n", "v"}, "<leader>he", "<cmd>lua require('vscode').action('vscode-harpoon.editEditors')<CR>")
    map({"n", "v"}, "<leader>h1", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor1')<CR>")
    map({"n", "v"}, "<leader>h2", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor2')<CR>")
    map({"n", "v"}, "<leader>h3", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor3')<CR>")
    map({"n", "v"}, "<leader>h4", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor4')<CR>")
    map({"n", "v"}, "<leader>h5", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor5')<CR>")
    map({"n", "v"}, "<leader>h6", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor6')<CR>")
    map({"n", "v"}, "<leader>h7", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor7')<CR>")
    map({"n", "v"}, "<leader>h8", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor8')<CR>")
    map({"n", "v"}, "<leader>h9", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor9')<CR>")
else
    map("n", "gd", "<cmd>lua vim.lsp.buf.declaration()<CR>")
end

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
