return {
  'epeli/slimux',
  {'majutsushi/tagbar', cmd = 'TagbarToggle'},
  'christoomey/vim-tmux-navigator',
  'scrooloose/nerdcommenter',
  { 'tpope/vim-fugitive', cmd = 'G' },
  'tpope/vim-rhubarb',
  'lifepillar/vim-solarized8',
  'vim-scripts/YankRing.vim',
  'ctrlpvim/ctrlP.vim',
  'SirVer/ultisnips',
  'honza/vim-snippets',
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
  { dir = '~/.vim/bundle/myBundle' },
}
