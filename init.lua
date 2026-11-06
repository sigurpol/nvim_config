vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.fn.has("nvim-0.13") == 0 then
  vim.notify("nvim requires Neovim 0.13+", vim.log.levels.ERROR)
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
