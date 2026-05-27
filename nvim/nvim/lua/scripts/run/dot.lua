local exec_in_term = require("scripts.run.term")

return function(file_path)
	local absolute_path = file_path:absolute()
	local filename = absolute_path:match("^.+/(.+)$")
	local output_name = filename:gsub("%.dot$", ".png")
	local output_path = "/tmp/" .. output_name
	local run_cmd = "dot -Tpng " .. absolute_path .. " -o " .. output_path .. " && open -a 'Google Chrome' " .. output_path

	exec_in_term(run_cmd)
end
