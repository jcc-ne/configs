return {
  -- nerdcommenter removed: gc/gcc/gcip are Neovim built-in defaults, and
  -- NERDSpaceDelims matched the built-in behavior anyway.
  { 'tpope/vim-fugitive', cmd = {'G', 'Git', 'GBlame', 'GBrowse', 'Gvdiffsplit'} },
  'tpope/vim-rhubarb',
  'lifepillar/vim-solarized8',
  {'vim-scripts/YankRing.vim',
    init = function()
        vim.g.yankring_replace_n_pkey = '<leader>p'
    end
  },
  -- ctrlP removed: it was bound to <c-p> for buffers only, which :FzBuffers
  -- (<leader>b) already covers. fzf.vim is the one finder in use.
}
