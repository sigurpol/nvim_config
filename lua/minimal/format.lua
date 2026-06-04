local ok, conform = pcall(require, "conform")
if not ok then
  return
end

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt_nightly" },
    yaml = { "yamlfmt" },
  },
  formatters = {
    rustfmt_nightly = {
      command = "rustup",
      args = {
        "run",
        "nightly",
        "rustfmt",
        "--emit",
        "stdout",
      },
      cwd = require("conform.util").root_file({ "Cargo.toml" }),
      stdin = true,
    },
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end

    return {
      lsp_format = "fallback",
      timeout_ms = 3000,
    }
  end,
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  conform.format({
    async = true,
    lsp_format = "fallback",
  })
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
