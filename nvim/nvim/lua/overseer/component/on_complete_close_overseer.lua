local constants = require("overseer.constants")
local STATUS = constants.STATUS

---@type overseer.ComponentFileDefinition
return {
	desc = "Close the Overseer window when a task completes",
	params = {
		success_delay_ms = {
			desc = "Delay before closing after success",
			type = "integer",
			default = 1500,
		},
		failure_delay_ms = {
			desc = "Delay before closing after failure",
			type = "integer",
			default = 0,
		},
		statuses = {
			desc = "Statuses that trigger a close",
			type = "list",
			default = { STATUS.SUCCESS, STATUS.FAILURE },
			subtype = {
				type = "enum",
				choices = STATUS.values,
			},
		},
	},
	constructor = function(params)
		return {
			timer = nil,
			_stop_timer = function(self)
				if self.timer then
					self.timer:stop()
					self.timer:close()
					self.timer = nil
				end
			end,
			on_complete = function(self, task, status)
				if not vim.tbl_contains(params.statuses, status) then
					return
				end

				self:_stop_timer()
				local delay = status == STATUS.SUCCESS and params.success_delay_ms or params.failure_delay_ms
				local close = vim.schedule_wrap(function()
					require("overseer").close()
				end)

				if delay <= 0 then
					close()
					return
				end

				self.timer = vim.uv.new_timer()
				self.timer:start(delay, 0, function()
					self:_stop_timer()
					close()
				end)
			end,
			on_reset = function(self)
				self:_stop_timer()
			end,
			on_dispose = function(self)
				self:_stop_timer()
			end,
		}
	end,
}
