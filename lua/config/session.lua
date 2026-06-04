local ok, persistence = pcall(require, "persistence")
if not ok then
  return
end

persistence.setup({})

vim.keymap.set("n", "<leader>qs", function()
  persistence.load()
end, { desc = "Restore session" })

vim.keymap.set("n", "<leader>qS", function()
  persistence.select()
end, { desc = "Select session" })

vim.keymap.set("n", "<leader>ql", function()
  persistence.load({ last = true })
end, { desc = "Restore last session" })

vim.keymap.set("n", "<leader>qd", function()
  persistence.stop()
end, { desc = "Do not save current session" })
