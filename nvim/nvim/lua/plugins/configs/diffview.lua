local present, gitsigns = pcall(require, "gitsigns")
if not present then
  return
end

local present, diffview_actions = pcall(require, "diffview.actions")
if not present then
  return
end

require("gitsigns").setup()
require("diffview").setup({
  enhanced_diff_hl = true,
  keymaps = {
    file_panel = {
      ["o"] = diffview_actions.goto_file_tab,
      ["<leader>q"] = "<Cmd>DiffviewClose<CR>",
    },
    view = { ["<leader>q"] = "<Cmd>DiffviewClose<CR>" },
  },
})
