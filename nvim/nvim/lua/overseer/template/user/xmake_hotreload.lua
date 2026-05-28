return {
	name = "xmake_hotreload",
	builder = function()
		local xmake = require("scripts.run.xmake")
		local errorformat = table.concat({
			"%Eerror: %f:%l:%c: %m",
			"%Wwarning: %f:%l:%c: %m",
			"%Inote: %f:%l:%c: %m",
			"%E%f:%l:%c: error: %m",
			"%W%f:%l:%c: warning: %m",
			"%I%f:%l:%c: note: %m",
			"%-G%.%#",
		}, ",")

		local build, err = xmake.resolve_hotreload_target(vim.api.nvim_buf_get_name(0))
		if not build then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end

		return {
			name = "xmakehotreload " .. build.dll_target,
			cmd = string.format(
				"luajit %s %s %s && xmake build %s",
				vim.fn.shellescape(build.touch_script),
				vim.fn.shellescape(build.manifest_path),
				vim.fn.shellescape(build.dll_target),
				vim.fn.shellescape(build.dll_target)
			),
			cwd = build.root,
			components = {
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
			},
		}
	end,
	condition = {
		filetype = { "cpp" },
	},
}
