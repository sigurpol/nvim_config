# Neovim configuration  via `vim.pack`

Neovim profile using the built-in `vim.pack` plugin manager from Neovim 0.12.
Plugin maintenance uses the built-in `:packupdate` and `:packdel` commands from
Neovim 0.13.

### Installation

This profile lives by default at `~/.config/nvim`, stores plugin state under
`~/.local/share/nvim`, and writes its `vim.pack` lockfile to
`~/.config/nvim/nvim-pack-lock.json`.

First startup installs plugins with `vim.pack.add()`.

Rust is configured through `rustaceanvim`, so `rust-analyzer` should be available on `PATH`
through Rustup or your system. Mason is configured for `lua_ls`, `yamlls`, and
`harper_ls`; `rust_analyzer` is explicitly excluded from Mason's automatic LSP
enablement to avoid a second Rust client.

### Useful defaults (inspired by LazyVim):

- `<leader><space>` opens the Snacks file picker.
- `gr` opens LSP references, using Snacks when available.
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
