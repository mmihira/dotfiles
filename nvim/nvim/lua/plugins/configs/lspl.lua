local api = vim.api
local lsp = require("vim.lsp")
local M = {}

local key_mappings = {
  { "documentFormattingProvider", "n", "<space>lf", "<Cmd>lua vim.lsp.buf.format()<CR>" },
  { "documentRangeFormattingProvider", "v", "gq", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>" },
  -- { "referencesProvider", "n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>" }, :Ref in telescope
  { "hoverProvider", "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>" },
  { "implementation", "n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>" },
  { "definitionProvider", "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>" },
  -- { "signatureHelpProvider", "i", "<c-space>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>" },
  { "workspaceSymbolProvider", "n", "gW", "<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>" },
  { "codeActionProvider", "n", "<leader>cl", "<Cmd>lua vim.lsp.buf.code_action()<CR>" },
  -- { "codeActionProvider", "n", "<leader>r", "<Cmd>lua vim.lsp.buf.code_action { only = 'refactor' }<CR>" },
  -- { "codeActionProvider", "v", "<a-CR>", "<Esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>" },
  -- { "codeActionProvider", "v", "<leader>r", "<Esc><Cmd>lua vim.lsp.buf.range_code_action { only = 'refactor'}<CR>" },
}

local function on_attach(client, bufnr, attach_opts)
  api.nvim_buf_set_var(bufnr, "lsp_client_id", client.id)
  api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  api.nvim_buf_set_option(bufnr, "bufhidden", "hide")

  vim.api.nvim_create_user_command("ClientCapabilities", function(opts)
    print(vim.inspect(client.server_capabilities))
  end, { nargs = 0 })

  if client.server_capabilities.goto_definition then
    api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
  end

  local opts = { silent = true }
  for _, mappings in pairs(key_mappings) do
    local capability, mode, lhs, rhs = unpack(mappings)
    if client.server_capabilities[capability] then
      api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end
  end

  api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<Cmd>lua vim.lsp.buf.rename(vim.fn.input('New Name: '))<CR>", opts)
  -- api.nvim_buf_set_keymap(bufnr, "i", "<c-n>", "<Cmd>lua require('lsp_compl').trigger_completion()<CR>", opts)

  -- On hover over syntax highlight the term
  vim.cmd("augroup lsp_aucmds")
  vim.cmd(string.format("au! * <buffer=%d>", bufnr))
  if client.server_capabilities["documentHighlightProvider"] then
    vim.cmd(string.format("au CursorHold  <buffer=%d> lua vim.lsp.buf.document_highlight()", bufnr))
    vim.cmd(string.format("au CursorHoldI <buffer=%d> lua vim.lsp.buf.document_highlight()", bufnr))
    vim.cmd(string.format("au CursorMoved <buffer=%d> lua vim.lsp.buf.clear_references()", bufnr))
  end

  if vim.lsp.codelens and client.server_capabilities["codeLensProvider"] then
    api.nvim_buf_set_keymap(bufnr, "n", "<leader>cr", "<Cmd>lua vim.lsp.codelens.refresh()<CR>", opts)
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
