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
  -- Main
  ls.s(
    { trig = "main", name = "Main", dscr = "Create a main function" },
    fmta("func main() {\n\t<>\n}", ls.i(0))
  ),

  -- If call error
  ls.s(
    { trig = "ifc", name = "if call", dscr = "Call a function and check the error" },
    fmt(
      [[
        {val}, {err1} := {func}({args})
        if {err2} != nil {{
          return {err3}
        }}
        {finally}
      ]], {
        val     = ls.i(1, { "val" }),
        err1    = ls.i(2, { "err" }),
        func    = ls.i(3, { "func" }),
        args    = ls.i(4),
        err2    = rep(2),
        err3    = ls.i(5, { "err3" }),
        finally = ls.i(0),
    })
  ),

  ls.s(
    { trig = "ifce", name = "if call err inline", dscr = "Call a function and check the error inline" },
    fmt(
      [[
        if {err1} := ({args}); {err2} != nil {{
          return {err3}
        }}
        {finally}
      ]], {
        err1    = ls.i(1, { "err" }),
        args    = ls.i(2, { "args" }),
        err2    = rep(1),
        err3    = ls.i(3, { "err3" }),
        finally = ls.i(0),
    })
  ),

  -- Function
  ls.s(
    { trig = "fn", name = "Function", dscr = "Create a function or a method" },
    fmt(
      [[
        // {name1} {desc}
        func {rec}{name2}({args}) {ret} {{
          {finally}
        }}
      ]], {
        name1 = rep(2),
        desc  = ls.i(5, "description"),
        rec   = ls.c(1, {
          ls.t(""),
          ls.sn(nil, fmt("({} {}) ", {
            ls.i(1, "r"),
            ls.i(2, "receiver"),
          })),
        }),
        name2 = ls.i(2, "Name"),
        args  = ls.i(3),
        ret   = ls.c(4, {
          ls.i(1, "error"),
          ls.sn(nil, fmt("({}, {}) ", {
            ls.i(1, "ret"),
            ls.i(2, "error"),
          })),
        }),
        finally = ls.i(0),
    })
  ),

  -- errors.Wrap
  ls.s(
    { trig = "erw", dscr = "errors.Wrap" },
    fmt([[errors.Wrap({}, "{}")]], {
      ls.i(1, "err"),
      ls.i(2, "failed to"),
    })
  ),

  -- errors.Wrapf
  ls.s(
    { trig = "erwf", dscr = "errors.Wrapf" },
    fmt([[errors.Wrapf({}, "{}", {})]], {
      ls.i(1, "err"),
      ls.i(2, "failed %v"),
      ls.i(3, "args"),
    })
  ),

  -- for select
  ls.s(
    { trig = "fsel", dscr = "for select" },
    fmt([[
for {{
	  select {{
        case {} <- {}:
			      {}
        default:
            {}
	  }}
}}
]], {
      ls.c(1, {ls.i(1, "ch"), ls.i(2, "ch := ")}),
      ls.i(2, "ch"),
      ls.i(3, "break"),
      ls.i(0, ""),
    })
  ),

  ls.s(
    { trig = "for([%w_]+)", regTrig = true, hidden = true },
	fmt(
		[[
for  {} := 0; {} < {}; {}++ {{
  {}
}}
{}
    ]],
		{
			ls.d(1, function(_, snip)
				return ls.sn(1, ls.i(1, snip.captures[1]))
			end),
			rep(1),
			ls.c(2, { ls.i(1, "num"), ls.sn(1, { ls.t("len("), ls.i(1, "arr"), ls.t(")") }) }),
			rep(1),
			ls.i(3, "// TODO:"),
			ls.i(4),
		}
	)
),
  -- type switch
  ls.s(
    { trig = "tysw", dscr = "type switch" },
    fmt([[
switch {} := {}.(type) {{
    case {}:
        {}
    default:
        {}
}}
]], {
      ls.i(1, "v"),
      ls.i(2, "i"),
      ls.i(3, "int"),
      ls.i(4, 'fmt.Println("int")'),
      ls.i(0, ""),
    })
  ),
  -- fmt.Sprintf
  ls.s(
    { trig = "spn", dscr = "fmt.Sprintf" },
    fmt([[fmt.Sprintf("{}%{}", {})]], {
      ls.i(1, "msg "),
      ls.i(2, "+v"),
      ls.i(2, "arg"),
    })
  ),

  -- build tags
  ls.s(
    { trig = "//tag", dscr = "// +build tags" },
    fmt([[// +build:{}{}]], {
      ls.i(1, "integration"),
      ls.i(2, ",unit"),
    })
  ),

  -- Nolint
  ls.s(
    { trig = "nolt", dscr = "ignore linter" },
    fmt([[// nolint:{}{}]], {
      ls.i(1, "funlen"),
      ls.i(2, ",cyclop"),
    })
  ),

  -- defer recover
  ls.s(
    { trig = "dfr", dscr = "defer recover" },
    fmt(
      [[
        defer func() {{
            if err := recover(); err != nil {{
       	        {}
            }}
        }}()]], {
      ls.i(1, ""),
    })
  ),

  -- Allocate Slices and Maps
  ls.s(
    { trig = "mk", name = "Make", dscr = "Allocate map or slice" },
    fmt("{} {}= make({})\n{}", {
      ls.i(1, "name"),
      ls.i(2),
      ls.c(3, {
        fmt("[]{}, {}", { ls.r(1, "type"), ls.i(2, "len") }),
        fmt("[]{}, 0, {}", { ls.r(1, "type"), ls.i(2, "len") }),
        fmt("map[{}]{}, {}", { ls.r(1, "type"), ls.i(2, "values"), ls.i(3, "len") }),
      }, {
        stored = { -- FIXME: the default value is not set.
          type = ls.i(1, "type"),
        },
      }),
      ls.i(0),
    }),
    in_fn
  ),

  ls.s(
    { trig = "sf", name = "[]f64", dscr = "Slice Float64" },
    fmt("{} {} := []float64{{}}", {
      ls.i(1, "name"),
      ls.i(2),
    }),
    in_fn
  ),

  -- Test Cases
  ls.s(
    { trig = "tcs", dscr = "create test cases for testing" },
    fmta(
      [[
        tcs := map[string]struct {
        	<>
        } {
        	// Test cases here
        }
        for name, tc := range tcs {
        	tc := tc
        	t.Run(name, func(t *testing.T) {
        		<>
        	})
        }
      ]],
      { ls.i(1), ls.i(2) }
    )
  ),

  -- gRPC Error
  ls.s(
    { trig = "gerr", dscr = "Return an instrumented gRPC error" },
    fmt('internal.GrpcError({},\n\tcodes.{}, "{}", "{}", {})', {
      ls.i(1, "err"),
      ls.i(2, "Internal"),
      ls.i(3, "Description"),
      ls.i(4, "Field"),
      ls.i(5, "fields"),
    }),
    in_fn
  ),

  ls.s(
    { trig = "hf", name = "http.HandlerFunc", dscr = "http handler" },
    fmt( [[
    func {}(w http.ResponseWriter, r *http.Request) {{
        {}
    }}
]], {
      ls.i(1, "handler"),
      ls.i(2, [[fmt.Fprintf(w, "hello world")"]]),
    })
  ),

  -- deep equal
  ls.s(
    { trig = "deq", name = "reflect Deep equal", dscr = "Compare with deep equal and print error" },
    fmt([[
if !reflect.DeepEqual({}, {}) {{
	_, file, line, _ := runtime.Caller(0)
    fmt.Printf("%s:%d:\n\n\texp: %#v\n\n\tgot: %#v\n\n", filepath.Base(file), line, {}, {})
    t.FailNow()
}}]] , {
      ls.i(1, "expected"),
      ls.i(2, "got"),
      rep(1),
      rep(2),
    })
  ),
  -- Create Mocks
  ls.s(
    { trig = "mock", name = "Mocks create", dscr = "Create a mock with NewFactory" },
    fmt("{} := &mocks.{}({})", {
      ls.i(1, "m"),
      ls.i(2, "NewFactory"),
      ls.i(3, "t"),
    })
  ),

  -- Http request with defer close
  ls.s(
       { trig = 'hreq', name = "http request with defer close", dscr = "create a http request with defer body close" },
    fmt([[
  {}, {} := http.{}("http://{}:" + {} + "/{}")
	if {} != nil {{
		log.Fatalln({})
	}}
	_ = {}.Body.Close()

    ]], {
        ls.i(1, "resp"),
        ls.i(2, "err"),
        ls.c(3, {ls.i(1, "Get"), ls.i(2, "Post"), ls.i(3, "Patch")}),
        ls.i(4, "localhost"),
        ls.i(5, [["8080"]]),
        ls.i(6, "path"),
        rep(2),
        rep(2),
        rep(1),
      }
    )
  ),

  -- Go CMP
  ls.s(
    { trig = "gocmp", dscr = "Create an if block comparing with cmp.Diff" },
    fmt(
      [[
        if diff := cmp.Diff({}, {}); diff != "" {{
        	t.Errorf("(-want +got):\\n%s", diff)
        }}
      ]], {
        ls.i(1, "want"),
        ls.i(2, "got"),
    })
  ),

  -- Require NoError
  ls.s(
    { trig = "noerr", name = "Require No Error", dscr = "Add a require.NoError call" },
    ls.c(1, {
      ls.sn(nil, fmt("require.NoError(t, {})", { ls.i(1, "err") })),
      ls.sn(nil, fmt('require.NoError(t, {}, "{}")', { ls.i(1, "err"), ls.i(2) })),
      ls.sn(nil, fmt('require.NoErrorf(t, {}, "{}", {})', { ls.i(1, "err"), ls.i(2), ls.i(3) })),
    })
  ),

  -- Assert equal
  ls.s(
    { trig = "ae", name = "Assert Equal", dscr = "Add assert.Equal" },
    ls.c(1, {
      ls.sn(nil, fmt('assert.Equal(t, {}, {})', { ls.i(1, "expected"), ls.i(2, "got") })),
      ls.sn(nil, fmt('assert.Equalf(t, {}, {}, "{}", {})', { ls.i(1, "expected"), ls.i(2, "got"), ls.i(3, "got %v not equal to want"), ls.i(4, "got") })),
    })
  ),

  -- Assert Nil
  ls.s(
    { trig = "an", name = "Assert Equal Nil", dscr = "Add assert.Nil" },
    ls.c(1, {
      ls.sn(nil, fmt('assert.Nil(t, {})', { ls.i(1, "got")})),
      ls.sn(nil, fmt('assert.Nilf(t, {}, "{}", {})', { ls.i(1, "got"), ls.i(2, "got %v not equal to want"), ls.i(3, "got") })),
    })
  ),

  -- bench test
  ls.s(
    { trig = "bench", name = "bench test cases ", dscr = "Create benchmark test" },
    fmt([[
	    func Benchmark{}(b *testing.B) {{
	        for i := 0; i < b.N; i++ {{
	     	    {}({})
	        }}
	    }}]]
    , {
      ls.i(1, "MethodName"),
      rep(1),
      ls.i(2, "args")
    })
  ),


  -- Stringer
  ls.s(
    { trig = "strigner", name = "Stringer", dscr = "Create a stringer go:generate" },
    fmt("//go:generate stringer -type={} -output={}_string.go", {
      ls.i(1, "Type"),
      partial(vim.fn.expand, "%:t:r"),
    })
  ),
}

ls.add_snippets("go", snippets)
