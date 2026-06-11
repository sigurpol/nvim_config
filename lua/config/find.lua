local M = {}

local cache = {
  cwd = nil,
  files = nil,
}

local function lines(result)
  if not result or result.code ~= 0 or not result.stdout then
    return nil
  end

  return vim.split(result.stdout, "\n", { trimempty = true })
end

local function systemlist(cmd, opts)
  return lines(vim.system(cmd, vim.tbl_extend("force", { text = true }, opts or {})):wait())
end

local function git_root(cwd)
  local out = systemlist({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd })
  return out and out[1] or nil
end

local function relative_to_cwd(root, file)
  local full = vim.fs.joinpath(root, file)
  return vim.fs.relpath(assert(vim.uv.cwd()), full) or full
end

local function project_files()
  local cwd = vim.uv.cwd()
  if cache.cwd == cwd and cache.files then
    return cache.files
  end

  local root = git_root(cwd)
  local files

  if root then
    local git_files = systemlist({ "git", "ls-files", "--cached", "--others", "--exclude-standard" }, { cwd = root })
    if git_files then
      files = vim.tbl_map(function(file)
        return relative_to_cwd(root, file)
      end, git_files)
    end
  else
    files = systemlist({ "rg", "--files", "--hidden", "--glob", "!.git" }, { cwd = cwd })
  end

  cache.cwd = cwd
  cache.files = files or {}

  return cache.files
end

function M.findfunc(arg)
  local files = project_files() or {}
  if arg == "" then
    return files
  end

  return vim.fn.matchfuzzy(files, arg)
end

function M.open()
  vim.fn.feedkeys(":find ", "n")
end

vim.opt.findfunc = "v:lua.require'config.find'.findfunc"
vim.opt.wildmode = "noselect:lastused,full"

vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    cache.cwd = nil
    cache.files = nil
  end,
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = ":",
  callback = function()
    local line = vim.fn.getcmdline()
    local arg = line:match("^find%s+(.+)$") or line:match("^fin%s+(.+)$")
    if arg and #vim.trim(arg) >= 2 then
      vim.fn.wildtrigger()
    end
  end,
})

vim.keymap.set("n", "<leader><space>", M.open, { desc = "Find file" })

return M
