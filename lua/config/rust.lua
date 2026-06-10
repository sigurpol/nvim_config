local function client_request(client, method, params, handler)
  local request = client.request
  --[[@as fun(self: vim.lsp.Client, method: string, params: table?, handler: lsp.Handler, bufnr?: integer): boolean, integer?]]

  return request(client, method, params, handler, 0)
end

local function expand_macro()
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "rust_analyzer" })
  if #clients == 0 then
    vim.notify("rust-analyzer not attached", vim.log.levels.ERROR)
    return
  end

  local client = clients[1]

  client_request(
    client,
    "rust-analyzer/expandMacro",
    vim.lsp.util.make_position_params(0, client.offset_encoding),
    function(err, result)
      if result and result.expansion then
        local buf = vim.api.nvim_create_buf(false, true)
        local lines = vim.split(result.expansion, "\n")
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].filetype = "rust"

        vim.cmd("vsplit")
        vim.api.nvim_win_set_buf(0, buf)
        return
      end

      if err then
        vim.notify(
          string.format(
            "Error expanding macro (code: %s): %s",
            err.code or "unknown",
            err.message or vim.inspect(err)
          ),
          vim.log.levels.ERROR
        )
        return
      end

      vim.notify("No macro to expand at cursor position", vim.log.levels.WARN)
    end
  )
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    vim.keymap.set("n", "<leader>me", expand_macro, {
      buffer = ev.buf,
      desc = "Expand Rust macro",
    })
  end,
})

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  -- CHALK_* are read by the rust-analyzer process itself, so they go in the
  -- spawn environment, not in settings.
  cmd_env = {
    CHALK_OVERFLOW_DEPTH = "100000000",
    CHALK_SOLVER_MAX_SIZE = "100000000",
  },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        extraEnv = {
          SKIP_WASM_BUILD = "1",
          CARGO_INCREMENTAL = "0", -- stop RA from writing the incremental cache
        },
        features = "all",
      },
      diagnostics = {
        disabled = { "macro-error" },
      },
      procMacro = {
        ignored = {
          ["async-recursion"] = { "async_recursion" },
          ["async-std"] = { "async_std" },
          ["async-trait"] = { "async_trait" },
          ["napi-derive"] = { "napi" },
        },
      },
      rust = {
        analyzerTargetDir = "target/rust-analyzer",
      },
      rustfmt = {
        extraArgs = { "+nightly" },
      },
    },
  },
})

vim.lsp.enable("rust_analyzer")
