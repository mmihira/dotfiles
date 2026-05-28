---@type overseer.ComponentFileDefinition
return {
	desc = "Open trouble.nvim with the quickfix list for task diagnostics",
	params = {
		mode = {
			desc = "Trouble mode to open/close",
			type = "string",
			default = "qflist",
		},
		close = {
			desc = "If true, close Trouble when there are no diagnostics",
			type = "boolean",
			default = false,
		},
		clear_namespace = {
			desc = "If true, clear the task diagnostic namespace on start",
			type = "boolean",
			default = true,
		},
	},
	constructor = function(params)
		local function clear_task_namespace(task)
			if not params.clear_namespace then
				return
			end
			local ns = vim.api.nvim_create_namespace(task.name)
			vim.diagnostic.reset(ns)
		end

		return {
			on_start = function(self, task)
				clear_task_namespace(task)
			end,
			on_result = function(self, task, result)
				local ok, trouble = pcall(require, "trouble")
				if not ok then
					return
				end

				local diagnostics = result.diagnostics or {}
				if vim.tbl_isempty(diagnostics) then
					if params.close then
						trouble.close(params.mode)
					end
					return
				end

				trouble.open(params.mode)
			end,
		}
	end,
}
