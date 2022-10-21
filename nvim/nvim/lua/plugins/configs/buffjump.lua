local present, bufjump = pcall(require, "bufjump")
if not present then
  return
end

require("bufjump").setup({
  forward = "<C-p>",
  backward = "<C-n>",
  on_success = nil,
})
