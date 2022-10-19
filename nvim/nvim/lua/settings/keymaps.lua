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
keymap("n", "<leader>k", ":Telescope oldfiles live_grep<CR>", opts)

keymap("n", "<leader>nn", "<CMD>Neotree position=float toggle=true reveal_force_cwd=true<CR>", opts)

-- Remap exit
keymap("n", "<leader>q", ":q<CR>", opts)
-- Remap cancel highlight
keymap("n", "<leader>8", ":noh<CR>", opts)
-- Remap paste from + buffer
keymap("n", "<leader>=", "+gP", opts)
-- Remap copy one line to system buffer
keymap("n", "<leader>cc V", "+yyv <CR>", opts)
keymap("v", "<leader>cc V", "+yyv <CR>", opts)
-- Replace highlighted text buffer global
keymap("v", "<leader>r", "0y :%s/<C-r>0", opts)
-- Run
keymap("n", "<leader>r", ":Run <CR>", opts)
-- Git view
keymap("n", "<leader>ss", ":Diff<CR>", opts)
-- Floaterm
keymap("n", "<leader>mm", ":StartMainFloat<CR>", opts)
keymap("n", "<leader>mm", "<C-\\><C-n>:FloatermToggle<CR>", opts)
keymap("n", "<F9>", "<C-\\><C-n>:FloaTermToggleLayout<CR>", opts)
keymap("t", "<leader>qq", "<C-\\><C-n><CR>", opts)
-- Vim-Test
keymap("n", "<leader>t", ":TestNearest<CR>", opts)
keymap("n", "<leader>T", ":TestFile<CR>", opts)
keymap("n", "<leader>C", ":T clear<CR>", opts)
