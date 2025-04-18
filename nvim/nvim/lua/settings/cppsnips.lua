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
  ls.s(
    { trig = "inc", name = "#include", dscr = "Insert #include directive" },
    fmt("#include <{}>", {
      ls.i(1, "header"),
    })
  ),
}

ls.add_snippets("cpp", snippets)
