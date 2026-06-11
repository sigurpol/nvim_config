-- Native replacements for Snacks cmdline pickers.
local find = require("config.find")

-- Auto-open completion for these commands too. Note: help/colorscheme/man
-- completion is prefix-based (Neovim has no fuzzy completion for them).
for _, cmd in ipairs({ "help", "h", "Man", "colorscheme", "colo" }) do
  find.cmdline_commands[cmd] = true
end

local map = vim.keymap.set

-- Command-line window: full editing of command/search history.
map("n", "<leader>:", "q:", { desc = "Command history" })
map("n", "<leader>sc", "q:", { desc = "Command history" })
map("n", "<leader>s/", "q/", { desc = "Search history" })

local function open(cmd)
  return function()
    vim.fn.feedkeys(":" .. cmd .. " ", "n")
  end
end

map("n", "<leader>sh", open("help"), { desc = "Help pages" })
map("n", "<leader>sM", open("Man"), { desc = "Man pages" })
map("n", "<leader>uC", open("colorscheme"), { desc = "Colorschemes" })
