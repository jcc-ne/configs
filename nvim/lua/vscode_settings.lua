-- VSCode specific keymaps and settings
--
--
local function notify(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
end

local function setup()
    -- Folding commands
    vim.keymap.set('n', 'zM', function() vim.fn.VSCodeNotify('editor.foldAll') end)
    vim.keymap.set('n', 'zR', function() vim.fn.VSCodeNotify('editor.unfoldAll') end)
    vim.keymap.set('n', 'zc', function() vim.fn.VSCodeNotify('editor.fold') end)
    vim.keymap.set('n', 'zC', function() vim.fn.VSCodeNotify('editor.foldRecursively') end)
    vim.keymap.set('n', 'zo', function() vim.fn.VSCodeNotify('editor.unfold') end)
    vim.keymap.set('n', 'zO', function() vim.fn.VSCodeNotify('editor.unfoldRecursively') end)
    vim.keymap.set('n', 'za', function() vim.fn.VSCodeNotify('editor.toggleFold') end)

    -- Cursor movement
    vim.keymap.set('n', 'j', function() vim.fn.VSCodeCall('cursorDown') end, { silent = true })
    vim.keymap.set('n', 'k', function() vim.fn.VSCodeCall('cursorUp') end, { silent = true })

    -- file finders
    vim.keymap.set('n', '<Leader>qo', notify 'workbench.action.quickOpen', { silent = true })
end

setup()
