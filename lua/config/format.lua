-- Format on save via LSP (rust-analyzer, yamlls, lua_ls, ...).
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
      return
    end

    vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 3000 })
  end,
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format" })

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  bang = true,
  desc = "Disable format on save",
})

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Enable format on save",
})
