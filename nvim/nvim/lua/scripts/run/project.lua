local M = {}

M.find_project_root = function(file_path, marker_names)
	local scan = require("plenary.scandir")
	local parent_path = file_path

	while true do
		local next_parent = parent_path:parent()
		if next_parent:absolute() == parent_path:absolute() then
			return nil
		end

		parent_path = next_parent
		local absolute = parent_path:absolute()
		local out = scan.scan_dir(absolute, { hidden = true, depth = 1, add_dirs = true })
		local found_git = false

		for _, item in ipairs(out) do
			if string.find(item, ".git", 1, true) then
				found_git = true
			end

			for _, marker in ipairs(marker_names) do
				if string.find(item, marker, 1, true) then
					return parent_path
				end
			end
		end

		if found_git then
			return nil
		end
	end
end

return M
