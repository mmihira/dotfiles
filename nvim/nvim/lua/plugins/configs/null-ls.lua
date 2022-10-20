local present, null = pcall(require, "null-ls")
if not present then
	return
end

-- doesnt work
local go_iff_err = {
	method = null.methods.FORMATTING,
	filetypes = { "go" },
	generator = {
		fn = function(params)
			vim.api.nvim_command(":GoIfErr")
		end,
	},
}
null.register(go_iff_err)

null.setup({
	sources = {
		null.builtins.formatting.prettier,

		null.builtins.formatting.stylua,

		null.builtins.diagnostics.golangci_lint,
		null.builtins.formatting.gofmt,
		null.builtins.formatting.goimports,
		null.builtins.formatting.goimports_reviser,
		go_iff_err,
	},
})
