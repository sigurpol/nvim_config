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

In particular, Rust is configured through `rustaceanvim`, so `rust-analyzer` should be available on `PATH`
through Rustup or your system package manager.
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
sudo rm -rf /opt/lua-language-server
sudo mkdir -p /opt/lua-language-server
curl -fL "$lua_ls_url" | sudo tar -xz -C /opt/lua-language-server
printf '%s\n' '#!/bin/sh' 'exec /opt/lua-language-server/bin/lua-language-server "$@"' |
  sudo tee /usr/local/bin/lua-language-server >/dev/null
sudo chmod +x /usr/local/bin/lua-language-server

sudo npm install -g yaml-language-server

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

### Useful defaults (inspired by LazyVim):

- `<leader><space>` opens the Snacks file picker.
- `gr` opens LSP references with Neovim's native quickfix list.
- `which-key.nvim` shows keybinding hints for prefixes such as `g`,
  `<leader>g`, and `<leader>gh`.
- `<leader>as` opens the Snacks-backed Sidekick CLI selector for tools such as
  opencode, Claude, Gemini, and Codex.
- `<leader>sr` opens Grug Far for project search and replace.
- `<leader>gY` copies a GitHub-style permalink for the current file or
  selection.
- `<leader>gg` opens LazyGit at the current Git root.
- `<leader>xx` opens all diagnostics in the quickfix list.
- ``<C-`>`` opens a native terminal split at the current Git root.
- Git integration uses `gitsigns.nvim`, `vim-fugitive`, and `diffview.nvim`.
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
Neovim, then run `:packdel ++all` to clean up inactive packages.
