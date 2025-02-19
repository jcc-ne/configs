return {
  'epeli/slimux',
  {'majutsushi/tagbar', cmd = 'TagbarToggle'},
  'christoomey/vim-tmux-navigator',
  'scrooloose/nerdcommenter',
  { 'tpope/vim-fugitive', cmd = {'G', 'Git'} },
  'tpope/vim-rhubarb',
  'lifepillar/vim-solarized8',
  {'vim-scripts/YankRing.vim',
    init = function()
        vim.g.yankring_replace_n_pkey = '<leader>p'
    end
  },
  { 'ctrlpvim/ctrlP.vim',
  	init = function()
        vim.g.ctrlp_map = '<c-p>'
        vim.g.ctrlp_cmd = 'CtrlPBuffer'
        vim.g.ctrlp_custom_ignore = 'node_modules|DS_Store|git|(.(swp|ico|git|svn|pyc))'
    end
  },
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
