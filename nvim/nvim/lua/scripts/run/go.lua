local exec_in_term = require("scripts.run.term")
local project = require("scripts.run.project")

return function(file_path)
	local parent_path = project.find_project_root(file_path, { "Makefile" })

	if parent_path then
		local run_cmd = "(cd " .. parent_path:absolute() .. "; make run)"
		exec_in_term(run_cmd)
	else
		print("Could not found makefile")
	end
end
