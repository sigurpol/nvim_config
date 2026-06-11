local function map(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { desc = desc, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- map("n", "<leader>gs", "<cmd>Git<cr>", "Git status")
map("n", "<leader>gb", "<cmd>Git blame<cr>", "Git blame")
map("n", "<leader>gc", "<cmd>Git commit<cr>", "Git commit")
map("n", "<leader>gP", "<cmd>Git push<cr>", "Git push")
map("n", "<leader>gp", "<cmd>Git pull<cr>", "Git pull")
map("n", "<leader>gD", "<cmd>Gvdiffsplit<cr>", "Diff current file")
map("n", "<leader>gF", "<cmd>0Gclog<cr>", "Current file history")

local function git_root()
  local file = vim.api.nvim_buf_get_name(0)
  local cwd = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
  local root = vim.fn.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })

  return vim.v.shell_error == 0 and vim.trim(root) or vim.fn.getcwd()
end

map("n", "<leader>gg", function()
  require("config.terminal").run({ "lazygit" }, { cwd = git_root() })
end, "Lazygit")

-- Cursor line, or "start-end" for a visual selection.
local function line_spec()
  if vim.fn.mode():match("[vV\22]") then
    local first, last = vim.fn.line("v"), vim.fn.line(".")
    if first > last then
      first, last = last, first
    end
    if first ~= last then
      return first .. "-" .. last
    end
    return tostring(first)
  end

  return tostring(vim.fn.line("."))
end

local function current_branch(root)
  local r = vim.system({ "git", "-C", root, "branch", "--show-current" }, { text = true }):wait()
  return r.code == 0 and vim.trim(r.stdout) or ""
end

-- Browse the current file/line(s) on GitHub via the `gh` CLI (GitHub-only).
-- `gB` opens the current branch; `gY` copies a commit-pinned permalink.
local function gh_browse(opts)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return
  end

  local root = git_root()
  local cmd = { "gh", "browse" }
  if opts.permalink then
    vim.list_extend(cmd, { "-n", "-c" })
  else
    local branch = current_branch(root)
    vim.list_extend(cmd, branch ~= "" and { "-b", branch } or { "-c" })
  end
  cmd[#cmd + 1] = (vim.fs.relpath(root, file) or file) .. ":" .. line_spec()

  local result = vim.system(cmd, { cwd = root, text = true }):wait()
  if result.code ~= 0 then
    vim.notify("gh browse: " .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
  elseif opts.permalink then
    local url = vim.trim(result.stdout)
    vim.fn.setreg("+", url)
    vim.notify("Copied permalink: " .. url)
  end
end

map({ "n", "x" }, "<leader>gB", function()
  gh_browse({})
end, "Git browse")

map({ "n", "x" }, "<leader>gY", function()
  gh_browse({ permalink = true })
end, "Git browse copy permalink")
