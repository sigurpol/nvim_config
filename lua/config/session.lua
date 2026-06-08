local M = {}

local session_dir = vim.fs.joinpath(vim.fn.stdpath("state"), "sessions")
local last_session_file = vim.fs.joinpath(session_dir, "last")
local save_enabled = true

local function session_id(cwd)
  return vim.fn.sha256(vim.fn.fnamemodify(cwd, ":p"))
end

local function session_path(cwd)
  return vim.fs.joinpath(session_dir, session_id(cwd) .. ".vim")
end

local function cwd_path(path)
  local metadata_path = path:gsub("%.vim$", ".cwd")
  return metadata_path
end

local function ensure_session_dir()
  vim.fn.mkdir(session_dir, "p")
end

local function current_session_path()
  return session_path(vim.fn.getcwd())
end

local function has_listed_file_buffer()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= "" then
      return true
    end
  end

  return false
end

local function read_first_line(path)
  if not path or vim.fn.filereadable(path) == 0 then
    return nil
  end

  local lines = vim.fn.readfile(path, "", 1)
  return lines[1]
end

function M.save()
  if not save_enabled or not has_listed_file_buffer() then
    return
  end

  ensure_session_dir()

  local path = current_session_path()
  vim.cmd("silent! mksession! " .. vim.fn.fnameescape(path))
  vim.fn.writefile({ path }, last_session_file)
  vim.fn.writefile({ vim.fn.getcwd() }, cwd_path(path))
end

function M.load(opts)
  opts = opts or {}

  local path = opts.path
  if opts.last then
    path = read_first_line(last_session_file)
  end

  path = path or current_session_path()

  if not path or vim.fn.filereadable(path) == 0 then
    vim.notify("No session found", vim.log.levels.WARN)
    return
  end

  vim.cmd("silent! source " .. vim.fn.fnameescape(path))
  ensure_session_dir()
  vim.fn.writefile({ path }, last_session_file)
end

function M.select()
  ensure_session_dir()

  local sessions = vim.fn.glob(vim.fs.joinpath(session_dir, "*.vim"), false, true)
  table.sort(sessions, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)

  if #sessions == 0 then
    vim.notify("No sessions found", vim.log.levels.WARN)
    return
  end

  vim.ui.select(sessions, {
    prompt = "Select session",
    format_item = function(path)
      return read_first_line(cwd_path(path)) or vim.fn.fnamemodify(path, ":t")
    end,
  }, function(path)
    if path then
      M.load({ path = path })
    end
  end)
end

function M.stop()
  save_enabled = false
  vim.notify("Session saving disabled for this instance", vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = M.save,
})

vim.keymap.set("n", "<leader>qs", function()
  M.load()
end, { desc = "Restore session" })

vim.keymap.set("n", "<leader>qS", M.select, { desc = "Select session" })

vim.keymap.set("n", "<leader>ql", function()
  M.load({ last = true })
end, { desc = "Restore last session" })

vim.keymap.set("n", "<leader>qd", M.stop, { desc = "Do not save current session" })

return M
