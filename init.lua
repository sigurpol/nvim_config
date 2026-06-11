vim.g.nvim_start_ns = vim.uv.hrtime()
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local startup_group = vim.api.nvim_create_augroup("config_startup_time", { clear = true })
local function record_startup_time()
  if not vim.g.nvim_startup_ms then
    vim.g.nvim_startup_ms = (vim.uv.hrtime() - vim.g.nvim_start_ns) / 1e6
  end
end

vim.api.nvim_create_autocmd({ "UIEnter", "VimEnter" }, {
  group = startup_group,
  callback = function()
    record_startup_time()
  end,
})

if vim.fn.has("nvim-0.12") == 0 or vim.pack == nil then
  vim.notify("nvim requires Neovim 0.12+ with vim.pack", vim.log.levels.ERROR)
  return
end

require("config.options")
require("config.find")
require("config.rust")
require("config.plugins")
require("config.colorscheme")
require("config.session")
require("config.snacks")
require("config.terminal")
require("config.which_key")
require("config.oil")
require("config.lsp")
require("config.diagnostics")
require("config.symbols")
require("config.git")
require("config.format")
