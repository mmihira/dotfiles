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

local wrapped_items = parse({
	"src/ui/playerview/playerviewhotbar.cpp:110:64: warning: ISO C++ requires field designators to be specified in declaration order; field 'attachTo' wil",
	"l be initialized after field 'pointerCaptureMode' [-Wreorder-init-list]",
	"  110 |                                          .pointerCaptureMode = CLAY_POINTER_CAPTURE_MODE_PASSTHROUGH,",
	"      |                                          ~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"src/clay/clay.h:143:149: note: expanded from macro 'CLAY'",
	"  143 |             CLAY__ELEMENT_DEFINITION_LATCH = (Clay__OpenElementWithId(id), Clay__ConfigureOpenElement(CLAY__CONFIG_WRAPPER(Clay_ElementDeclaration, __VA_ARGS__)), 0); \\",
	"      |                                                                                                                                                     ^~~~~~~~~~~",
	"src/ui/playerview/playerviewhotbar.cpp:109:54: note: previous initialization for field 'attachTo' is here",
	"  107 |                                          .offset = {64 - 20, 64 - 18},",
	"      |                                          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"      |                                          .offset = {64 - 20, 64 - 18}",
	"  108 |                                          .zIndex = 100,",
	"      |                                          ~~~~~~~~~~~~~",
	"      |                                          .zIndex = 100",
}, root)

assert_equal(#wrapped_items, 3, "wrapped valid item count")

local wrapped_warning = wrapped_items[1]
assert_equal(wrapped_warning.type, "W", "wrapped type")
assert_equal(wrapped_warning.lnum, 110, "wrapped line")
assert_equal(wrapped_warning.col, 64, "wrapped column")
assert_equal(
	wrapped_warning.text,
	"ISO C++ requires field designators to be specified in declaration order; field 'attachTo' wil\nl be initialized after field 'pointerCaptureMode' [-Wreorder-init-list]",
	"wrapped message"
)
assert_equal(
	vim.api.nvim_buf_get_name(wrapped_warning.bufnr),
	root .. "/src/ui/playerview/playerviewhotbar.cpp",
	"wrapped filename"
)

print("cpp_build_errorformat_test ok")
