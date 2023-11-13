local present, telek = pcall(require, "telekasten")
if not present then
  return
end
telek.setup({
  home = vim.fn.expand(os.getenv("CODE_DIR") .. "/notes"),
})
