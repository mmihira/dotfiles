local Popup = require("nui.popup")

local M = {}

local popup = nil

function M.toggle()
	if popup and popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
		popup:unmount()
		popup = nil
		return
	end

	popup = Popup({
		enter = false,
		focusable = false,
		border = {
			style = "rounded",
		},
		position = {
			row = 1,
			col = "100%",
		},
		relative = "editor",
		size = {
			width = 30,
			height = 1,
		},
	})

	popup:mount()
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, { " Hello from floating window! " })
end

return M
