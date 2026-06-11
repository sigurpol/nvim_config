local function notify(name, on)
  vim.notify((on and "Enabled " or "Disabled ") .. name, vim.log.levels.INFO)
end

local function toggle(lhs, name, get, set)
  vim.keymap.set("n", lhs, function()
    local on = not get()
    set(on)
    notify(name, on)
  end, { desc = "Toggle " .. name:lower() })
end

local function opt(lhs, name, option)
  toggle(lhs, name, function()
    return vim.o[option]
  end, function(on)
    vim.o[option] = on
  end)
end

opt("<leader>us", "Spelling", "spell")
opt("<leader>uw", "Wrap", "wrap")
opt("<leader>uL", "Relative number", "relativenumber")
opt("<leader>ul", "Line number", "number")

toggle("<leader>uc", "Conceal", function()
  return vim.o.conceallevel > 0
end, function(on)
  vim.o.conceallevel = on and 2 or 0
end)

toggle("<leader>ub", "Dark background", function()
  return vim.o.background == "dark"
end, function(on)
  vim.o.background = on and "dark" or "light"
end)

toggle("<leader>ud", "Diagnostics", vim.diagnostic.is_enabled, function(on)
  vim.diagnostic.enable(on)
end)

toggle("<leader>uh", "Inlay hints", function()
  return vim.lsp.inlay_hint.is_enabled()
end, function(on)
  vim.lsp.inlay_hint.enable(on)
end)
