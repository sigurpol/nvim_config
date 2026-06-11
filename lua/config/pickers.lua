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

-- Plain native list views (no fuzzy equivalent).
map("n", '<leader>s"', "<cmd>registers<cr>", { desc = "Registers" })
map("n", "<leader>sa", "<cmd>autocmd<cr>", { desc = "Autocmds" })
map("n", "<leader>sC", "<cmd>command<cr>", { desc = "Commands" })
map("n", "<leader>sH", "<cmd>highlight<cr>", { desc = "Highlights" })
map("n", "<leader>sj", "<cmd>jumps<cr>", { desc = "Jumps" })
map("n", "<leader>sk", "<cmd>map<cr>", { desc = "Keymaps" })
map("n", "<leader>sm", "<cmd>marks<cr>", { desc = "Marks" })
map("n", "<leader>n", "<cmd>messages<cr>", { desc = "Messages" })
