local ok, oil = pcall(require, "oil")
if ok then
  oil.setup({})
end

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer (oil)" })
