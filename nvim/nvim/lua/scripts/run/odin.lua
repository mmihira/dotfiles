local exec_in_term = require("scripts.run.term")

return function(file_path)
	local parent_path = file_path:parent()
	local run_cmd = "(cd " .. parent_path:absolute() .. "; odin run .)"
	exec_in_term(run_cmd)
end
