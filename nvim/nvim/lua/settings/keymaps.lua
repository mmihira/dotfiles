local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap


keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes:
--   Normal       = "n"
--   Insert       = "i"
--   Visual       = "v"
--   Visual_Block = "x"
--   Terminal     = "t"
--   Command      = "c"
--

-- NOP assignments
-- Reassign macro key
keymap("n", "Q", "", opts)
keymap("n", "q", "<NOP>", opts)

keymap("v", "u", "<NOP>", opts)

-- JJ
keymap("i", "jj", "<Esc>", opts)
keymap("c", "jj", "<Esc>", opts)

-- " GitSigns
-- nnoremap <S-h> :Gitsigns next_hunk<CR>
--
-- " Map line matching omnicomplete
-- inoremap <C-l> <C-x><C-o>

-- Telescope
keymap("n", "<c-k>", ":Telescope buffers<CR>", opts)
keymap("n", "<c-l>", ":Telescope lsp_document_symbols symbol_width=60 ignore_symbols=field,struct<CR>", opts)
keymap("n", "<leader>k", ":Telescope live_grep<CR>", opts)
keymap(
  "n",
  "<leader>im",
  [[<cmd>lua require'telescope'.extensions.goimpl.goimpl{}<CR>]],
  { noremap = true, silent = true }
)

-- Neotree
keymap("n", "<leader>nn", "<CMD>Neotree position=float toggle=true reveal_force_cwd=true<CR>", opts)

-- Remap exit
keymap("n", "<leader>q", ":close<CR>", opts)
-- Remap cancel highlight
keymap("n", "<leader>8", ":noh<CR>", opts)
-- Remap paste from + buffer
keymap("n", "<leader>=", '"+P', opts)
-- Remap copy one line to system buffer
keymap("n", "<leader>cc", '"+y <CR>', opts)
keymap("v", "<leader>cc", '"+y <CR>', opts)
-- Replace highlighted text buffer global
keymap("v", "<leader>r", '"0y :%s/<C-r>0', opts)
-- Run
keymap("n", "<leader>r", ":Run<CR>", opts)
-- Git view
keymap("n", "<leader>ss", ":Diff<CR>", opts)
-- Floaterm
keymap("n", "<leader>mm", ":StartMainFloat<CR>", opts)
keymap("t", "<leader>mm", "<C-\\><C-n>:FloatermToggle<CR>", opts)
keymap("n", "<F9>", "<C-\\><C-n>:FloaTermToggleLayout<CR>", opts)
keymap("t", "<leader>qq", "<C-\\><C-n><CR>", opts)
-- Vim-Test
keymap("n", "<leader>t", ":TestNearest<CR>", opts)
keymap("n", "<leader>T", ":TestFile<CR>", opts)
keymap("n", "<leader>C", ":T clear<CR>", opts)
-- Goto preview
keymap("n", "gv", "<Cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "gp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", opts)
-- Refactoring Inline variable can also pick up the identifier currently under the cursor without visual mode
vim.api.nvim_set_keymap(
  "n",
  "<leader>ri",
  [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
  { noremap = true, silent = true, expr = false }
)
