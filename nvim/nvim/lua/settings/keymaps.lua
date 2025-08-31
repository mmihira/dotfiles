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

-- TreeSJ
keymap("n", "t", ":TSJToggle<CR>", opts)
-- Telescope
keymap("n", "<c-k>", ":Telescope git_files<CR>", opts)
keymap(
	"n",
	"<c-l>",
	":lua require('telescope.builtin').lsp_document_symbols({ show_line=true, previewer=false, symbols={'method','function'} })<CR>",
	opts
)
keymap("n", "<leader>k", ":Telescope live_grep<CR>", opts)
keymap(
	"n",
	"<leader>im",
	[[<cmd>lua require'telescope'.extensions.goimpl.goimpl{}<CR>]],
	{ noremap = true, silent = true }
)

-- Neotree
keymap("n", "<leader>nn", ":NOpen<CR>", opts)
-- keymap("n", "<leader>nn", "<CMD>Neotree position=float toggle=true reveal_force_cwd=true<CR>", opts)

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
-- Git
keymap("n", "<leader>s", ":GitMn<CR>", opts)
-- ToggleTerm
local function toggle_claude()
	local terms = require("toggleterm.terminal")
	local existing_term = terms.find(function(t)
		return t.display_name == "claude"
	end)

	if existing_term then
		existing_term:toggle()
	else
		vim.cmd('3TermExec cmd="claude" name=claude direction=float size=100')
	end
end

keymap("n", "<c-,>", "", { noremap = true, silent = true, callback = toggle_claude })
keymap("t", "<c-,>", "<C-\\><C-n>:ToggleTerm<CR>", opts)
keymap("n", "<leader>mm", ":ToggleTerm<CR>", opts)
keymap("t", "<leader>mm", "<C-\\><C-n>:ToggleTerm<CR>", opts)
keymap("t", "<leader>qq", "<C-\\><C-n><CR>", opts)

keymap("n", "<leader>q", ":close<CR>", opts)
keymap("n", "0", ':lua require("gitsigns").next_hunk()<CR>', opts)

-- Vim-Test
keymap("n", "<leader>t", ":TestNearest<CR>", opts)
keymap("n", "<leader>T", ":TestFile<CR>", opts)
keymap("n", "<leader>C", ":T clear<CR>", opts)
-- CopilotChat
keymap("n", "<leader>cp", ":CopilotChat<CR>", opts)
-- Goto preview
keymap("n", "gv", "<Cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "gp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", opts)

-- Debug
keymap("n", "<leader>d", ":DapMn<CR>", opts)
vim.keymap.set("n", "<F4>", function()
	require("dap").continue()
end)

vim.keymap.set("n", "<F5>", function()
	require("dap").continue()
end)

vim.keymap.set("n", "_", function()
	local dap = require("dap")
	if dap.session() then
		dap.step_over()
	else
		require("dap").toggle_breakpoint()
	end
end)

vim.keymap.set({ "n", "v" }, "<Leader>dk", function()
	require("dapui").eval()
end)
