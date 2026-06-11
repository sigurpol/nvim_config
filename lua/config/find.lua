local M = {}

-- name -> { key = <cwd|dir>, files = {...} }
local caches = {}

local function lines(result)
  if not result or result.code ~= 0 or not result.stdout then
    return nil
  end

  return vim.split(result.stdout, "\n", { trimempty = true })
end

local function systemlist(cmd, opts)
  return lines(vim.system(cmd, vim.tbl_extend("force", { text = true }, opts or {})):wait())
end

local function cached(name, key, build)
  local c = caches[name]
  if c and c.key == key then
    return c.files
  end

  local files = build() or {}
  caches[name] = { key = key, files = files }

  return files
end

local function git_root(cwd)
  local out = systemlist({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd })
  return out and out[1] or nil
end

local function relative_to_cwd(root, file)
  local full = vim.fs.joinpath(root, file)
  return vim.fs.relpath(assert(vim.uv.cwd()), full) or full
end

-- Tracked (and optionally untracked) files, as paths relative to cwd.
local function git_ls(cwd, args)
  local root = git_root(cwd)
  if not root then
    return nil
  end

  local out = systemlist(vim.list_extend({ "git", "ls-files" }, args), { cwd = root })
  return out
    and vim.tbl_map(function(file)
      return relative_to_cwd(root, file)
    end, out)
end

-- Absolute paths of files under dir, git-aware.
local function list_dir(dir)
  local rel = systemlist({ "git", "ls-files", "--cached", "--others", "--exclude-standard" }, { cwd = dir })
    or systemlist({ "rg", "--files", "--hidden", "--glob", "!.git" }, { cwd = dir })

  return vim.tbl_map(function(file)
    return vim.fs.joinpath(dir, file)
  end, rel or {})
end

M.sources = {
  files = function()
    local cwd = assert(vim.uv.cwd())
    return cached("files", cwd, function()
      return git_ls(cwd, { "--cached", "--others", "--exclude-standard" })
        or systemlist({ "rg", "--files", "--hidden", "--glob", "!.git" }, { cwd = cwd })
    end)
  end,

  git = function()
    local cwd = assert(vim.uv.cwd())
    return cached("git", cwd, function()
      return git_ls(cwd, {}) or {}
    end)
  end,

  config = function()
    local dir = vim.fn.stdpath("config")
    return cached("config", dir, function()
      return list_dir(dir)
    end)
  end,
}

local active = "files"

function M.findfunc(arg)
  local files = M.sources[active]() or {}
  if arg == "" then
    return files
  end

  return vim.fn.matchfuzzy(files, arg)
end

function M.find(source)
  active = source or "files"
  vim.fn.feedkeys(":find ", "n")
end

vim.opt.findfunc = "v:lua.require'config.find'.findfunc"
vim.opt.wildmode = "noselect:lastused,full"

vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    caches = {}
  end,
})

-- Commands whose completion popup auto-opens once the argument is non-trivial.
-- Other modules (see config.pickers) extend this set.
M.cmdline_commands = { find = true, fin = true, buffer = true, buf = true, b = true }

vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = ":",
  callback = function()
    local cmd, arg = vim.fn.getcmdline():match("^(%S+)%s+(.+)$")
    if cmd and M.cmdline_commands[cmd] and #vim.trim(arg) >= 2 then
      vim.fn.wildtrigger()
    end
  end,
})

local map = vim.keymap.set
map("n", "<leader><space>", function()
  M.find("files")
end, { desc = "Find file" })
map("n", "<leader>ff", function()
  M.find("files")
end, { desc = "Find files" })
map("n", "<leader>fg", function()
  M.find("git")
end, { desc = "Find git files" })
map("n", "<leader>fc", function()
  M.find("config")
end, { desc = "Find config file" })
local function buffers()
  vim.fn.feedkeys(":buffer ", "n")
end
map("n", "<leader>fb", buffers, { desc = "Buffers" })
map("n", "<leader>,", buffers, { desc = "Buffers" })

return M
