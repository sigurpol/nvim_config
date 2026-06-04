vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.fn.has("nvim-0.12") == 0 or vim.pack == nil then
  vim.notify("nvim requires Neovim 0.12+ with vim.pack", vim.log.levels.ERROR)
  return
end

require("minimal/options")
require("minimal/keymaps")
require("minimal/rust")
require("minimal/plugins")
require("minimal/colorscheme")
require("minimal/session")
require("minimal/snacks")
require("minimal/markdown")
require("minimal/which_key")
require("minimal/oil")
require("minimal/lsp")
require("minimal/trouble")
require("minimal/git")
require("minimal/format")
require("minimal/test")
