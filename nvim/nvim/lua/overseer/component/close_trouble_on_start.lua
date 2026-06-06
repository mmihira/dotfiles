---@type overseer.ComponentFileDefinition
return {
	desc = "Close trouble.nvim when a task starts",
	constructor = function()
		return {
			on_start = function()
				local ok, trouble = pcall(require, "trouble")
				if not ok then
					return
				end

				trouble.close()
			end,
		}
	end,
}
