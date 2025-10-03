local present, null = pcall(require, "null-ls")
if not present then
  return
end

local lsplib = require("plugins/configs/lspl")
local cpplint = require("none-ls.diagnostics.cpplint")

null.setup({
  on_attach = lsplib.mk_config().on_attach,
  sources = {
    null.builtins.formatting.prettier,

    null.builtins.formatting.stylua,

    null.builtins.formatting.gofmt,
    null.builtins.formatting.goimports,
    null.builtins.formatting.goimports_reviser,

    null.builtins.diagnostics.golangci_lint,

    cpplint.with({
      extra_args = { "--filter=-whitespace/indent,-runtime/references,-whitespace/indent_namespace" },
      prepend_extra_args = true,
    }),

    null.builtins.diagnostics.yamllint,
  },
})
