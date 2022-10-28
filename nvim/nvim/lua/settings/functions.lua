-- Show git diff
local present, diffview = pcall(require, "diffview")
if present then
  vim.api.nvim_create_user_command("Diff", function(opts)
    diffview.open()
  end, { nargs = 0 })
end

-- Open vimconfig
vim.api.nvim_create_user_command("Vimfile", function(opts)
  local file_path = vim.fn.expand("~/.config/nvim/lua/plugins/init.lua")
  vim.api.nvim_command(":e " .. file_path)
end, { nargs = 0 })

vim.api.nvim_create_user_command("Cheat", function(opts)
  local file_path = vim.fn.expand("~/c/dotfiles/cheatsheet.md")
  vim.api.nvim_command(":e " .. file_path)
end, { nargs = 0 })

-- Start the main float we reuse
vim.api.nvim_create_user_command("StartMainFloat", function(opts)
  local main = vim.api.nvim_call_function("floaterm#terminal#get_bufnr", { "main_term" })
  if main then
    vim.api.nvim_command(":FloatermToggle main_term")
  else
    vim.api.nvim_command(":FloatermNew! --wintype=float --name=main_term --width=0.8 --height=0.8")
  end
end, { nargs = 0 })

-- Telescope old files
vim.api.nvim_create_user_command("Old", function(opts)
  vim.api.nvim_command(":Telescope oldfiles")
end, { nargs = 0 })

vim.api.nvim_create_user_command("Ref", function(opts)
  vim.api.nvim_command(":Telescope lsp_references")
end, { nargs = 0 })

vim.api.nvim_create_user_command("Sym", function(opts)
  vim.api.nvim_command(":Telescope lsp_document_symbols")
end, { nargs = 0 })
