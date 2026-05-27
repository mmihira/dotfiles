local exec_in_term = require("scripts.run.term")

local parse_run_block = function(file_full_path)
	local lines = vim.fn.readfile(file_full_path)
	if #lines == 0 or not lines[1]:match("^%-%-%s*ASPERITE") then
		return nil
	end

	local capturing = false
	local cmd_parts = {}

	for _, line in ipairs(lines) do
		if line:match("^%-%-%s*RUN_START") then
			capturing = true
		elseif line:match("^%-%-%s*RUN_END") then
			break
		elseif capturing then
			local part = line:gsub("^%-%-", ""):gsub("^%s+", ""):gsub("\\%s*$", "")
			table.insert(cmd_parts, part)
		end
	end

	if #cmd_parts == 0 then
		return nil
	end

	return table.concat(cmd_parts, " ")
end

return function(file_path)
	local file_full_path = file_path:absolute()
	local cmd = parse_run_block(file_full_path)

	if cmd then
		local parent_dir = vim.fn.fnamemodify(file_full_path, ":h")
		exec_in_term("(cd " .. parent_dir .. "; " .. cmd .. ")")
		return
	end

	local parent_path = file_path:parent()
	local rel = file_path:make_relative(parent_path:absolute())
	local run_cmd = "(cd " .. parent_path:absolute() .. "; luajit " .. rel .. ")"
	exec_in_term(run_cmd)
end
