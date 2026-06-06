local layout = require("overseer.layout")
local render = require("overseer.render")
local util = require("overseer.util")
local STATUS = require("overseer.constants").STATUS

local SUMMARY_NS = vim.api.nvim_create_namespace("overseer_center_float_summary")

local function close_win(winid)
	if winid and vim.api.nvim_win_is_valid(winid) then
		vim.api.nvim_win_close(winid, true)
	end
end

---@type overseer.ComponentFileDefinition
return {
	desc = "Open task output in a centered floating window",
	params = {
		width_fraction = {
			desc = "Fraction of editor width to use",
			type = "integer",
			default = 30,
		},
		height_fraction = {
			desc = "Fraction of editor height to use",
			type = "integer",
			default = 100,
		},
		focus = {
			desc = "Focus the output window when it is opened",
			type = "boolean",
			default = false,
		},
		close_on_complete = {
			desc = "Close the output window when the task completes",
			type = "boolean",
			default = true,
		},
		close_delay_ms = {
			desc = "Delay before closing after task completion",
			type = "integer",
			default = 0,
		},
	},
	constructor = function(params)
		return {
			bufnr = nil,
			winid = nil,
			summary_winid = nil,
			resize_augroup = nil,
			update_augroup = nil,
			timer = nil,
			completed_status = nil,
			close = function(self)
				if self.timer then
					self.timer:stop()
					self.timer:close()
					self.timer = nil
				end
				close_win(self.winid)
				close_win(self.summary_winid)
				if self.resize_augroup then
					pcall(vim.api.nvim_del_augroup_by_id, self.resize_augroup)
				end
				if self.update_augroup then
					pcall(vim.api.nvim_del_augroup_by_id, self.update_augroup)
				end
				self.winid = nil
				self.summary_winid = nil
				self.resize_augroup = nil
				self.update_augroup = nil
			end,
			get_dimensions = function()
				local editor_width = layout.get_editor_width()
				local width = math.floor(editor_width * params.width_fraction / 100)
				local editor_height = layout.get_editor_height()
				local height = math.max(4, math.floor(editor_height * params.height_fraction / 100))
				local summary_height = math.min(5, math.max(3, math.floor(height * 0.2)))
				local output_height = math.max(1, height - summary_height)
				local row = math.floor((editor_height - height) / 2)
				local col = math.floor((editor_width - width) / 2)

				return {
					row = row,
					col = col,
					width = width,
					height = height,
					summary_height = summary_height,
					output_row = row + summary_height,
					output_height = output_height,
				}
			end,
			update_summary = function(self, task)
				if not self.bufnr or not vim.api.nvim_buf_is_valid(self.bufnr) then
					return
				end

				util.render_buf_chunks(self.bufnr, SUMMARY_NS, render.format_standard(task))
			end,
			open = function(self, task)
				local output_bufnr = task:get_bufnr()
				if not output_bufnr then
					return
				end

				close_win(self.winid)
				close_win(self.summary_winid)

				if not self.bufnr or not vim.api.nvim_buf_is_valid(self.bufnr) then
					self.bufnr = vim.api.nvim_create_buf(false, true)
					vim.bo[self.bufnr].bufhidden = "wipe"
					vim.bo[self.bufnr].filetype = "OverseerCenterFloat"
				end
				self:update_summary(task)

				local dims = self:get_dimensions()
				self.summary_winid = vim.api.nvim_open_win(self.bufnr, false, {
					relative = "editor",
					row = dims.row,
					col = dims.col,
					width = dims.width,
					height = dims.summary_height,
					style = "minimal",
					border = nil,
				})
				self.winid = vim.api.nvim_open_win(output_bufnr, params.focus, {
					relative = "editor",
					row = dims.output_row,
					col = dims.col,
					width = dims.width,
					height = dims.output_height,
					style = "minimal",
					border = nil,
				})

				for _, winid in ipairs({ self.summary_winid, self.winid }) do
					vim.api.nvim_set_option_value("number", false, { scope = "local", win = winid })
					vim.api.nvim_set_option_value("relativenumber", false, { scope = "local", win = winid })
					vim.api.nvim_set_option_value("signcolumn", "no", { scope = "local", win = winid })
					vim.api.nvim_set_option_value("wrap", false, { scope = "local", win = winid })
				end

				self.resize_augroup = vim.api.nvim_create_augroup("OverseerCenterFloat" .. task.id, { clear = true })
				self.update_augroup =
					vim.api.nvim_create_augroup("OverseerCenterFloatSummary" .. task.id, { clear = true })

				vim.api.nvim_create_autocmd("VimResized", {
					group = self.resize_augroup,
					desc = "Resize centered floating Overseer output",
					callback = function()
						if
							not self.winid
							or not vim.api.nvim_win_is_valid(self.winid)
							or not self.summary_winid
							or not vim.api.nvim_win_is_valid(self.summary_winid)
						then
							return true
						end

						local resized_dims = self:get_dimensions()
						vim.api.nvim_win_set_config(self.summary_winid, {
							relative = "editor",
							row = resized_dims.row,
							col = resized_dims.col,
							width = resized_dims.width,
							height = resized_dims.summary_height,
							style = "minimal",
							border = nil,
						})
						vim.api.nvim_win_set_config(self.winid, {
							relative = "editor",
							row = resized_dims.output_row,
							col = resized_dims.col,
							width = resized_dims.width,
							height = resized_dims.output_height,
							style = "minimal",
							border = nil,
						})
					end,
				})

				vim.api.nvim_create_autocmd("User", {
					group = self.update_augroup,
					pattern = "OverseerListUpdate",
					desc = "Update centered floating Overseer summary",
					callback = function()
						self:update_summary(task)
					end,
				})
			end,
			on_start = function(self, task)
				self:open(task)
			end,
			on_output = function(self, task)
				self:update_summary(task)
			end,
			on_result = function(self, task)
				self:update_summary(task)
			end,
			on_complete = function(self, task, status)
				self.completed_status = status
				if params.close_on_complete then
					if params.close_delay_ms <= 0 then
						self:close()
						return
					end

					self.timer = vim.uv.new_timer()
					self.timer:start(
						params.close_delay_ms,
						0,
						vim.schedule_wrap(function()
							self:close()
						end)
					)
				end
			end,
			on_dispose = function(self) end,
		}
	end,
}
