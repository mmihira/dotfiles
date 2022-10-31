local present, xray = pcall(require, "go")
if not present then
  return
end

local path = require("mason-core.path")
local install_root_dir = path.concat({ vim.fn.stdpath("data"), "lsp_servers" })

xray.setup({
  gopls_cmd = { install_root_dir .. "/go/gopls" },
  fillstruct = "gopls",
  dap_debug = false,
  dap_debug_gui = false,
  lsp_diag_hdlr = false,
  lsp_diag_underline = false,
  lsp_diag_signs = false,
  lsp_diag_update_in_insert = false,
  lsp_document_formatting = false,
  textobjects = true, -- enable default text jobects through treesittter-text-objects
  lsp_inlay_hints = {
    enable = false,
  },
})
