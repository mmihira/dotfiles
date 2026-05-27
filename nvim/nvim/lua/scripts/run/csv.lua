local exec_in_term = require("scripts.run.term")

return function(_)
	local root_path = vim.fn.expand("~/c/ove/")
	local run_cmd = "(cd " .. root_path .. "; ./out/Debug/ove --stats)"
	exec_in_term(run_cmd)
end
