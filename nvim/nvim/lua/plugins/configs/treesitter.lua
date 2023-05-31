local present, treesitterconfig = pcall(require, "nvim-treesitter.configs")
if not present then
  return
end

treesitterconfig.setup({
  ensure_installed = { "go", "lua" },
  sync_install = false,
  auto_install = false,
  ignore_install = { "javascript" },
  highlight = {
    enable = false,
    additional_vim_regex_highlighting = false,
  },
})
