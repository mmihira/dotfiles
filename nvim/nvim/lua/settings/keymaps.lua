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
	"<c-b>",
	":lua require('telescope.builtin').live_grep({ cwd = 'src/entities', initial_mode = 'insert' })<CR>",
	opts
)
keymap("n", "<c-l>", ":LspMn<CR>", opts)
keymap("n", "<leader>k", ":Telescope live_grep<CR>", opts)
keymap(
	"n",
	"<leader>im",
	[[<cmd>lua require'telescope'.extensions.goimpl.goimpl{}<CR>]],
	{ noremap = true, silent = true }
)

vim.api.nvim_create_user_command("Pcm", function()
	-- Find only the cpplsp client
	local clients = vim.lsp.get_clients({ name = "cpplsp" })
	if #clients == 0 then
		vim.notify("cpplsp: no active client", vim.log.levels.WARN)
		return
	end

	local params = {
		textDocument = vim.lsp.util.make_text_document_params(),
	}

	-- Only send the request to the cpplsp client
	clients[1].request("cpplsp/buildPcm", params, function(err, result)
		if err then
			vim.notify("cpplsp: PCM build failed (RPC error): " .. tostring(err), vim.log.levels.ERROR)
			return
		end
		if result and result.status == "success" then
			vim.notify("cpplsp: PCM built successfully -> " .. result.pcm_path, vim.log.levels.INFO)
		else
			local msg = result and result.error or "unknown error"
			vim.notify("cpplsp: PCM build failed: " .. msg, vim.log.levels.WARN)
		end
	end)
end, { desc = "Build PCM for the current C++ module" })

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

-- AI CLI (claude/codex) - prompt on first use, remembered for session
_G._ai_tool = _G._ai_tool or nil

vim.keymap.set("n", "<c-,>", function()
	if _G._ai_tool then
		require("sidekick.cli").toggle({ name = _G._ai_tool, focus = true })
	else
		vim.ui.select({ "claude", "codex", "copilot", "gemini" }, { prompt = "Select AI tool: " }, function(choice)
			if choice then
				_G._ai_tool = choice
				require("sidekick.cli").toggle({ name = _G._ai_tool, focus = true })
			end
		end)
	end
end, { noremap = true, silent = true })

keymap("n", "<leader>mm", ":ToggleTerm<CR>", opts)
keymap("t", "<leader>mm", "<C-\\><C-n>:ToggleTerm<CR>", opts)
keymap("t", "<leader>qq", "<C-\\><C-n><CR>", opts)

keymap("n", "<leader>q", ":close<CR>", opts)
keymap("n", "0", ':lua require("gitsigns").next_hunk()<CR>', opts)

-- Vim-Test
keymap("n", "<leader>t", ":TestNearest<CR>", opts)
keymap("n", "<leader>T", ":TestFile<CR>", opts)
keymap("n", "<leader>C", ":T clear<CR>", opts)
-- Goto preview
keymap("n", "gv", "<Cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "gp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", opts)

-- Debug
vim.keymap.set("n", "<leader>d", function()
	local cwd = vim.fn.getcwd()

	if vim.fn.filereadable(cwd .. "/xmake.lua") ~= 1 then
		vim.cmd("DapMn")
		return
	end

	local function strip_ansi(s)
		return s:gsub("\27%[[%d;]*%a", "")
	end

	-- Parse xmake.lua for the target marked set_default(true), else first target
	local xmake_lua = io.open(cwd .. "/xmake.lua", "r")
	if not xmake_lua then
		vim.notify("xmake: could not open xmake.lua", vim.log.levels.WARN)
		return
	end
	local xmake_content = xmake_lua:read("*a")
	xmake_lua:close()

	local default_target = nil
	local current_target = nil
	local first_target = nil
	for line in xmake_content:gmatch("[^\n]+") do
		local t = line:match('target%("([^"]+)"')
		if t then
			current_target = t
			if not first_target then first_target = t end
		end
		if current_target and line:match("set_default%(true%)") then
			default_target = current_target
			break
		end
	end
	default_target = default_target or first_target

	if not default_target then
		vim.notify("xmake: no target() found in xmake.lua", vim.log.levels.WARN)
		return
	end

	-- Get the binary path for that target
	local target_out = strip_ansi(vim.fn.system("xmake show -t " .. vim.fn.shellescape(default_target) .. " 2>/dev/null"))
	local target_file = target_out:match("targetfile:%s*([^\n]+)")
	if not target_file then
		vim.notify("xmake: could not find targetfile for " .. default_target, vim.log.levels.WARN)
		return
	end
	target_file = target_file:gsub("^%s+", ""):gsub("%s+$", "")

	if not target_file:match("^/") then
		target_file = cwd .. "/" .. target_file
	end

	require("dap").run({
		name = "xmake: " .. default_target,
		type = "lldb",
		request = "launch",
		program = target_file,
		cwd = cwd,
	})
end, opts)
vim.keymap.set("n", "<F4>", function()
	require("dap").continue()
end)

vim.keymap.set("n", "<F5>", function()
	require("dap").step_over()
end)

vim.keymap.set("n", "<F6>", function()
	require("dap").step_into()
end)

vim.keymap.set("n", "_", function()
	local dap = require("dap")
	if dap.session() then
		dap.step_over()
	else
		require("dap").toggle_breakpoint()
	end
end)

keymap("n", "<leader>f", ":FindMn<CR>", opts)

vim.keymap.set({ "n", "v" }, "<Leader>dk", function()
	require("dap.ui.widgets").hover(nil, { border = "rounded" })
end)
