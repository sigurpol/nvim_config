vim.filetype.add({
  extension = {
    prdoc = "yaml",
  },
})

vim.diagnostic.config({
  severity_sort = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  virtual_lines = { current_line = true },
})

local function map(bufnr, mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { buffer = bufnr, desc = desc }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf

    map(bufnr, "n", "gd", vim.lsp.buf.definition, "Goto definition")
    map(bufnr, "n", "gD", vim.lsp.buf.declaration, "Goto declaration")
    map(bufnr, "n", "gr", vim.lsp.buf.references, "References", { nowait = true })
    map(bufnr, "n", "gI", vim.lsp.buf.implementation, "Goto implementation")
    map(bufnr, "n", "gy", vim.lsp.buf.type_definition, "Goto type definition")
    map(bufnr, "n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map(bufnr, "n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map(bufnr, "n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map(bufnr, "n", "<leader>ss", vim.lsp.buf.document_symbol, "Document symbols")
    map(bufnr, "n", "<leader>sS", vim.lsp.buf.workspace_symbol, "Workspace symbols")
    map(bufnr, "n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Next diagnostic")
    map(bufnr, "n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Previous diagnostic")

    if client and client:supports_method("textDocument/completion", bufnr) and vim.lsp.completion then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    if client and client:supports_method("textDocument/inlayHint", bufnr) and vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

vim.lsp.config("lua_ls", {
  -- Redirect log/cache to a writable dir; the binary lives under root-owned /opt
  -- and otherwise crashes on startup trying to create its cache there.
  cmd = {
    "lua-language-server",
    "--logpath=" .. vim.fn.stdpath("cache") .. "/lua-language-server/log",
    "--metapath=" .. vim.fn.stdpath("cache") .. "/lua-language-server/meta",
  },
  filetypes = { "lua" },
  root_markers = {
    { ".emmyrc.json", ".luarc.json", ".luarc.jsonc" },
    { ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml" },
    { ".git" },
  },
  settings = {
    Lua = {
      codeLens = { enable = true },
      diagnostics = {
        globals = { "Snacks", "vim" },
      },
      hint = { enable = true, semicolon = "Disable" },
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})

vim.lsp.config("yamlls", {
  cmd = function(dispatchers, config)
    local cmd = "yaml-language-server"
    if config and config.root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin", cmd)
      if vim.fn.executable(local_cmd) == 1 then
        cmd = local_cmd
      end
    end

    return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
  end,
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
  root_markers = { ".git" },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      format = { enable = true },
      validate = true,
      schemas = {
        ["/home/paolo/github/polkadot-sdk/prdoc/schema_user.json"] = "*polkadot-sdk*/**/*.prdoc",
      },
    },
  },
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = true
  end,
})

vim.lsp.config("harper_ls", {
  cmd = { "harper-ls", "--stdio" },
  filetypes = {
    "asciidoc",
    "c",
    "cpp",
    "cs",
    "gitcommit",
    "go",
    "html",
    "java",
    "javascript",
    "lua",
    "markdown",
    "nix",
    "python",
    "ruby",
    "rust",
    "swift",
    "tex",
    "toml",
    "typescript",
    "typescriptreact",
    "haskell",
    "cmake",
    "typst",
    "php",
    "dart",
    "clojure",
    "sh",
  },
  root_markers = { ".harper-dictionary.txt", ".git" },
  on_attach = function(client)
    local ns = vim.lsp.diagnostic.get_namespace(client.id)
    vim.diagnostic.config({
      signs = true,
      underline = true,
      virtual_text = false,
      virtual_lines = false,
    }, ns)
  end,
  settings = {
    ["harper-ls"] = {},
  },
})

local servers = { "lua_ls", "yamlls", "harper_ls" }

if vim.lsp.enable then
  vim.lsp.enable(servers)
end
