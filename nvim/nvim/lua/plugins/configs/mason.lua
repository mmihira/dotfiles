local present, mason = pcall(require, "mason")
if not present then
  return
end

mason.setup()
require("mason-lspconfig").setup({
  automatic_enable = false,
})
