-- Delete the current buffer while preserving the window layout.
local function bufdelete()
  local buf = vim.api.nvim_get_current_buf()

  if vim.bo[buf].modified then
    local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname(buf)), "&Yes\n&No\n&Cancel")
    if choice == 0 or choice == 3 then
      return
    elseif choice == 1 then
      vim.cmd.write()
    end
  end

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
        return
      end

      local alt = vim.fn.bufnr("#")
      if alt ~= buf and alt ~= -1 and vim.fn.buflisted(alt) == 1 then
        vim.api.nvim_win_set_buf(win, alt)
        return
      end

      pcall(vim.cmd, "bprevious")
      if vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
      end
    end)
  end

  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

vim.keymap.set("n", "<leader>bd", bufdelete, { desc = "Delete buffer" })
