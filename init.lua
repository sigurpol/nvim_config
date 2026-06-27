vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.fn.has("nvim-0.12") == 0 or vim.pack == nil then
  vim.notify("nvim requires Neovim 0.12+ with vim.pack", vim.log.levels.ERROR)
  return
end

require("config.options")
require("config.find")
require("config.grep")
require("config.pickers")
require("config.rust")
require("config.plugins")
require("config.colorscheme")
require("config.session")
require("config.sidekick")
require("config.terminal")
require("config.which_key")
require("config.lsp")
require("config.diagnostics")
require("config.symbols")
require("config.git")
require("config.blame")
require("config.format")
