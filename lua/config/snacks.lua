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
  bigfile = { enabled = true },
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
  notifier = {
    enabled = true,
    timeout = 3000,
  },
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
  quickfile = { enabled = true },
  scope = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
})

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode or "n", lhs, rhs, { desc = desc })
end

map("n", "<leader><space>", function()
  Snacks.picker.files()
end, "Find files")

map("n", "<leader>,", function()
  Snacks.picker.buffers()
end, "Buffers")

map("n", "<leader>/", function()
  Snacks.picker.grep()
end, "Grep")

map("n", "<leader>:", function()
  Snacks.picker.command_history()
end, "Command history")

map("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, "Buffers")

map("n", "<leader>fc", function()
  Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, "Find config file")

map("n", "<leader>ff", function()
  Snacks.picker.files()
end, "Find files")

map("n", "<leader>fg", function()
  Snacks.picker.git_files()
end, "Find git files")

map("n", "<leader>fr", function()
  Snacks.picker.recent()
end, "Recent files")

map("n", "<leader>fp", function()
  Snacks.picker.projects()
end, "Projects")

map("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, "Notification history")

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

map("n", "<leader>sd", function()
  Snacks.picker.diagnostics()
end, "Diagnostics")

map("n", "<leader>sD", function()
  Snacks.picker.diagnostics_buffer()
end, "Buffer diagnostics")

map("n", "<leader>sg", function()
  Snacks.picker.grep()
end, "Grep")

map("n", "<leader>sB", function()
  Snacks.picker.grep_buffers()
end, "Grep open buffers")

map({ "n", "x" }, "<leader>sw", function()
  Snacks.picker.grep_word()
end, "Word or selection")

map("n", '<leader>s"', function()
  Snacks.picker.registers()
end, "Registers")

map("n", "<leader>s/", function()
  Snacks.picker.search_history()
end, "Search history")

map("n", "<leader>sa", function()
  Snacks.picker.autocmds()
end, "Autocmds")

map("n", "<leader>sb", function()
  Snacks.picker.lines()
end, "Buffer lines")

map("n", "<leader>sc", function()
  Snacks.picker.command_history()
end, "Command history")

map("n", "<leader>sC", function()
  Snacks.picker.commands()
end, "Commands")

map("n", "<leader>sh", function()
  Snacks.picker.help()
end, "Help pages")

map("n", "<leader>sH", function()
  Snacks.picker.highlights()
end, "Highlights")

map("n", "<leader>si", function()
  Snacks.picker.icons()
end, "Icons")

map("n", "<leader>sj", function()
  Snacks.picker.jumps()
end, "Jumps")

map("n", "<leader>sk", function()
  Snacks.picker.keymaps()
end, "Keymaps")

map("n", "<leader>sl", function()
  Snacks.picker.loclist()
end, "Location list")

map("n", "<leader>sm", function()
  Snacks.picker.marks()
end, "Marks")

map("n", "<leader>sM", function()
  Snacks.picker.man()
end, "Man pages")

map("n", "<leader>sq", function()
  Snacks.picker.qflist()
end, "Quickfix list")

map("n", "<leader>sR", function()
  Snacks.picker.resume()
end, "Resume picker")

map({ "n", "x" }, "<leader>sr", function()
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")

  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end, "Search and replace")

map("n", "<leader>su", function()
  local ok, err = pcall(vim.cmd.packadd, "nvim.undotree")
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  vim.cmd.Undotree()
end, "Undo history")

map("n", "<leader>uC", function()
  Snacks.picker.colorschemes()
end, "Colorschemes")

map("n", "<leader>z", function()
  Snacks.zen()
end, "Toggle zen mode")

map("n", "<leader>Z", function()
  Snacks.zen.zoom()
end, "Toggle zoom")

map("n", "<leader>.", function()
  Snacks.scratch()
end, "Toggle scratch buffer")

map("n", "<leader>S", function()
  Snacks.scratch.select()
end, "Select scratch buffer")

map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, "Delete buffer")

map("n", "<leader>cR", function()
  Snacks.rename.rename_file()
end, "Rename file")

map({ "n", "v" }, "<leader>gB", function()
  Snacks.gitbrowse()
end, "Git browse")

map({ "n", "v" }, "<leader>gY", function()
  Snacks.gitbrowse({
    what = "permalink",
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
  })
end, "Git browse copy permalink")

map("n", "<leader>un", function()
  Snacks.notifier.hide()
end, "Dismiss notifications")

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

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", {
  name = "Conceal level",
  off = 0,
  on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
}):map("<leader>uc")
Snacks.toggle.option("background", {
  name = "Dark background",
  off = "light",
  on = "dark",
}):map("<leader>ub")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.dim():map("<leader>uD")
