return {
  'scrooloose/nerdcommenter',
  { 'tpope/vim-fugitive', cmd = {'G', 'Git', 'GBlame', 'GBrowse', 'Gvdiffsplit'} },
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
}
