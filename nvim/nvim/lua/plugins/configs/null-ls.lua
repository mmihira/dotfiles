local present, null = pcall(require, "null-ls")
if not present then
	return
end

local lsplib = require("plugins/configs/lspl")

null.setup({
  on_attach = lsplib.mk_config().on_attach,
	sources = {
		null.builtins.formatting.prettier,

		null.builtins.formatting.stylua,

		null.builtins.formatting.gofmt,
		null.builtins.formatting.goimports,
		null.builtins.formatting.goimports_reviser,

		null.builtins.diagnostics.golangci_lint,

		require("none-ls.diagnostics.cpplint"),

		null.builtins.diagnostics.yamllint,
	},
})
