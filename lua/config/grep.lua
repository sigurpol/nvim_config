local M = {}

local function open_qf()
  if vim.tbl_isempty(vim.fn.getqflist()) then
    vim.notify("grep: no matches", vim.log.levels.WARN)
  else
    vim.cmd.copen()
  end
end

-- ripgrep (via 'grepprg') into the quickfix list. `pattern` is a regex; `files`,
-- when given, restricts the search to those paths.
function M.grep(pattern, files)
  if not pattern or pattern == "" then
    return
  end

  local args = { vim.fn.shellescape(pattern, true) }
  for _, file in ipairs(files or {}) do
    args[#args + 1] = vim.fn.shellescape(file)
  end

  vim.cmd("silent grep! " .. table.concat(args, " "))
  open_qf()
end

function M.prompt(files)
  vim.ui.input({ prompt = "grep: " }, function(pattern)
    M.grep(pattern, files)
  end)
end

local function cword_or_selection()
  local mode = vim.fn.mode()
  if mode:match("[vV\22]") then
    local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    return region[1] or ""
  end

  return vim.fn.expand("<cword>")
end

function M.word()
  M.grep(cword_or_selection())
end

local function listed_buffer_files()
  local files = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.fn.filereadable(name) == 1 then
        files[#files + 1] = name
      end
    end
  end

  return files
end

function M.buffers()
  local files = listed_buffer_files()
  if #files == 0 then
    vim.notify("grep: no listed buffers with files", vim.log.levels.WARN)
    return
  end

  M.prompt(files)
end

-- Search lines in the current buffer (Vim regex, honours unsaved changes).
function M.buffer_lines()
  vim.ui.input({ prompt = "buffer lines: " }, function(pattern)
    if not pattern or pattern == "" then
      return
    end

    vim.cmd("silent vimgrep /" .. pattern:gsub("/", "\\/") .. "/gj %")
    open_qf()
  end)
end

local map = vim.keymap.set
map("n", "<leader>/", function()
  M.prompt()
end, { desc = "Grep" })
map({ "n", "x" }, "<leader>sw", function()
  M.word()
end, { desc = "Grep word/selection" })
map("n", "<leader>sB", function()
  M.buffers()
end, { desc = "Grep open buffers" })
map("n", "<leader>sb", function()
  M.buffer_lines()
end, { desc = "Buffer lines" })

return M
