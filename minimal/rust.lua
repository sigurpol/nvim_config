local function expand_macro()
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "rust-analyzer" })
  if #clients == 0 then
    vim.notify("rust-analyzer not attached", vim.log.levels.ERROR)
    return
  end

  local client = clients[1]
  client.request(
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

vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          extraEnv = {
            SKIP_WASM_BUILD = "1",
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
        server = {
          extraEnv = {
            CHALK_OVERFLOW_DEPTH = "100000000",
            CHALK_SOLVER_MAX_SIZE = "100000000",
          },
        },
      },
    },
  },
}
