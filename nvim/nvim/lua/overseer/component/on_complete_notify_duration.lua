local Notifier = require("overseer.notifier")
local constants = require("overseer.constants")
local util = require("overseer.util")
local STATUS = constants.STATUS

---@type overseer.ComponentFileDefinition
return {
	desc = "vim.notify when task succeeds, including task duration",
	constructor = function()
		return {
			notifier = Notifier.new({ system = "never" }),
			on_complete = function(self, task, status)
				if status ~= STATUS.SUCCESS then
					return
				end

				local duration = nil
				if task.time_start and task.time_end then
					duration = util.format_duration(task.time_end - task.time_start)
				end

				local message = duration and string.format("SUCCESS %s in %s", task.name, duration)
					or string.format("SUCCESS %s", task.name)

				self.notifier:notify(message, vim.log.levels.INFO)
			end,
		}
	end,
}
