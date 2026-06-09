local M = {}

local terminal_buf
local terminal_job

local function git_root()
  local file = vim.api.nvim_buf_get_name(0)
  local cwd = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
  local root = vim.fn.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })

  return vim.v.shell_error == 0 and vim.trim(root) or vim.fn.getcwd()
end

local function terminal_window()
  if not terminal_buf or not vim.api.nvim_buf_is_valid(terminal_buf) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == terminal_buf then
      return win
    end
  end
end

local function hide_terminal_window(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end

  if #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.api.nvim_win_close(win, true)
    return
  end

  vim.api.nvim_set_current_win(win)

  local alternate = vim.fn.bufnr("#")
  if alternate > 0 and alternate ~= terminal_buf and vim.api.nvim_buf_is_valid(alternate) then
    vim.api.nvim_win_set_buf(win, alternate)
  else
    vim.cmd.enew()
  end
end

local function cleanup_terminal_buffer(buf, job)
  vim.schedule(function()
    if job ~= terminal_job or buf ~= terminal_buf or not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(win) == buf then
        hide_terminal_window(win)
      end
    end

    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end

    terminal_buf = nil
    terminal_job = nil
  end)
end

local function terminal_height()
  return math.max(1, math.floor(vim.o.lines / 2))
end

local function create_terminal_buffer()
  terminal_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, terminal_buf)
  vim.bo[terminal_buf].bufhidden = "hide"
  vim.bo[terminal_buf].buflisted = false
  vim.bo[terminal_buf].swapfile = false

  local buf = terminal_buf
  terminal_job = vim.fn.jobstart(vim.o.shell, {
    cwd = git_root(),
    term = true,
    on_exit = function(job)
      cleanup_terminal_buffer(buf, job)
    end,
  })

  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
    buffer = terminal_buf,
    desc = "Terminal normal mode",
  })
end

local function open_terminal_window()
  vim.cmd("botright split")
  vim.api.nvim_win_set_height(0, terminal_height())

  if not terminal_buf or not vim.api.nvim_buf_is_valid(terminal_buf) then
    create_terminal_buffer()
  else
    vim.api.nvim_win_set_buf(0, terminal_buf)
  end
end

function M.toggle()
  local win = terminal_window()
  if win then
    hide_terminal_window(win)
    return
  end

  open_terminal_window()
  vim.cmd.startinsert()
end

vim.keymap.set({ "n", "t" }, "<C-`>", M.toggle, { desc = "Terminal" })
vim.keymap.set({ "n", "t" }, "<C-/>", M.toggle, { desc = "Terminal" })
vim.keymap.set({ "n", "t" }, "<C-_>", M.toggle, { desc = "Terminal" })

return M
