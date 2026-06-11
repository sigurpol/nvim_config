-- Native diagnostic and quickfix/location-list mappings.
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode or "n", lhs, rhs, { desc = desc, silent = true })
end

local function command(name)
  return function()
    local success, err = pcall(vim.cmd[name])
    if not success then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

local function toggle_quickfix()
  local open = vim.fn.getqflist({ winid = 0 }).winid ~= 0
  command(open and "cclose" or "copen")()
end

local function toggle_loclist()
  local open = vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
  command(open and "lclose" or "lopen")()
end

local function loclist_diagnostics()
  vim.diagnostic.setloclist({ open = false, title = "Buffer diagnostics" })
  command("lopen")()
end

vim.cmd([[
  cnoreabbrev <expr> grep getcmdtype() ==# ':' && getcmdline() ==# 'grep' ? 'grep!' : 'grep'
]])

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = { "grep", "grepadd" },
  callback = function()
    command("copen")()
  end,
})

map("n", "<leader>xx", loclist_diagnostics, "Diagnostics")
map("n", "<leader>xX", loclist_diagnostics, "Buffer diagnostics")
map("n", "<leader>xL", loclist_diagnostics, "Diagnostics location list")
map("n", "<leader>xQ", toggle_quickfix, "Quickfix list")

map("n", "<leader>xl", toggle_loclist, "Location list")
map("n", "<leader>xq", toggle_quickfix, "Quickfix list")

map("n", "[q", function()
  command("cprev")()
end, "Previous quickfix item")

map("n", "]q", function()
  command("cnext")()
end, "Next quickfix item")

map("n", "[l", function()
  command("lprev")()
end, "Previous location list item")

map("n", "]l", function()
  command("lnext")()
end, "Next location list item")
