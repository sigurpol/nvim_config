local ok, oil = pcall(require, "oil")
if ok then
  -- Keep netrw enabled (`:Explore`/`:Lexplore`); oil stays explicit via `-`/`<leader>e`.
  oil.setup({ default_file_explorer = false })
end

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
