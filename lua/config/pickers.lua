-- Native cmdline pickers
local find = require("config.find")

-- Auto-open completion for these commands too. Note: help/colorscheme/man
-- completion is prefix-based (Neovim has no fuzzy completion for them).
for _, cmd in ipairs({ "help", "h", "Man", "colorscheme", "colo" }) do
  find.cmdline_commands[cmd] = true
end
