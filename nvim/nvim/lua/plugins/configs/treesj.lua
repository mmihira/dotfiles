local present, ts = pcall(require, "treesj")
if not present then
  return
end

ts.setup({
  use_default_keymaps = false,
  max_join_length = 10000,
})
