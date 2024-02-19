local present, lspconfig = pcall(require, "lspconfig")
if not present then
  return
end

local present, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not present then
  return
end

local lsplib = require("plugins/configs/lspl")

local goplsconfig = { on_attach = lsplib.mk_config().on_attach }

-- Gopls
lspconfig.gopls.setup(goplsconfig)

-- Lua
luaconfig = lsplib.mk_config()
luaconfig.settings = { Lua = { diagnostics = { globals = { "vim" } } } }
lspconfig.lua_ls.setup(luaconfig)

-- Python
lspconfig.pyright.setup({})

-- HTML
lspconfig.html.setup({})

-- HTML
lspconfig.tsserver.setup(goplsconfig)

-- Hide the dianostic virtual text
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = false,
})

-- Show diagnostics on hover
vim.api.nvim_command("autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focusable = false})")

-- Vanity
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

vim.diagnostic.config({
  float = { border = "rounded" },
})

-- Signature help, doesn't work in attach func, so putting it here
local signature_config = {
  debug = true,
  hint_enable = false,
  handler_opts = { border = "rounded" },
  max_width = 80,
}
require("lsp_signature").setup(signature_config)
