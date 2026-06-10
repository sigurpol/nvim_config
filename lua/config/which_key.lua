local ok, wk = pcall(require, "which-key")
if not ok then
  return
end

wk.setup({
  preset = "helix",
  delay = function(ctx)
    return ctx.plugin and 0 or 200
  end,
  spec = {
    {
      mode = { "n", "x" },
      { "<leader>a", group = "ai/actions" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>q", group = "quit/session" },
      { "<leader>s", group = "search" },
      -- { "<leader>t", group = "test" },
      { "<leader>w", group = "window", proxy = "<c-w>" },
      { "<leader>x", group = "diagnostics/quickfix" },
      { "[", group = "previous" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "z", group = "fold" },
    },
  },
})

vim.keymap.set("n", "<leader>?", function()
  wk.show({ global = false })
end, { desc = "Buffer keymaps" })

vim.keymap.set("n", "<c-w><space>", function()
  wk.show({ keys = "<c-w>", loop = true })
end, { desc = "Window keymaps" })
