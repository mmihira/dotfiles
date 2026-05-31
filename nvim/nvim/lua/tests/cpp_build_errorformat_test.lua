local errorformat = require("overseer.cpp_errorformat")

local function fail(message)
	error(message, 2)
end

local function assert_equal(actual, expected, label)
	if actual ~= expected then
		fail(string.format("%s: expected %s, got %s", label, vim.inspect(expected), vim.inspect(actual)))
	end
end

local function parse(lines, root)
	local cwd = vim.uv.cwd()
	vim.fn.mkdir(root, "p")
	vim.fn.chdir(root)
	local ok, qf = pcall(function()
		return vim.fn.getqflist({
			lines = lines,
			efm = errorformat,
		}).items
	end)
	vim.fn.chdir(cwd)

	if not ok then
		error(qf)
	end

	return vim.tbl_filter(function(item)
		return item.valid == 1
	end, qf)
end

local root = "/private/tmp/nvim-cpp-build-errorformat-test"
local items = parse({
	"[ 88%]: <game_core> compiling.debug src/entities/projector/projectorBuilder.cpp",
	"error: src/entities/projector/projectorBuilder.cpp:56:37: error: no member named 'graphics' in namespace 'cmp'",
	"   56 |     auto &g = registry.emplace<cmp::graphics>(entity);",
	"      |                                     ^~~~~~~~",
	"1 error generated.",
	"  > in src/entities/projector/projectorBuilder.cpp",
}, root)

assert_equal(#items, 1, "valid item count")

local item = items[1]
assert_equal(item.type, "E", "type")
assert_equal(item.lnum, 56, "line")
assert_equal(item.col, 37, "column")
assert_equal(item.text, "no member named 'graphics' in namespace 'cmp'", "message")
assert_equal(vim.api.nvim_buf_get_name(item.bufnr), root .. "/src/entities/projector/projectorBuilder.cpp", "filename")

print("cpp_build_errorformat_test ok")
