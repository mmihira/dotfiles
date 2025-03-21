-- Run command
vim.api.nvim_create_user_command("Run", function(opts)
  require("scripts/run").run_file()
end, { nargs = 0 })

-- Open init.vim
vim.api.nvim_create_user_command("Vimfile", function(opts)
  local file_path = vim.fn.expand("~/.config/nvim/lua/plugins/init.lua")
  vim.api.nvim_command(":e " .. file_path)
end, { nargs = 0 })

-- Open settings
vim.api.nvim_create_user_command("Settings", function(opts)
  local file_path = vim.fn.expand("~/.config/nvim/lua/settings/keymaps.lua")
  vim.api.nvim_command(":e " .. file_path)
end, { nargs = 0 })

-- Open Plugins
vim.api.nvim_create_user_command("Plugins", function(opts)
  local file_path = vim.fn.expand("~/.config/nvim/lua/plugins/init.lua")
  vim.api.nvim_command(":e " .. file_path)
end, { nargs = 0 })

vim.api.nvim_create_user_command("Cheat", function(opts)
  vim.api.nvim_command(":e " .. os.getenv("CODE_DIR") .. "/dotfiles/cheatsheet.md")
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
  require("telescope.builtin").lsp_references()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Imp", function(opts)
  require("telescope.builtin").lsp_implementations()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Sym", function(opts)
  vim.api.nvim_command(":Trouble lsp_document_symbols lsp_doc_float")
end, { nargs = 0 })

vim.api.nvim_create_user_command("Nocmp", function(opts)
  require("cmp").setup.buffer({ enabled = false })
end, { nargs = 0 })

vim.api.nvim_create_user_command("OpenData", function(opts)
  vim.api.nvim_command(":Neotree " .. vim.fn.stdpath("data"))
end, { nargs = 0 })

vim.api.nvim_create_user_command("SS", function(opts)
  vim.api.nvim_command(":TSJToggle")
end, { nargs = 0 })

vim.api.nvim_create_user_command("Snip", function(opts)
  vim.api.nvim_command(":Neotree " .. vim.fn.stdpath("data") .. "/site/pack/packer/start/friendly-snippets/snippets")
end, { nargs = 0 })

vim.api.nvim_create_user_command("GhistFile", function(opts)
  vim.api.nvim_command("DiffviewFileHistory %")
end, { nargs = 0 })

vim.api.nvim_create_user_command("GhistBranch", function(opts)
  vim.api.nvim_command("DiffviewFileHistory")
end, { nargs = 0 })

vim.api.nvim_create_user_command("Issues", function(opts)
  vim.api.nvim_command(":Trouble diagnostics")
end, { nargs = 0 })

vim.api.nvim_create_user_command("Debug", function(opts)
  require("dap-go").debug_test()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Break", function(opts)
  require("dap").toggle_breakpoint()
end, { nargs = 0 })
vim.api.nvim_create_user_command("Dap", function(opts)
  require("dap").repl.open()
end, { nargs = 0 })

-- vim.api.nvim_set_keymap('n', '<Leader>dr', function() require('dap').repl.open() end)

-- Telekasten
vim.api.nvim_create_user_command("Notes", function(opts)
  vim.api.nvim_command(":Telekasten find_notes")
end, { nargs = 0 })
vim.api.nvim_create_user_command("TK", function(opts)
  vim.api.nvim_command(":Telekasten panel")
end, { nargs = 0 })

-- Macquarie work --
vim.api.nvim_create_user_command("ProdConfig", function(opts)
  vim.api.nvim_command(":Neotree " .. os.getenv("CODE_DIR") .. "/product-config-registry/products/ci-platform")
end, { nargs = 0 })

vim.api.nvim_create_user_command("GhistPCR", function(opts)
  vim.api.nvim_command(
    "DiffviewFileHistory" .. os.getenv("CODE_DIR") .. "/product-config-registry/products/ci-platform"
  )
end, { nargs = 0 })

vim.api.nvim_create_user_command("TelescopeGitSigns", function(opts)
  require("telescope").extensions.git_signs.git_signs()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Stack", function(opts)
  vim.api.nvim_command(":Trouble qflist qf_stack")
end, { nargs = 0 })

vim.api.nvim_create_user_command("Mn", function(opts)
  require("menu").open({
    {
      name = "Git status",
      cmd = function()
        vim.api.nvim_command(":Telescope git_status")
      end,
      rtxt = "s",
    },
    {
      name = "Buffer hunks",
      cmd = function()
        require("telescope").extensions.git_signs.git_signs()
      end,
      rtxt = "d",
    },
    {
      name = "Reset Hunk",
      cmd = require("gitsigns").reset_hunk,
      rtxt = "w",
    },
    {
      name = "Preview Hunk",
      cmd = require("gitsigns").preview_hunk,
      rtxt = "e",
    },
    {
      name = "Stage Hunk",
      cmd = require("gitsigns").stage_hunk,
      rtxt = "h",
    },
    {
      name = "Toggle split",
      cmd = require("treesj").toggle,
      rtxt = "l",
    },
  }, {
    mouse = false,
    border = true,
  })
end, { nargs = 0 })
