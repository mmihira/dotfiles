local M = {}

local plenary = require("plenary")
local path = require("plenary.path")
local exec_in_term = require("scripts.run.term")
local project = require("scripts.run.project")

local handlers = {
	lua = require("scripts.run.lua"),
	sh = require("scripts.run.bash"),
	go = require("scripts.run.go"),
	odin = require("scripts.run.odin"),
	cpp = require("scripts.run.cpp"),
	c = require("scripts.run.cpp"),
	dot = require("scripts.run.dot"),
	csv = require("scripts.run.csv"),
}

local resolve_handler = function(filetype, file_full_path)
	if filetype == "odin" or file_full_path:match("%.odin$") then
		return handlers.odin
	end

	return handlers[filetype]
end

local run_file = function()
	local file_full_path = vim.api.nvim_buf_get_name(0)
	local file_path = path.new(file_full_path)
	local filetype = plenary.filetype.detect_from_extension(file_full_path)
	local handler = resolve_handler(filetype, file_full_path)

	if handler then
		handler(file_path)
	end
end

local build_file_target = function()
	local file_full_path = vim.api.nvim_buf_get_name(0)
	local file_path = path.new(file_full_path)
	local xmake_root = project.find_project_root(file_path, { "xmake.lua" })

	if not xmake_root then
		vim.notify("No xmake.lua root found", vim.log.levels.ERROR)
		return
	end

	local root = xmake_root:absolute()
	local rel = file_full_path:sub(#root + 2)
	local script = string.format([[
import("core.project.project")
for _, target in pairs(project.targets()) do
    for _, src in ipairs(target:sourcefiles()) do
        if src:find("%s", 1, true) then
            print(target:name())
            return
        end
    end
end
]], rel)
	local result = vim.fn.system(
		string.format("cd '%s' && echo %s | xmake lua --stdin 2>/dev/null", root, vim.fn.shellescape(script))
	)
	local target = result:match("^([^\n]+)")

	if not target or target == "" then
		vim.notify("Could not find xmake target for " .. rel, vim.log.levels.WARN)
		return
	end

	exec_in_term(string.format("(cd '%s' && xmake build %s)", root, target))
end

M.run_file = run_file
M.build_file_target = build_file_target

return M
