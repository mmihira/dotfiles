---@type overseer.ComponentFileDefinition
return {
	desc = "Notify when task diagnostics are available in the quickfix list",
	params = {
		command = {
			desc = "Command to show in the notification",
			type = "string",
			default = "Trouble qflist",
		},
	},
	constructor = function(params)
		return {
			on_result = function(self, task, result)
				local diagnostics = result.diagnostics or {}
				if vim.tbl_isempty(diagnostics) then
					return
				end

				local message = string.format(
					"%d build diagnostic%s added to quickfix. Run :%s",
					#diagnostics,
					#diagnostics == 1 and "" or "s",
					params.command
				)

				vim.notify(message, vim.log.levels.WARN, { title = task.name })
			end,
		}
	end,
}
