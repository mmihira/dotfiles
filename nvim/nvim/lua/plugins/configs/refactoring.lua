require('refactoring').setup({})

-- Need nightly neovim for this to work, and tree-sitter 

vim.api.nvim_set_keymap(
    "v",
    "<leader>rr",
    ":lua require('refactoring').select_refactor()<CR>",
    { noremap = true, silent = true, expr = false }
)

