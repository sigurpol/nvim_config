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
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/iamcco/markdown-preview.nvim" },
  { src = "https://github.com/folke/sidekick.nvim" },
  { src = "https://github.com/tpope/vim-fugitive" },
}, {
  confirm = false,
  load = false,
})
