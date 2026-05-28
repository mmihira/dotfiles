return {
	name = "pm2_ove_logs",
	builder = function()
		local xmake = require("scripts.run.xmake")
		local file_full_path = vim.api.nvim_buf_get_name(0)
		local build, err = xmake.resolve_build_target(file_full_path)

		if not build then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end

		return {
			name = "pm2_ove_logs",
			cmd = "pm2 logs --raw ove",
			cwd = build.root,
			components = {
				{ "open_output", on_start = "always", direction = "float", focus = true },
				{ "unique", soft = true },
				"default",
			},
		}
	end,
	condition = {
		filetype = { "cpp" },
	},
}
