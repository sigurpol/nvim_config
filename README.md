# Neovim configuration  via `vim.pack`

Neovim profile using the built-in `vim.pack` plugin manager from Neovim 0.12.
Plugin maintenance uses the built-in `:packupdate` and `:packdel` commands from
Neovim 0.13.

### Installation

This profile lives by default at `~/.config/nvim`, stores plugin state under
`~/.local/share/nvim`, and writes its `vim.pack` lockfile to
`~/.config/nvim/nvim-pack-lock.json`.

First startup installs plugins with `vim.pack.add()`.

LSP configuration uses Neovim's native
`vim.lsp.config()` and `vim.lsp.enable()` APIs without Mason or
`nvim-lspconfig`; language server binaries must be installed separately.

In particular, Rust is configured through native `vim.lsp.config("rust_analyzer", ...)`, so `rust-analyzer`
should be available on `PATH` through Rustup or your system package manager.
Same for lua-language-server, yaml-language-server or any other LSP you might want to add.

On Ubuntu, install the LSP binaries used by this config with:

```bash
sudo apt update
sudo apt install -y curl nodejs npm

lua_ls_url="$(
  curl -fsSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest |
    grep -oE 'https://[^"]+linux-x64\.tar\.gz' |
    head -n 1
)"
# Install to a user-writable dir: under root-owned /opt the server cannot create
# its log/cache dir at runtime and crashes before initializing.
lua_ls_dir="${XDG_DATA_HOME:-$HOME/.local/share}/lua-language-server"
rm -rf "$lua_ls_dir"
mkdir -p "$lua_ls_dir"
curl -fL "$lua_ls_url" | tar -xz -C "$lua_ls_dir"
printf '%s\n' '#!/bin/sh' "exec \"$lua_ls_dir/bin/lua-language-server\" \"\$@\"" |
  sudo tee /usr/local/bin/lua-language-server >/dev/null
sudo chmod +x /usr/local/bin/lua-language-server

npm install -g yaml-language-server

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
rustup component add rust-analyzer
cargo install --locked harper-ls
```

After installation, these commands must be available on `PATH`:

```bash
lua-language-server --version
yaml-language-server --version
harper-ls --version
rust-analyzer --version
```

### Useful defaults

- The `<leader>f` group uses native cmdline completion:
  `<leader><space>`/`<leader>ff` (files), `<leader>fg` (git-tracked),
  `<leader>fc` (config) switch the `findfunc` source and open fuzzy `:find`;
  `<leader>fb` opens native fuzzy `:buffer`.
- More native cmdline pickers: `<leader>sh` (`:help`), `<leader>sM` (`:Man`),
  `<leader>uC` (`:colorscheme`) auto-open prefix completion; `<leader>:`/`<leader>sc`
  open the command-line window (`q:`), `<leader>s/` the search history (`q/`).
- `<leader>u*` toggles (spell, wrap, numbers, conceal, background, diagnostics,
  inlay hints) are native option flips.
- `gr` opens LSP references with Neovim's native quickfix list.
- `which-key.nvim` shows keybinding hints for prefixes such as `g`,
  `<leader>g`, and `<leader>gh`.
- `<leader>as` opens the Snacks-backed Sidekick CLI selector for tools such as
  opencode, Claude, Gemini, and Codex.
- Grep is native ripgrep-into-quickfix: `<leader>/` prompts for a
  pattern; `<leader>sw` greps the word/selection; `<leader>sB` restricts to open
  buffers; `<leader>sb` searches lines in the current buffer (`:vimgrep`). All
  open the quickfix list for `:cnext`/`:cdo`.
- `<leader>gY` copies a GitHub-style permalink for the current file or
  selection.
- `<leader>gg` opens LazyGit at the current Git root.
- `<leader>xd` opens local (current file) diagnostics in the location list;
  `<leader>xD` puts workspace (all-buffer) diagnostics in the quickfix list.
- ``<C-`>`` opens a native terminal split at the current Git root.
- Git integration uses `gitsigns.nvim` and `vim-fugitive`; diffs and file
  history go through fugitive (`:Gvdiffsplit`, `:0Gclog`).
- Sessions are saved with native `:mksession` files. On an empty startup,
  Snacks dashboard opens and `s` restores the session for the current directory.


### Update plugins

Neovim 0.13 ships the package maintenance commands needed for this profile, so
no shell wrapper is required.

```vim
:packupdate
:packdel ++all
```

Use `:packupdate ++lockfile` after pulling lockfile changes from another
machine. To remove plugins, delete their specs from `vim.pack.add()`, restart
Neovim via `:restart`, then run `:packdel ++all` to clean up inactive packages.
