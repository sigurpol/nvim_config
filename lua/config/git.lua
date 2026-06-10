local function map(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { desc = desc, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then
  gitsigns.setup({
    current_line_blame = true,
  })
end

-- map("n", "<leader>gs", "<cmd>Git<cr>", "Git status")
map("n", "<leader>gb", "<cmd>Git blame<cr>", "Git commit")
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
