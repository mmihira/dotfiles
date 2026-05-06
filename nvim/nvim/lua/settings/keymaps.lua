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
keymap("n", "<c-k>", ":Telescope find_files<CR>", opts)
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
keymap("n", "<c-;>", ":Run<CR>", opts)
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

	local function trim(s)
		return s and s:gsub("^%s+", ""):gsub("%s+$", "") or nil
	end

	local function parse_target_name(line)
		return line:match('target%("([^"]+)"') or line:match("target%('([^']+)'")
	end

	local function load_target_info(target_name)
		local target_out = strip_ansi(vim.fn.system("xmake show -t " .. vim.fn.shellescape(target_name) .. " 2>&1"))
		if vim.v.shell_error ~= 0 then
			return nil, trim(target_out)
		end

		local target_file = trim(target_out:match("targetfile:%s*([^\n]+)"))
		if not target_file then
			return nil, "could not find targetfile"
		end

		if not target_file:match("^/") then
			target_file = cwd .. "/" .. target_file
		end

		return {
			name = target_name,
			kind = trim(target_out:match("targetkind:%s*([^\n]+)") or target_out:match("kind:%s*([^\n]+)")),
			program = target_file,
		}
	end

	-- Parse xmake.lua for targets, preferring the one marked set_default(true).
	local xmake_lua = io.open(cwd .. "/xmake.lua", "r")
	if not xmake_lua then
		vim.notify("xmake: could not open xmake.lua", vim.log.levels.WARN)
		return
	end
	local xmake_content = xmake_lua:read("*a")
	xmake_lua:close()

	local targets = {}
	local current_target = nil
	for line in xmake_content:gmatch("[^\n]+") do
		local t = parse_target_name(line)
		if t then
			current_target = { name = t, is_default = false }
			table.insert(targets, current_target)
		end
		if current_target and line:match("set_default%s*%(%s*true%s*%)") then
			current_target.is_default = true
		end
	end

	if #targets == 0 then
		vim.notify("xmake: no target() found in xmake.lua", vim.log.levels.WARN)
		return
	end

	local preferred_target = targets[1]
	for _, target in ipairs(targets) do
		if target.is_default then
			preferred_target = target
			break
		end
	end

	local target_order = { preferred_target.name }
	for _, target in ipairs(targets) do
		if target.name ~= preferred_target.name then
			table.insert(target_order, target.name)
		end
	end

	local launch_target = nil
	local preferred_target_info = nil
	local last_error = nil
	for _, target_name in ipairs(target_order) do
		local info, err = load_target_info(target_name)
		if not info then
			last_error = err
		else
			if target_name == preferred_target.name then
				preferred_target_info = info
			end
			if info.kind == "binary" or vim.fn.executable(info.program) == 1 then
				launch_target = info
				break
			end
		end
	end

	if not launch_target then
		if preferred_target_info then
			local kind = preferred_target_info.kind or "non-runnable"
			vim.notify(
				("xmake: target %s is %s at %s; build or choose an executable target before debugging")
					:format(preferred_target_info.name, kind, preferred_target_info.program),
				vim.log.levels.WARN
			)
		else
			vim.notify(
				("xmake: could not inspect target %s%s"):format(
					preferred_target.name,
					last_error and (": " .. last_error) or ""
				),
				vim.log.levels.WARN
			)
		end
		return
	end

	if launch_target.name ~= preferred_target.name then
		vim.notify(
			("xmake: target %s is not runnable, debugging %s instead"):format(
				preferred_target.name,
				launch_target.name
			),
			vim.log.levels.INFO
		)
	end

	if vim.fn.executable(launch_target.program) ~= 1 then
		vim.notify(
			("xmake: %s is not executable; run `xmake build %s` first"):format(
				launch_target.program,
				launch_target.name
			),
			vim.log.levels.WARN
		)
		return
	end

	require("dap").run({
		name = "xmake: " .. launch_target.name,
		type = "lldb",
		request = "launch",
		program = launch_target.program,
		cwd = cwd,
		initCommands = vim.g.dap_lldb_init_commands,
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
