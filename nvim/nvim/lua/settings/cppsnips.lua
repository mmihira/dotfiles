local present, ls = pcall(require, "luasnip")
if not present then
	return
end

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local ai = require("luasnip.nodes.absolute_indexer")
local events = require("luasnip.util.events")
local partial = require("luasnip.extras").partial

local snippets = {
	-- fmt
	ls.s(
		{ trig = "fp", name = "fmt::println", dscr = "fmt::println" },
		fmt('spdlog::info("{val} = {ix}", {s});', {
			val = ls.i(1, "val"),
			ix = ls.i(2, "{}"),
			s = ls.i(3, ""),
		})
	),
	-- c++20 module
	ls.s(
		{ trig = "mod", name = "C++20 module", dscr = "C++20 module declaration" },
		fmt(
			[[
module;

{}

export module {};

{}
]],
			{
				ls.i(1, "// global module fragment"),
				ls.i(2, "module_name"),
				ls.i(3, "// module interface"),
			}
		)
	),
}

ls.add_snippets("cpp", snippets)
