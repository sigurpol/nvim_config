local opt = vim.opt

opt.clipboard = "unnamedplus"
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.number = true
opt.path:append("**")
opt.relativenumber = true
opt.shiftwidth = 2
-- opt.signcolumn = "yes"
-- opt.smoothscroll = true
opt.softtabstop = 2
opt.swapfile = false
opt.termguicolors = true
opt.winborder = "rounded"
opt.wildoptions:append("fuzzy")

-- wrap and spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
