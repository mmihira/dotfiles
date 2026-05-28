local M = {}

local function strip_ansi(s)
	return s:gsub("\27%[[%d;]*%a", "")
end

local function trim(s)
	return s and s:gsub("^%s+", ""):gsub("%s+$", "") or nil
end

local function parse_target_name(line)
	return line:match('target%("([^"]+)"') or line:match("target%('([^']+)'")
end

local function load_target_info(cwd, target_name)
	local target_out = strip_ansi(vim.fn.system("xmake show -t " .. vim.fn.shellescape(target_name) .. " 2>&1"))
	if vim.v.shell_error ~= 0 then
		return nil, trim(target_out)
	end

	local target_file = trim(target_out:match("targetfile:%s*([^\n]+)"))
	if not target_file then
		return nil, "could not find targetfile"
	end

	if not target_file:match("^/") then
		target_file = cwd .. "/" .. target_file
	end

	return {
		name = target_name,
		kind = trim(target_out:match("targetkind:%s*([^\n]+)") or target_out:match("kind:%s*([^\n]+)")),
		program = target_file,
	}
end

function M.run()
	local cwd = vim.fn.getcwd()

	if vim.fn.filereadable(cwd .. "/xmake.lua") ~= 1 then
		vim.notify("xmake: no xmake.lua found in the current directory", vim.log.levels.WARN)
		return
	end

	local xmake_lua = io.open(cwd .. "/xmake.lua", "r")
	if not xmake_lua then
		vim.notify("xmake: could not open xmake.lua", vim.log.levels.WARN)
		return
	end

	local xmake_content = xmake_lua:read("*a")
	xmake_lua:close()

	local targets = {}
	local current_target = nil
	for line in xmake_content:gmatch("[^\n]+") do
		local target_name = parse_target_name(line)
		if target_name then
			current_target = { name = target_name, is_default = false }
			table.insert(targets, current_target)
		end
		if current_target and line:match("set_default%s*%(%s*true%s*%)") then
			current_target.is_default = true
		end
	end

	if #targets == 0 then
		vim.notify("xmake: no target() found in xmake.lua", vim.log.levels.WARN)
		return
	end

	local preferred_target = targets[1]
	for _, target in ipairs(targets) do
		if target.is_default then
			preferred_target = target
			break
		end
	end

	local target_order = { preferred_target.name }
	for _, target in ipairs(targets) do
		if target.name ~= preferred_target.name then
			table.insert(target_order, target.name)
		end
	end

	local launch_target = nil
	local preferred_target_info = nil
	local last_error = nil
	for _, target_name in ipairs(target_order) do
		local info, err = load_target_info(cwd, target_name)
		if not info then
			last_error = err
		else
			if target_name == preferred_target.name then
				preferred_target_info = info
			end
			if info.kind == "binary" or vim.fn.executable(info.program) == 1 then
				launch_target = info
				break
			end
		end
	end

	if not launch_target then
		if preferred_target_info then
			local kind = preferred_target_info.kind or "non-runnable"
			vim.notify(
				("xmake: target %s is %s at %s; build or choose an executable target before debugging"):format(
					preferred_target_info.name,
					kind,
					preferred_target_info.program
				),
				vim.log.levels.WARN
			)
		else
			vim.notify(
				("xmake: could not inspect target %s%s"):format(
					preferred_target.name,
					last_error and (": " .. last_error) or ""
				),
				vim.log.levels.WARN
			)
		end
		return
	end

	if launch_target.name ~= preferred_target.name then
		vim.notify(
			("xmake: target %s is not runnable, debugging %s instead"):format(preferred_target.name, launch_target.name),
			vim.log.levels.INFO
		)
	end

	if vim.fn.executable(launch_target.program) ~= 1 then
		vim.notify(
			("xmake: %s is not executable; run `xmake build %s` first"):format(
				launch_target.program,
				launch_target.name
			),
			vim.log.levels.WARN
		)
		return
	end

	require("dap").run({
		name = "xmake: " .. launch_target.name,
		type = "lldb",
		request = "launch",
		program = launch_target.program,
		cwd = cwd,
		initCommands = vim.g.dap_lldb_init_commands,
	})
end

return M
