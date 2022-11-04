local present, null = pcall(require, "null-ls")
if not present then
  return
end

null.setup({
  sources = {
    null.builtins.formatting.prettier,

    null.builtins.formatting.stylua,

    null.builtins.diagnostics.golangci_lint,
    null.builtins.formatting.gofmt,
    null.builtins.formatting.goimports,
    null.builtins.formatting.goimports_reviser,
  },
})
