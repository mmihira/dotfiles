local present, treesitterconfig = pcall(require, "nvim-treesitter.configs")
if not present then
  return
end

treesitterconfig.setup({
  ensure_installed = { "go", "lua", "java" },
  sync_install = false,
  auto_install = false,
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})
