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
  virtual_text = {
    source = "if_many",
    spacing = 4,
  },
})

local function picker(name, fallback)
  return function()
    if Snacks and Snacks.picker and Snacks.picker[name] then
      Snacks.picker[name]()
      return
    end

    fallback()
  end
end

local function map(bufnr, mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { buffer = bufnr, desc = desc }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf

    map(bufnr, "n", "gd", picker("lsp_definitions", vim.lsp.buf.definition), "Goto definition")
    map(bufnr, "n", "gD", picker("lsp_declarations", vim.lsp.buf.declaration), "Goto declaration")
    map(bufnr, "n", "gr", picker("lsp_references", vim.lsp.buf.references), "References", { nowait = true })
    map(bufnr, "n", "gI", picker("lsp_implementations", vim.lsp.buf.implementation), "Goto implementation")
    map(bufnr, "n", "gy", picker("lsp_type_definitions", vim.lsp.buf.type_definition), "Goto type definition")
    map(bufnr, "n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map(bufnr, "n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map(bufnr, "n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map(bufnr, "n", "<leader>ss", picker("lsp_symbols", vim.lsp.buf.document_symbol), "Document symbols")
    map(bufnr, "n", "<leader>sS", picker("lsp_workspace_symbols", vim.lsp.buf.workspace_symbol), "Workspace symbols")
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
  settings = {
    Lua = {
      diagnostics = {
        globals = { "Snacks", "vim" },
      },
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
  filetypes = { "yaml" },
  settings = {
    validate = true,
    yaml = {
      schemas = {
        ["/home/paolo/github/polkadot-sdk/prdoc/schema_user.json"] = "*polkadot-sdk*/**/*.prdoc",
      },
    },
  },
})

vim.lsp.config("harper_ls", {
  on_attach = function(client)
    local ns = vim.lsp.diagnostic.get_namespace(client.id)
    vim.diagnostic.config({
      signs = true,
      underline = true,
      virtual_text = false,
    }, ns)
  end,
  settings = {
    ["harper-ls"] = {},
  },
})

local servers = { "lua_ls", "yamlls", "harper_ls" }

local ok_mason, mason = pcall(require, "mason")
if ok_mason then
  mason.setup({
    ui = {
      border = "rounded",
    },
  })
end

local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok_mason_lspconfig then
  mason_lspconfig.setup({
    ensure_installed = servers,
    automatic_enable = {
      exclude = { "rust_analyzer" },
    },
  })
end

if vim.lsp.enable then
  vim.lsp.enable(servers)
end
