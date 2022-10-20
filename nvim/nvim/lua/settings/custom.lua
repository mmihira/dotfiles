local cmd = "go get -u github.com/motemen/go-iferr/cmd/goiferr"
local popup = require("plenary.popup")

-- vim.fn.jobstart(cmd, {
-- 	on_exit = function(_, code, _)
-- 		if code == 0 then
-- 			output.show_success(prefix, string.format("Installed %s", tool.name))
-- 		end
-- 	end,
-- 	on_stderr = function(_, data, _)
-- 		local results = table.concat(data, "\n")
-- 		output.show_error(prefix, results)
-- 	end,
-- })

function message(message)
	local buf_nr = vim.api.nvim_create_buf(false, true)
	local win_height = vim.fn.winheight(0)
	local buf_nr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf_nr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf_nr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf_nr, "filetype", "nvimgo-popup")
	vim.api.nvim_buf_set_lines(buf_nr, 0, -1, true, { message })
	vim.api.nvim_buf_set_option(buf_nr, "modifiable", true)
	-- modifiable at first, then set readonly
	-- local actual_content_height = vim.api.nvim_buf_line_count(buf_nr)
	-- local title = opts.title
	-- local pos = opts.pos
	-- local top = win_height - (math.min(pos.height, actual_content_height) + 1)
	--
	local popup_win, popup_opts = popup.create(buf_nr, {
		title = "test",
		col = 2,
		border = { 1, 1, 1, 1 },
		cursorline = true,
		focusable = true,
		maxheight = 20,
		minwidth = 80,
		width = 30,
		highlight = "GoTestResult",
	})
end

message("hello 2")
