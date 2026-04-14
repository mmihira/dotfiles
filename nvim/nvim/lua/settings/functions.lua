-- NeoTree command
vim.api.nvim_create_user_command("NOpen", function(opts)
	local current_buffer_name = vim.api.nvim_buf_get_name(0)
	local cwd = vim.fn.getcwd()
	if current_buffer_name:find("ministarter") then
		vim.cmd("Neotree position=float toggle=true dir=" .. cwd)
	else
		vim.cmd("Neotree position=float toggle=true reveal_force_cwd=true")
	end
end, { nargs = 0 })
--
-- Run command
vim.api.nvim_create_user_command("Run", function(opts)
	require("scripts/run").run_file()
end, { nargs = 0 })

-- Import inserter
vim.api.nvim_create_user_command("ImportInsert", function(opts)
	require("scripts/import_inserter").run()
end, { nargs = 0 })

-- Events
vim.api.nvim_create_user_command("EventsSync", function(opts)
	local edl = require("scripts/event_dispatcher_lookup")
	edl.main()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Events", function(opts)
	local edl = require("scripts/event_dispatcher_lookup")

	local pos = vim.api.nvim_win_get_cursor(0)
	local file_path = vim.api.nvim_buf_get_name(0)
	local line_number = pos[1]
	local column = pos[2] + 1

	-- edl.main()
	local className = edl.get_class_from_lsp(file_path, line_number, column)
	edl.get_dispatcher_calls_for_class(className, "file_hashes.json")
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
	require("dap").set_breakpoint()
	require("dap").continue()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Break", function(opts)
	require("dap").toggle_breakpoint()
end, { nargs = 0 })
vim.api.nvim_create_user_command("Dap", function(opts)
	require("dap").repl.open()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DapUi", function(opts)
	require("dapui").open()
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

vim.api.nvim_create_user_command("Make", function(opts)
	require("menu").open({
		{
			name = "Generate",
			cmd = function()
				vim.api.nvim_command(":CMakeGenerate")
			end,
			rtxt = "m",
		},
		{
			name = "Settings",
			cmd = function()
				vim.api.nvim_command(":CMakeSettings")
			end,
			rtxt = "s",
		},
	}, {
		mouse = false,
		border = true,
	})
end, { nargs = 0 })

vim.api.nvim_create_user_command("LspMn", function(opts)
	require("menu").open({
		{
			name = "Document symbols",
			cmd = function()
				require("telescope.builtin").lsp_document_symbols({
					show_line = true,
					previewer = false,
					-- symbols = { "method", "function", "class" },
					symbol_filter = function(symbol)
						return not string.match(symbol.name, "^exec")
					end,
				})
			end,
			rtxt = "l",
		},
		{
			name = "Workspace symbols",
			cmd = function()
				local make_entry = require("telescope.make_entry")
				local default_maker = make_entry.gen_from_lsp_symbols({ show_line = true })
				require("telescope.builtin").lsp_workspace_symbols({
					show_line = true,
					previewer = false,
					symbols = { "method", "function", "class", "field" },
					entry_maker = function(entry)
						local result = default_maker(entry)
						if result then
							-- entry.text is "[Kind] symbolName" — match only against symbol name
							result.ordinal = entry.text:match("^%[.-%] (.+)$") or entry.text
						end
						return result
					end,
				})
			end,
			rtxt = "w",
		},
		{
			name = "LSP UI",
			cmd = function()
				vim.cmd("Cpplsp")
			end,
			rtxt = "s",
		},
		{
			name = "LSP Ast",
			cmd = function()
				require("cpplsp.ast_inspect").open()
			end,
			rtxt = "a",
		},
		{
			name = "LSP Init",
			cmd = function()
				local clients = vim.lsp.get_clients({ bufnr = 0, name = "cpplsp" })
				if #clients == 0 then
					vim.notify("cpplsp not attached", vim.log.levels.ERROR)
					return
				end
				clients[1]:request("cpplsp/reinit", vim.NIL, function(err, result)
					if err then
						vim.notify("reinit failed: " .. vim.inspect(err), vim.log.levels.ERROR)
					else
						vim.notify("reinit triggered")
					end
				end)
			end,
			rtxt = "i",
		},
		{
			name = "LSP Restart",
			cmd = function()
				vim.api.nvim_command(":LspRestart")
			end,
			rtxt = "r",
		},
		{
			name = "LSP Buffer Info",
			cmd = function()
				vim.api.nvim_command(":CpplspBufferInfo")
			end,
			rtxt = "p",
		},
		{
			name = "LSP Artifact Registry",
			cmd = function()
				vim.api.nvim_command(":CpplspArtifactRegistry")
			end,
			rtxt = "ag",
		},
		{
			name = "LSP Logs",
			cmd = function()
				vim.api.nvim_command(":CpplspLogs")
			end,
			rtxt = "g",
		},
		{
			name = "LSP Compile Env Script",
			cmd = function()
				vim.api.nvim_command(":CpplspCompileCommands")
			end,
			rtxt = "ce",
		},
		{
			name = "Build Capture + Diagnostics",
			cmd = function()
				vim.api.nvim_command(":BuildCaptureLoad")
				vim.api.nvim_command(":Trouble diagnostics")
			end,
			rtxt = "bd",
		},
	}, {
		mouse = false,
		border = true,
	})
end, { nargs = 0 })

vim.api.nvim_create_user_command("GitMn", function(opts)
	require("menu").open({
		{
			name = "Git status",
			cmd = function()
				vim.api.nvim_command(":Telescope git_status")
			end,
			rtxt = "s",
		},
		{
			name = "Side kick here",
			cmd = function()
				local sidekick = require("sidekick.cli")
				local tool = _G._ai_tool or "claude"
				local template = "In {file} at {position}"
				local rendered_msg = sidekick.render(template)
				if rendered_msg then
					sidekick.send({ name = tool, msg = rendered_msg })
				end
			end,
			rtxt = "a",
		},
		{
			name = "Switch AI tool",
			cmd = function()
				vim.ui.select(
					{ "claude", "codex", "copilot", "gemini" },
					{ prompt = "Switch AI tool: " },
					function(choice)
						if choice then
							_G._ai_tool = choice
						end
					end
				)
			end,
			rtxt = "i",
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
			name = "Toggle split",
			cmd = require("treesj").toggle,
			rtxt = "l",
		},
	}, {
		mouse = false,
		border = true,
	})
end, { nargs = 0 })

vim.api.nvim_create_user_command("DapMn", function(opts)
	require("menu").open({
		{
			name = "Start",
			cmd = function()
				require("dap").continue()
			end,
			rtxt = "s",
		},
		{
			name = "Continue",
			cmd = require("dap").continue(),
			rtxt = "l",
		},
	}, {
		mouse = false,
		border = true,
	})
end, { nargs = 0 })

vim.api.nvim_create_user_command("Dp", function(opts)
	require("dap").toggle_breakpoint()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Ft", function(opts)
	require("scripts/floating_window").toggle()
end, { nargs = 0 })

vim.api.nvim_create_user_command("FindMn", function(opts)
	require("menu").open({
		{
			name = "Event handler",
			cmd = function()
				local word = vim.fn.expand("<cword>")
				local event_name = word:gsub("^e", "")
				local pattern = "handle[A-Za-z]*" .. event_name
				require("telescope.builtin").grep_string({
					search = pattern,
					use_regex = true,
					glob_pattern = "*.{cpp,h}",
				})
			end,
			rtxt = "h",
		},
		{
			name = "Event triggers",
			cmd = function()
				local word = vim.fn.expand("<cword>")
				local pattern = "(enqueue|trigger)[A-Za-z]*[<(][A-Za-z:]*" .. word
				require("telescope.builtin").grep_string({
					search = pattern,
					use_regex = true,
					glob_pattern = "*.{cpp,h}",
				})
			end,
			rtxt = "t",
		},
	}, {
		mouse = false,
		border = true,
	})
end, { nargs = 0 })
