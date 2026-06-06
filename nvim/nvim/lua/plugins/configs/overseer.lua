local present, overseer = pcall(require, "overseer")
if not present then
	return
end

overseer.setup({
	-- -- Patch nvim-dap to support preLaunchTask and postDebugTask
	-- dap = true,
	-- -- Configure the task output buffer and window
	-- output = {
	-- 	-- Use a terminal buffer to display output. If false, a normal buffer is used
	-- 	use_terminal = true,
	-- 	-- If true, don't clear the buffer when a task restarts
	-- 	preserve_output = false,
	-- },
	-- Configure the task list
	task_list = {
		-- Default direction. Can be "left", "right", or "bottom"
		direction = "bottom",
		-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_width and max_width can be a single value or a list of mixed integer/float types.
		-- max_width = {100, 0.2} means "the lesser of 100 columns or 20% of total"
		-- max_width = { 100, 0.2 },
		-- -- min_width = {40, 0.1} means "the greater of 40 columns or 10% of total"
		-- min_width = { 40, 0.1 },
		-- max_height = { 4, 0.2 },
		min_height = 2,
		-- String that separates tasks
		separator = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
		-- Indentation for child tasks
		child_indent = { "┃ ", "┣━", "┗━" },
		-- Function that renders tasks. See lua/overseer/render.lua for built-in options
		-- and for useful functions if you want to build your own.
		render = function(task)
			return require("overseer.render").format_standard(task)
		end,
		keymaps = {
			["i"] = { "<Nop>", mode = "n" },
			["I"] = { "<Nop>", mode = "n" },
			["a"] = { "<Nop>", mode = "n" },
			["A"] = { "<Nop>", mode = "n" },
			["O"] = { "<Nop>", mode = "n" },
			["c"] = { "<Nop>", mode = "n" },
			["C"] = { "<Nop>", mode = "n" },
			["s"] = { "<Nop>", mode = "n" },
			["S"] = { "<Nop>", mode = "n" },
		},
	},
	-- -- Custom actions for tasks. See :help overseer-actions
	-- actions = {},
	-- -- Configure the floating window used for task templates that require input
	-- -- and the floating window used for editing tasks
	-- form = {
	-- 	zindex = 40,
	-- 	-- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
	-- 	-- min_X and max_X can be a single value or a list of mixed integer/float types.
	-- 	min_width = 80,
	-- 	max_width = 0.9,
	-- 	min_height = 10,
	-- 	max_height = 0.9,
	-- 	border = nil,
	-- 	-- Set any window options here (e.g. winhighlight)
	-- 	win_opts = {},
	-- },
	-- -- Configuration for task floating output windows
	-- task_win = {
	-- 	-- How much space to leave around the floating window
	-- 	padding = 2,
	-- 	border = nil,
	-- 	-- Set any window options here (e.g. winhighlight)
	-- 	win_opts = {},
	-- },
	-- -- Aliases for bundles of components. Redefine the builtins, or create your own.
	-- component_aliases = {
	-- 	-- Most tasks are initialized with the default components
	-- 	default = {
	-- 		"on_exit_set_status",
	-- 		"on_complete_notify",
	-- 		{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
	-- 	},
	-- 	-- Tasks from tasks.json use these components
	-- 	default_vscode = {
	-- 		"default",
	-- 		"on_result_diagnostics",
	-- 	},
	-- 	-- Tasks created from experimental_wrap_builtins
	-- 	default_builtin = {
	-- 		"on_exit_set_status",
	-- 		"on_complete_dispose",
	-- 		{ "unique", soft = true },
	-- 	},
	-- },
	-- -- List of other directories to search for task templates.
	-- -- This will search under the runtimepath, so for example
	-- -- "foo/bar" will search "<runtimepath>/lua/foo/bar/*"
	-- template_dirs = {},
	-- -- List of module names or lua patterns that match modules (must start with '^')
	-- -- to disable. This can be used to disable built in task providers.
	-- disable_template_modules = {
	-- 	-- "overseer.template.make",
	-- 	-- "^.*cargo",
	-- },
	-- -- For template providers, how long to wait before timing out.
	-- -- Set to 0 to wait forever.
	-- template_timeout_ms = 3000,
	-- -- Cache template provider results if the provider takes longer than this to run.
	-- -- Set to 0 to disable caching.
	-- template_cache_threshold_ms = 200,
	-- log_level = vim.log.levels.WARN,
	-- -- Overseer can wrap any call to vim.system and vim.fn.jobstart as a task.
	-- experimental_wrap_builtins = {
	-- 	enabled = false,
	-- 	condition = function(cmd, caller, opts)
	-- 		return true
	-- 	end,
	-- },
})

local overseer_no_insert_group = vim.api.nvim_create_augroup("custom_overseer_no_insert", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = overseer_no_insert_group,
	pattern = { "OverseerList", "OverseerOutput" },
	callback = function(args)
		local no_insert_keys = { "i", "I", "a", "A", "O", "c", "C", "s", "S" }

		if vim.bo[args.buf].filetype == "OverseerOutput" then
			table.insert(no_insert_keys, "o")
		end

		for _, key in ipairs(no_insert_keys) do
			vim.keymap.set("n", key, "<Nop>", { buffer = args.buf, silent = true })
		end

		vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = args.buf, silent = true })
	end,
})
