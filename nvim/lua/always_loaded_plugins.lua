return {
  -- nerdcommenter removed: gc/gcc/gcip are Neovim built-in defaults, and
  -- NERDSpaceDelims matched the built-in behavior anyway.
  { 'tpope/vim-fugitive', cmd = {'G', 'Git', 'GBlame', 'GBrowse', 'Gvdiffsplit'} },
  'tpope/vim-rhubarb',
  'lifepillar/vim-solarized8',
  -- YankRing sourced ~22ms of vimscript on every startup (measured with
  -- --startuptime; it and slimux together were ~30% of a ~150ms start).
  --
  -- TextYankPost is the trigger rather than a key, because YankRing captures
  -- the ring through normal-mode maps it installs at load time -- it can only
  -- record yanks that happen after it loads. Loading on the first yank of the
  -- session means it misses nothing except, at worst, that first yank, which
  -- is still sitting in "0 anyway. The cmd list keeps :YRShow and friends
  -- working before any yank has happened.
  {'vim-scripts/YankRing.vim',
    event = 'TextYankPost',
    cmd = {'YRShow', 'YRClear', 'YRPaste', 'YRReplace', 'YRToggle', 'YRSearch',
           'YRGetElem', 'YRPop', 'YRPush'},
    init = function()
        vim.g.yankring_replace_n_pkey = '<leader>p'
    end
  },
  -- ctrlP removed: it was bound to <c-p> for buffers only, which :FzBuffers
  -- already covers. fzf.vim is the one finder in use, and <c-p> is mapped to
  -- :FzBuffers in neovim_standalone.lua so the key still works.
}
