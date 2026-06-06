---@type overseer.ComponentFileDefinition
return {
	desc = "Keep visible task output windows scrolled to the bottom",
	constructor = function()
		local scroll = vim.schedule_wrap(function(task)
			local bufnr = task:get_bufnr()
			if not bufnr then
				return
			end

			local line_count = vim.api.nvim_buf_line_count(bufnr)
			for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
				if vim.api.nvim_win_is_valid(winid) then
					vim.api.nvim_win_call(winid, function()
						vim.fn.winrestview({
							lnum = line_count,
							topline = line_count,
						})
					end)
				end
			end
		end)

		return {
			on_start = function(self, task)
				scroll(task)
			end,
			on_output = function(self, task)
				scroll(task)
			end,
			on_result = function(self, task)
				scroll(task)
			end,
		}
	end,
}
