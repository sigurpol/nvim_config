local ok, sidekick = pcall(require, "sidekick")
if not ok then
  return
end

sidekick.setup({
  nes = { enabled = false }, -- no Copilot / next-edit-suggestions
  -- No picker backend (Snacks removed); disable the file/buffer context picker keys.
  cli = { win = { keys = { files = false, buffers = false } } },
})

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

map("n", "<leader>aa", function()
  require("sidekick.cli").toggle()
end, "Sidekick toggle CLI")

map("n", "<leader>as", function()
  require("sidekick.cli").select()
end, "Select CLI")

map("n", "<leader>ad", function()
  require("sidekick.cli").close()
end, "Detach CLI session")

map({ "x", "n" }, "<leader>at", function()
  require("sidekick.cli").send({ msg = "{this}" })
end, "Send this")

map("n", "<leader>af", function()
  require("sidekick.cli").send({ msg = "{file}" })
end, "Send file")

map("x", "<leader>av", function()
  require("sidekick.cli").send({ msg = "{selection}" })
end, "Send visual selection")

map({ "n", "x" }, "<leader>ap", function()
  require("sidekick.cli").prompt()
end, "Sidekick select prompt")
