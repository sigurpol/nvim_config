local function map(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { desc = desc, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then
  gitsigns.setup({
    current_line_blame = true,
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "^" },
      changedelete = { text = "~" },
      untracked = { text = "?" },
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function bmap(mode, lhs, rhs, desc)
        map(mode, lhs, rhs, desc, { buffer = buffer })
      end

      bmap("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next hunk")

      bmap("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Previous hunk")

      bmap("n", "]H", function()
        gs.nav_hunk("last")
      end, "Last hunk")

      bmap("n", "[H", function()
        gs.nav_hunk("first")
      end, "First hunk")

      bmap({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<cr>", "Stage hunk")
      bmap({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<cr>", "Reset hunk")
      bmap("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
      bmap("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
      bmap("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
      bmap("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk")
      bmap("n", "<leader>ghb", function()
        gs.blame_line({ full = true })
      end, "Blame line")
      bmap("n", "<leader>ghB", gs.blame, "Blame buffer")
      bmap("n", "<leader>ghd", gs.diffthis, "Diff this")
      bmap("n", "<leader>ghD", function()
        gs.diffthis("~")
      end, "Diff this against HEAD")
      bmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", "Select hunk")
    end,
  })
end

-- map("n", "<leader>gs", "<cmd>Git<cr>", "Git status")
map("n", "<leader>gb", "<cmd>Git blame<cr>", "Git commit")
map("n", "<leader>gc", "<cmd>Git commit<cr>", "Git commit")
map("n", "<leader>gP", "<cmd>Git push<cr>", "Git push")
map("n", "<leader>gp", "<cmd>Git pull<cr>", "Git pull")
map("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", "Diffview open")
map("n", "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", "Current file history")
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", "Diffview close")

local function git_root()
  local file = vim.api.nvim_buf_get_name(0)
  local cwd = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
  local root = vim.fn.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })

  return vim.v.shell_error == 0 and vim.trim(root) or vim.fn.getcwd()
end

map("n", "<leader>gg", function()
  Snacks.lazygit({ cwd = git_root() })
end, "Lazygit")

local function snacks_picker(name, fallback)
  return function()
    if Snacks and Snacks.picker and Snacks.picker[name] then
      Snacks.picker[name]()
      return
    end

    if fallback then
      vim.cmd(fallback)
    end
  end
end

map("n", "<leader>gB", snacks_picker("git_branches"), "Git branches")
map("n", "<leader>gd", snacks_picker("git_diff", "DiffviewOpen"), "Git diff")
map("n", "<leader>gf", snacks_picker("git_log_file", "DiffviewFileHistory %"), "Git file history")
map("n", "<leader>gl", snacks_picker("git_log"), "Git log")
map("n", "<leader>gL", snacks_picker("git_log_line"), "Git log line")
map("n", "<leader>gs", snacks_picker("git_status", "Git"), "Git status")
map("n", "<leader>gS", snacks_picker("git_stash"), "Git stash")
