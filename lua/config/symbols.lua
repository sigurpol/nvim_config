-- Native symbol navigation/statusline glue.
-- Neovim exposes LSP document symbols via gO, but not ]f/[f motions or a
-- current-symbol statusline item, so this fills the motion gap without extra plugins.
local M = {}

local symbol_kind = vim.lsp.protocol.SymbolKind
local function_kinds = {
  [symbol_kind.Function] = true,
  [symbol_kind.Method] = true,
  [symbol_kind.Constructor] = true,
}

local function clients_with_symbols(bufnr)
  return vim.tbl_filter(function(client)
    return client:supports_method("textDocument/documentSymbol", bufnr)
  end, vim.lsp.get_clients({ bufnr = bufnr }))
end

local function position_before(a, b)
  return a.line < b.line or (a.line == b.line and a.character < b.character)
end

local function position_after(a, b)
  return a.line > b.line or (a.line == b.line and a.character > b.character)
end

local function normalize_symbol(item, out)
  local range = item.range or (item.location and item.location.range)
  if range and function_kinds[item.kind] then
    out[#out + 1] = {
      name = item.name,
      range = range,
    }
  end

  for _, child in ipairs(item.children or {}) do
    normalize_symbol(child, out)
  end
end

local function is_function_node(node)
  local node_type = node:type()

  if node_type:find("call") then
    return false
  end

  return node_type:find("function") ~= nil
    or node_type:find("method") ~= nil
    or node_type == "constructor_declaration"
    or node_type == "function_item"
end

local function add_treesitter_functions(node, out, seen)
  if is_function_node(node) then
    local start_line, start_character, end_line, end_character = node:range()
    local key = table.concat({ start_line, start_character, end_line, end_character }, ":")

    if not seen[key] then
      seen[key] = true
      out[#out + 1] = {
        range = {
          start = { line = start_line, character = start_character },
          ["end"] = { line = end_line, character = end_character },
        },
      }
    end
  end

  for child in node:iter_children() do
    add_treesitter_functions(child, out, seen)
  end
end

local function treesitter_symbols(bufnr)
  local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
  if not lang then
    return {}
  end

  local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_parser or not parser then
    return {}
  end

  local tree = parser:parse()[1]
  if not tree then
    return {}
  end

  local symbols = {}
  add_treesitter_functions(tree:root(), symbols, {})

  return symbols
end

local function document_symbols(bufnr)
  local symbols = {}

  if #clients_with_symbols(bufnr) > 0 then
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
    local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 1000) or {}

    for _, response in pairs(responses) do
      for _, item in ipairs(response.result or {}) do
        normalize_symbol(item, symbols)
      end
    end
  end

  if #symbols == 0 then
    symbols = treesitter_symbols(bufnr)
  end

  table.sort(symbols, function(a, b)
    return position_before(a.range.start, b.range.start)
  end)

  return symbols
end

local function jump_to(range, use_end)
  local pos = use_end and range["end"] or range.start
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(0, { pos.line + 1, pos.character })
end

local function jump_function(direction, use_end)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current = { line = cursor[1] - 1, character = cursor[2] }
  local symbols = document_symbols(bufnr)
  local candidate

  if direction > 0 then
    for _, item in ipairs(symbols) do
      local pos = use_end and item.range["end"] or item.range.start
      if position_after(pos, current) then
        candidate = item
        break
      end
    end
  else
    for i = #symbols, 1, -1 do
      local item = symbols[i]
      local pos = use_end and item.range["end"] or item.range.start
      if position_before(pos, current) then
        candidate = item
        break
      end
    end
  end

  if candidate then
    jump_to(candidate.range, use_end)
  else
    vim.notify("No " .. (direction > 0 and "next" or "previous") .. " function symbol", vim.log.levels.INFO)
  end
end

local function map(lhs, rhs, desc)
  vim.keymap.set({ "n", "x", "o" }, lhs, rhs, { desc = desc, silent = true })
end

map("]f", function()
  jump_function(1, false)
end, "Next function start")

map("[f", function()
  jump_function(-1, false)
end, "Previous function start")

map("]F", function()
  jump_function(1, true)
end, "Next function end")

map("[F", function()
  jump_function(-1, true)
end, "Previous function end")

function M.statusline()
  local parts = {
    "%<%f %h%w%m%r",
  }

  local diagnostics = vim.diagnostic.status()
  if diagnostics ~= "" then
    parts[#parts + 1] = " " .. diagnostics
  end

  parts[#parts + 1] = "%="

  parts[#parts + 1] = " %y %-14.(%l,%c%V%) %P"

  return table.concat(parts, "")
end

vim.o.statusline = "%!v:lua.require'config.symbols'.statusline()"

return M
