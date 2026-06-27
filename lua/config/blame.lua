-- Native inline current-line git blame (equivalent of gitsigns current_line_blame).
local ns = vim.api.nvim_create_namespace("inline_blame")
local timer = assert(vim.uv.new_timer())
local delay = 500
local max_lines = 20000

-- Resolved once, asynchronously (avoids a blocking :wait in the fast blame callback).
local user_email = ""
vim.system({ "git", "config", "user.email" }, { text = true }, function(r)
  if r.code == 0 then
    user_email = vim.trim(r.stdout)
  end
end)

local function relative_time(ts)
  local diff = os.time() - ts
  local units = {
    { 31536000, "year" },
    { 2592000,  "month" },
    { 604800,   "week" },
    { 86400,    "day" },
    { 3600,     "hour" },
    { 60,       "minute" },
  }
  for _, u in ipairs(units) do
    if diff >= u[1] then
      local n = math.floor(diff / u[1])
      return ("%d %s%s ago"):format(n, u[2], n > 1 and "s" or "")
    end
  end
  return "just now"
end

local function clear(buf)
  vim.api.nvim_buf_clear_namespace(buf or 0, ns, 0, -1)
end

local function show()
  if vim.fn.mode() ~= "n" then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_line_count(buf) > max_lines then
    return
  end

  -- Only blame real on-disk files (skips fugitive://, unnamed, etc.).
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" or vim.fn.filereadable(file) == 0 then
    return
  end

  local lnum = vim.fn.line(".")
  local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"

  vim.system({
    "git",
    "blame",
    "--contents",
    "-",
    "-L",
    lnum .. "," .. lnum,
    "--porcelain",
    "--",
    file,
  }, { cwd = vim.fs.dirname(file), stdin = content, text = true }, function(result)
    if result.code ~= 0 or not result.stdout then
      return
    end

    local out = result.stdout
    local sha = out:match("^(%x+)")
    if not sha or sha:match("^0+$") then
      return -- uncommitted line
    end

    local author = out:match("\nauthor (.-)\n")
    local mail = out:match("\nauthor%-mail <(.-)>\n")
    local time = tonumber(out:match("\nauthor%-time (%d+)"))
    local summary = out:match("\nsummary (.-)\n")
    if not (author and time and summary) then
      return
    end

    if mail and mail == user_email then
      author = "You"
    end

    vim.schedule(function()
      if vim.api.nvim_get_current_buf() ~= buf or vim.fn.line(".") ~= lnum then
        return
      end
      clear(buf)
      vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0, {
        virt_text = { { (" %s, %s - %s"):format(author, relative_time(time), summary), "Comment" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
      })
    end)
  end)
end

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    clear()
    timer:stop()
    timer:start(delay, 0, vim.schedule_wrap(show))
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave" }, {
  callback = function()
    timer:stop()
    clear()
  end,
})
