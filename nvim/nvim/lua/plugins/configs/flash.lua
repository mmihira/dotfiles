local present, flash = pcall(require, "flash")
if not present then
  return
end

flash.setup({
  modes = {
    -- options used when flash is activated through
    -- `f`, `F`, `t`, `T`, `;` and `,` motions
    char = {
      enabled = false,
      highlight = { backdrop = false },
    },
  },
})

vim.keymap.set({ "n", "x", "o" }, "s", function()
  flash.jump()
end, { desc = "Flash" })
-- vim.keymap.set({ "n", "o", "x" }, "S", function() flash.treesitter() end, {desc = "Flash Treesitter"})
vim.keymap.set("o", "r", function()
  flash.remote()
end, { desc = "Remote Flash" })
-- vim.keymap.set({ "o", "x" },"R", function() flash.treesitter_search() end, {desc = "Flash Treesitter Search" })
-- vim.keymap.set({ "c" }, "<c-s>", function()
--   flash.toggle()
-- end, { desc = "Toggle Flash Search" })
