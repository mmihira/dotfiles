local M = {}

local plenary = require("plenary")
local path = require("plenary.path")
local exec_in_term = require("scripts.run.term")
local xmake = require("scripts.run.xmake")

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
	local build, err = xmake.resolve_build_target(file_full_path)

	if not build then
		vim.notify(err, vim.log.levels.ERROR)
		return
	end

	if not build.target then
		vim.notify("Could not find xmake target for " .. build.rel, vim.log.levels.WARN)
		return
	end

	exec_in_term(
		string.format(
			"(cd '%s' && xmake build %s | tee '%s'/build/build.log)",
			build.root,
			vim.fn.shellescape(build.target),
			build.root
		)
	)
end

M.run_file = run_file
M.build_file_target = build_file_target

return M
