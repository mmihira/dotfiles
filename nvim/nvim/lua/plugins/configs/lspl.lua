local api = vim.api
local lsp = require("vim.lsp")
local M = {}

local show_client_capabilities = function(client)
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event
  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
    },
    position = "50%",
    size = {
      width = "80%",
      height = "60%",
    },
  })
  popup:mount()
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  local content = vim.inspect(client.server_capabilities)
  lines = {}
  for string in content:gmatch("[^\r\n]+") do
    table.insert(lines, string)
  end
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, 2, false, { "Client Capabilities", "-------------------------------" })
  vim.api.nvim_buf_set_lines(popup.bufnr, 3, 4, false, lines)
end

local function find_symbol_position(bufnr, symbol_name)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    local col = line:find(symbol_name, 1, true)
    if col then
      return i - 1, col - 1 -- Convert to 0-based for LSP
    end
  end
  return nil, nil
end

local function find_ref_by_symbol(client, bufnr, symbol_name)
  if not client.supports_method("textDocument/implementation") then
    vim.notify(
      string.format("LSP client %s does not support textDocument/implementation", client.name),
      vim.log.levels.WARN
    )
    return
  end

  -- Find the symbol's position
  local line, col = find_symbol_position(bufnr, symbol_name)
  if not line or not col then
    vim.notify(string.format("Symbol %s not found in buffer", symbol_name), vim.log.levels.ERROR)
    return
  end
  require("notify")("Found symbol " .. symbol_name .. " at line " .. line .. ", col " .. col)

  -- Construct parameters
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    position = { line = line, character = col },
  }

  -- Handler to populate quickfix list
  local handler = function(err, result, ctx, config)
    if err then
      vim.notify("Error fetching implementations: " .. err.message, vim.log.levels.ERROR)
      return
    end
    if not result or vim.tbl_isempty(result) then
      vim.notify(string.format("No implementations found for %s", symbol_name), vim.log.levels.INFO)
      return
    end

    -- Print each reference
    for i, loc in ipairs(result) do
      local uri = loc.uri or loc.targetUri
      local range = loc.range or loc.targetSelectionRange
      local filename = vim.uri_to_fname(uri)
      local line = range.start.line + 1  -- Convert to 1-based
      local col = range.start.character + 1 -- Convert to 1-based
      local text = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range.start.line + 1, false)[1] or ""
      vim.notify(string.format("Reference %d: %s:%d:%d - %s", i, filename, line, col, text), vim.log.levels.INFO)
    end
  end

  -- Send request
  client.request("textDocument/references", params, handler, bufnr)
end

local key_mappings = {
  { "documentFormattingProvider", "n",          "<space>lf",  "<Cmd>lua vim.lsp.buf.format()<CR>" },
  -- { "documentRangeFormattingProvider", "v", "gq", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>" },
  -- { "referencesProvider", "n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>" }, :Ref in telescope
  { "hoverProvider",              "n",          "K",          "<Cmd>lua vim.lsp.buf.hover()<CR>" },
  { "implementation",             "n",          "<space>gi",  "<Cmd>lua vim.lsp.buf.implementation()<CR>" },
  { "definitionProvider",         "n",          "gd",         "<Cmd>lua vim.lsp.buf.definition()<CR>" },
  -- { "signatureHelpProvider", "i", "<c-space>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>" },
  { "renameProvider",             "n",          "<space>rn",  "<cmd>lua vim.lsp.buf.rename()<cr>" },
  -- { "workspaceSymbolProvider", "n", "gW", "<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>" },
  { "codeActionProvider",         { "n", "v" }, "<leader>cl", "<Cmd>lua vim.lsp.buf.code_action()<CR>" },
  -- { "codeActionProvider", "n", "<leader>r", "<Cmd>lua vim.lsp.buf.code_action { only = 'refactor' }<CR>" },
}

local function on_attach(client, bufnr, attach_opts)
  api.nvim_buf_set_var(bufnr, "lsp_client_id", client.id)
  api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  api.nvim_buf_set_option(bufnr, "bufhidden", "hide")

  vim.api.nvim_create_user_command("ClientCapabilities", function(opts)
    show_client_capabilities(client)
  end, { nargs = 0 })

  vim.api.nvim_create_user_command("Test", function(opts)
    require("notify")("Here")

    local bufnr = vim.api.nvim_get_current_buf()

    find_ref_by_symbol(client, bufnr, "boundingBox")
  end, { nargs = 0 })

  if client.server_capabilities.goto_definition then
    api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
  end

  local opts = { silent = true, buffer = bufnr }
  for _, mappings in pairs(key_mappings) do
    local capability, mode, lhs, rhs = unpack(mappings)
    if client.server_capabilities[capability] then
      vim.keymap.set(mode, lhs, rhs, opts)
    end
  end

  -- On hover over syntax highlight the term
  vim.cmd("augroup lsp_aucmds")
  vim.cmd(string.format("au! * <buffer=%d>", bufnr))
  if client.server_capabilities["documentHighlightProvider"] then
    vim.cmd(string.format("au CursorHold  <buffer=%d> lua vim.lsp.buf.document_highlight()", bufnr))
    vim.cmd(string.format("au CursorHoldI <buffer=%d> lua vim.lsp.buf.document_highlight()", bufnr))
    vim.cmd(string.format("au CursorMoved <buffer=%d> lua vim.lsp.buf.clear_references()", bufnr))
  end

  if vim.lsp.codelens and client.server_capabilities["codeLensProvider"] then
    api.nvim_buf_set_keymap(bufnr, "n", "<leader>cr", "<Cmd>lua vim.lsp.codelens.refresh()<CR>", { silent = true })
  end
  vim.cmd("augroup end")
end

M.on_attach = on_attach

local function on_init(client)
  if client.config.settings then
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  end
end

local function on_exit(client, bufnr)
  require("me.lsp.ext").detach(client.id, bufnr)
  vim.cmd("augroup lsp_aucmds")
  vim.cmd(string.format("au! * <buffer=%d>", bufnr))
  vim.cmd("augroup end")
end

local function mk_config()
  local capabilities = lsp.protocol.make_client_capabilities()
  capabilities.workspace.configuration = true
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return {
    flags = {
      debounce_text_changes = 80,
      allow_incremental_sync = true,
    },
    handlers = {},
    capabilities = capabilities,
    on_init = on_init,
    on_attach = on_attach,
    on_exit = on_exit,
    init_options = {},
    settings = {},
  }
end

M.mk_config = mk_config

return M
