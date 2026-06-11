local ok, oil = pcall(require, "oil")
if ok then
  -- Keep netrw enabled (`:Explore`/`:Lexplore`); oil stays explicit via `-`
  oil.setup({ default_file_explorer = false })
end

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

-- netrw left sidebar (tree view) rooted at the current file's directory.
vim.g.netrw_liststyle = 3

vim.keymap.set("n", "<leader>e", function()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  vim.cmd("Lexplore " .. vim.fn.fnameescape(dir))
end, { desc = "File explorer (netrw)" })
