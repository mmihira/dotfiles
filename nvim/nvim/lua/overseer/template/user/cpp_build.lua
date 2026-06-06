return {
	name = "xmake_build",
	builder = function()
		local xmake = require("scripts.run.xmake")
		local errorformat = require("overseer.cpp_errorformat")
		local file_full_path = vim.api.nvim_buf_get_name(0)
		local build, err = xmake.resolve_build_target(file_full_path)

		if not build then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end

		if not build.target then
			vim.notify("Could not find xmake target for " .. build.rel, vim.log.levels.WARN)
			return
		end

		local components = {
			"close_trouble_on_start",
			{
				"on_output_quickfix",
				errorformat = errorformat,
				relative_file_root = build.root,
				set_diagnostics = true,
				items_only = true,
				close = true,
				tail = false,
			},
			{
				"open_output_center_float",
				width_fraction = 80,
				height_fraction = 60,
				focus = false,
				close_delay_ms = 500,
			},
			"on_exit_set_status",
			{ "on_complete_notify", statuses = { "FAILURE" } },
			"on_complete_notify_duration",
			{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
		}

		return {
			cmd = { "xmake", "build", build.target },
			cwd = build.root,
			env = {
				CLICOLOR = "0",
				GCC_COLORS = "",
				NO_COLOR = "1",
				XMAKE_COLORTERM = "nocolor",
			},
			components = components,
		}
	end,
	condition = {
		filetype = { "cpp" },
	},
}
