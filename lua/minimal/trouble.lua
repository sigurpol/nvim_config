local ok, trouble = pcall(require, "trouble")
if not ok then
  return
end

trouble.setup({
  modes = {
    lsp = {
      win = { position = "right" },
    },
  },
})

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode or "n", lhs, rhs, { desc = desc, silent = true })
end

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)")
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer diagnostics (Trouble)")
map("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", "Symbols (Trouble)")
map("n", "<leader>cS", "<cmd>Trouble lsp toggle<cr>", "LSP references/definitions/... (Trouble)")
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", "Location list (Trouble)")
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", "Quickfix list (Trouble)")

map("n", "<leader>xl", function()
  local open = vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
  local success, err = pcall(open and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, "Location list")

map("n", "<leader>xq", function()
  local open = vim.fn.getqflist({ winid = 0 }).winid ~= 0
  local success, err = pcall(open and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, "Quickfix list")

map("n", "[q", function()
  if trouble.is_open() then
    trouble.prev({ skip_groups = true, jump = true })
    return
  end

  local success, err = pcall(vim.cmd.cprev)
  if not success then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, "Previous Trouble/quickfix item")

map("n", "]q", function()
  if trouble.is_open() then
    trouble.next({ skip_groups = true, jump = true })
    return
  end

  local success, err = pcall(vim.cmd.cnext)
  if not success then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, "Next Trouble/quickfix item")
