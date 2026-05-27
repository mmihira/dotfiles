local exec_in_term = require("scripts.run.term")

return function(file_path)
	local parent_path = file_path:parent()
	local rel = file_path:make_relative(parent_path:absolute())
	local run_cmd = "(cd " .. parent_path:absolute() .. "; ./" .. rel .. ")"
	exec_in_term(run_cmd)
end
