# Neovim configuration  via `vim.pack`

Neovim profile using the built-in `vim.pack` plugin manager from
Neovim 0.12.

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
- Git integration uses `gitsigns.nvim`, `vim-fugitive`, `diffview.nvim`, and
  Snacks git pickers.
- Sessions are saved with native `:mksession` files. On an empty startup,
  Snacks dashboard opens and `s` restores the session for the current directory.


### Update plugins

I am using a `fish` function

```bash
function nvpack-update --description "Update all native Neovim packages (including detached HEADs)"
    set -l pack_dir ~/.local/share/nvim/site/pack/

    if not test -d $pack_dir
        echo (set_color red)"Error: Neovim pack directory not found at $pack_dir"(set_color normal)
        return 1
    end

    echo (set_color blue)"Checking for plugin updates..."(set_color normal)

    # Find all directories containing a .git folder
    find $pack_dir -type d -name ".git" | while read -l git_dir
        set -l plugin_dir (dirname $git_dir)
        set -l plugin_name (basename $plugin_dir)

        echo (set_color yellow)"Updating $plugin_name..."(set_color normal)

        # Move into the plugin directory safely
        builtin cd $plugin_dir

        # 1. Fetch latest changes from the remote server
        if git fetch --all --tags --prune > /dev/null 2>&1
            # 2. Force the plugin to sync with the remote's default branch (main/master)
            # This cleanly handles the "detached HEAD" issue without needing to know the branch name.
            if git reset --hard origin/HEAD > /dev/null 2>&1
                echo (set_color green)"  ✔ Success"(set_color normal)
            else
                echo (set_color red)"  ❌ Failed to reset to remote branch"(set_color normal)
            end
        else
            echo (set_color red)"  ❌ Failed to fetch updates"(set_color normal)
        end
    end

    echo (set_color green)"✔ All packages updated!"(set_color normal)
    echo (set_color magenta)"Remember to run ':helptags ALL' inside Neovim."(set_color normal)
end
```
