local ok, snacks = pcall(require, "snacks")
if not ok then
  return
end

local function startup_time()
  local ms = vim.g.nvim_startup_ms or ((vim.uv.hrtime() - vim.g.nvim_start_ns) / 1e6)

  return {
    align = "center",
    text = {
      { "Neovim loaded in ", hl = "footer" },
      { ("%.1fms"):format(ms), hl = "special" },
    },
  }
end

snacks.setup({
  dashboard = {
    enabled = true,
    preset = {
      header = [[
███████╗██╗ ██████╗ ██╗   ██╗██████╗ ██╗   ██╗██╗███╗   ███╗
██╔════╝██║██╔════╝ ██║   ██║██╔══██╗██║   ██║██║████╗ ████║
███████╗██║██║  ███╗██║   ██║██████╔╝██║   ██║██║██╔████╔██║
╚════██║██║██║   ██║██║   ██║██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║
███████║██║╚██████╔╝╚██████╔╝██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]],
      keys = {
        { key = "f", desc = "Find File",       action = ":lua Snacks.dashboard.pick('files')" },
        { key = "n", desc = "New File",        action = ":ene | startinsert" },
        { key = "g", desc = "Find Text",       action = ":lua Snacks.dashboard.pick('grep')" },
        { key = "r", desc = "Recent Files",    action = ":lua Snacks.dashboard.pick('recent')" },
        { key = "c", desc = "Config",          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { key = "s", desc = "Restore Session", action = ":lua require('config.session').load()" },
        { key = "q", desc = "Quit",            action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys",  gap = 1, padding = 1 },
      startup_time,
    },
  },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  picker = {
    enabled = true,
    actions = {
      sidekick_send = function(...)
        return require("sidekick.cli.picker.snacks").send(...)
      end,
    },
    sources = {
      explorer = {
        hidden = true,
        ignored = true,
      },
      files = {
        hidden = true,
        ignored = true,
      },
    },
    win = {
      input = {
        keys = {
          ["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
        },
      },
    },
  },
  scope = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
})

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode or "n", lhs, rhs, { desc = desc })
end

local has_sidekick, sidekick = pcall(require, "sidekick")
if has_sidekick then
  sidekick.setup({
    cli = {
      picker = "snacks",
    },
    nes = {
      enabled = false,
    },
  })

  map({ "n", "t", "i", "x" }, "<C-.>", function()
    require("sidekick.cli").focus()
  end, "Sidekick focus")

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
end

map("n", "<leader>su", function()
  local ok, err = pcall(vim.cmd.packadd, "nvim.undotree")
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  vim.cmd.Undotree()
end, "Undo history")

local function git_root()
  local file = vim.api.nvim_buf_get_name(0)
  local cwd = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
  local root = vim.fn.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })

  return vim.v.shell_error == 0 and vim.trim(root) or vim.fn.getcwd()
end

map("n", "<leader>e", function()
  Snacks.explorer({ cwd = git_root() })
end, "Explorer (toggle)")

map({ "n", "t" }, "]]", function()
  Snacks.words.jump(vim.v.count1)
end, "Next reference")

map({ "n", "t" }, "[[", function()
  Snacks.words.jump(-vim.v.count1)
end, "Previous reference")
