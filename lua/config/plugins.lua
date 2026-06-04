if vim.env.NVIM_MINIMAL_SKIP_PACK == "1" then
  return
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
      return
    end

    pcall(vim.cmd.helptags, ev.data.path .. "/doc")

    if ev.data.spec.name == "markdown-preview.nvim" then
      -- defer so the plugin is in rtp before calling its autoload function
      vim.schedule(function()
        vim.fn["mkdp#util#install"]()
      end)
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/mrcjkb/rustaceanvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/iamcco/markdown-preview.nvim" },
  { src = "https://github.com/folke/persistence.nvim" },
  { src = "https://github.com/folke/sidekick.nvim" },
  { src = "https://github.com/folke/trouble.nvim" },
  { src = "https://github.com/MagicDuck/grug-far.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/sindrets/diffview.nvim" },
  { src = "https://github.com/nvim-neotest/neotest" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
}, {
  confirm = false,
  load = true,
})
