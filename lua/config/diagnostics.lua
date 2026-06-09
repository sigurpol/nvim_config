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

local function quickfix_diagnostics()
  vim.diagnostic.setqflist({ open = false, title = "Diagnostics" })
  command("copen")()
end

local function loclist_diagnostics()
  vim.diagnostic.setloclist({ open = false, title = "Buffer diagnostics" })
  command("lopen")()
end

map("n", "<leader>xx", quickfix_diagnostics, "Diagnostics")
map("n", "<leader>xX", loclist_diagnostics, "Buffer diagnostics")
map("n", "<leader>xQ", quickfix_diagnostics, "Diagnostics quickfix")
map("n", "<leader>xL", loclist_diagnostics, "Diagnostics location list")

map("n", "<leader>xl", toggle_loclist, "Location list")
map("n", "<leader>xq", toggle_quickfix, "Quickfix list")

map("n", "[q", function()
  command("cprev")()
end, "Previous quickfix item")

map("n", "]q", function()
  command("cnext")()
end, "Next quickfix item")
