# Neovim config

Targets Neovim 0.12.

## Layout

```
lua/plugins.lua              lazy.nvim bootstrap + entry point
lua/always_loaded_plugins.lua  plugins loaded in both nvim and VSCode
lua/neovim_standalone.lua    plugins loaded only outside VSCode
lua/neovim_settings.lua      LSP servers, completion, folding, diagnostics
lua/vscode_settings.lua      VSCode-neovim settings
lua/lsp_mappings.lua         LSP/diagnostic keymaps (both hosts)
lua/dbg/python.lua           nvim-dap setup for python
snippets/*.json              mini.snippets sources (LSP/VSCode JSON format)
```

## Install

```sh
ln -s $PWD/lua $HOME/.config/nvim/lua
../install/setup_snippets_dir.sh      # links snippets/ into ~/.config/nvim
```

Requires `tree-sitter-cli` (nvim-treesitter `main` branch compiles parsers
with it). `../install/install_neovim.sh` installs it.

## What 0.12 replaced

These used to be plugins and are now built in — do not re-add them:

| Was | Now |
| --- | --- |
| nvim-cmp + cmp-* | `vim.o.autocomplete` + `vim.lsp.completion` |
| deoplete + deoplete-jedi | same as above |
| nerdcommenter | `gc` / `gcc` defaults |
| python-mode, FastFold | `vim.treesitter.foldexpr()` |
| lsp-zero | `vim.lsp.config()` / `vim.lsp.enable()` |
| UltiSnips + vim-snippets | mini.snippets + friendly-snippets |
| vim-airline | mini.statusline |
| vim-gitgutter | mini.diff |
| which-key | mini.clue |
| ctrlP, telescope | fzf.vim; DAP uses `dap.ui.widgets` |

**Do not add `mapclear` to the nvimrc.** Neovim installs its default mappings
(`gc`, `gcc`, `grn`, `gra`, `grr`, `gri`, `grt`, `grx`, `gO`, `K`, `[d`, `]d`,
`Y`, `<C-L>`, `<C-W>d`) before reading it, and `mapclear` wipes all of them.

No plugin needs the python3 remote host any more, so all providers are
disabled in `dot_nvimrc`.

## Snippets

`snippets/*.json` were converted from `my_patch/myBundle/UltiSnips_local`.
That directory is still used by plain vim (`dot_vimrc`), so it stays.

One snippet did not carry over: the javascript `.*\.propT` regex trigger.
LSP-format snippets match on a literal prefix, so regex triggers have no
equivalent. Re-add it as a plain prefix if you miss it.
