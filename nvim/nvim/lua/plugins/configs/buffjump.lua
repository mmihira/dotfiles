local present, bufjump = pcall(require, "bufjump")
if not present then
  return
end

bufjump.setup({
  forward_key = "<C-p>",
  backward_key = "<C-n>",
  on_success = nil,
})

local present, before = pcall(require, "before")
if not present then
  return
end

before.setup({
  -- Jump to previous entry in the edit history
  vim.keymap.set("n", "<C-m>", before.jump_to_last_edit, {}),
})
