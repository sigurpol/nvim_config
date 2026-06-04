local map = vim.keymap.set

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>ww", "<cmd>write<cr>", { desc = "Write buffer" })
