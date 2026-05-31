return {
	name = "odin_build",
	builder = function()
		local errorformat = table.concat({
			"%Eerror: %f:%l:%c: %m",
			"%Wwarning: %f:%l:%c: %m",
			"%Inote: %f:%l:%c: %m",
			"%E%f:%l:%c: error: %m",
			"%W%f:%l:%c: warning: %m",
			"%I%f:%l:%c: note: %m",
			"%-G%.%#",
		}, ",")
		local components = {
			{
				"on_output_quickfix",
				errorformat = errorformat,
				set_diagnostics = true,
				items_only = true,
				close = true,
				tail = false,
			},
			{ "open_output", on_start = "always", direction = "dock" },
			{ "on_result_trouble_qflist", mode = "qf_stack", close = true },
			{ "on_complete_close_overseer", success_delay_ms = 1500, failure_delay_ms = 0 },
			"default",
		}
		local file_full_path = vim.api.nvim_buf_get_name(0)
		local cwd = vim.fs.dirname(file_full_path)

		if not cwd or cwd == "" then
			vim.notify("Could not resolve Odin working directory", vim.log.levels.ERROR)
			return
		end

		return {
			cmd = { "odin", "run", "." },
			cwd = cwd,
			components = components,
		}
	end,
	condition = {
		filetype = { "odin" },
	},
}
