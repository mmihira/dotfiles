local present, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not present then
	return
end

local lsplib = require("plugins/configs/lspl")

local defaultconfig = { on_attach = lsplib.mk_config().on_attach }
local goplsconfig = {
	on_attach = lsplib.mk_config().on_attach,
	settings = {
		gopls = {
			experimentalPostfixCompletions = true,
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
		},
	},
	init_options = {
		usePlaceholders = true,
	},
}

-- gls
vim.lsp.config("glsl_analyzer", defaultconfig)
vim.lsp.enable("glsl_analyzer")

-- Markdown
vim.lsp.config("marksman", defaultconfig)
vim.lsp.enable("marksman")

-- Gopls
vim.lsp.config("gopls", goplsconfig)
vim.lsp.enable("gopls")

-- Lua
luaconfig = lsplib.mk_config()
luaconfig.settings = { Lua = { diagnostics = { globals = { "vim" } } } }
luaconfig = lsplib.mk_config()
vim.lsp.enable("lua_ls", luaconfig)

-- Python
vim.lsp.enable("pyright")

-- HTML
vim.lsp.enable("html")

-- HTML
vim.lsp.config("ts_ls", defaultconfig)
vim.lsp.enable("ts_ls")

-- C++ LSPs
local cpplspconfig = vim.tbl_deep_extend("force", lsplib.mk_config(), {
  capabilities = {
    offsetEncoding = { "utf-8", "utf-16" },
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
  },
  cmd = { "/Users/mihira/c/cpplsp/build/macosx/arm64/debug/cpplsp", "--lsp" },
  filetypes = { "c", "cpp", "cc", "cxx", "h", "hpp", "hh", "hxx", "cppm" },
  root_markers = { "xmake.lua", "CMakeLists.txt", ".git" },
})
vim.lsp.config("cpplsp", cpplspconfig)
vim.lsp.enable("cpplsp")
vim.opt.runtimepath:append("/Users/mihira/c/cpplsp")
require("cpplsp").setup()

-- clangd: set to "format_only" to just use clang-format, or "full" for all capabilities
local clangd_mode = "format_only"
-- local clangd_mode = "all"

local cppconfig = lsplib.mk_config()
-- default is here https://github.com/neovim/nvim-lspconfig/blob/master/lsp/clangd.lua
cppconfig = vim.tbl_deep_extend("force", cppconfig, {
  keys = {
    { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
  },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
  },
  capabilities = {
    offsetEncoding = { "utf-8", "utf-16" },
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
  },
  cmd = {
    "/opt/homebrew/opt/llvm/bin/clangd",
    "--clang-tidy",
    "--experimental-modules-support",
    "--fallback-style=llvm",
  },
  -- cmd = {
  -- 	-- "/Users/mihira/.local/share/nvim/mason/bin/clangd",
  -- 	"/opt/homebrew/opt/llvm/bin/clangd",
  -- 	"--background-index",
  -- 	"--clang-tidy",
  -- 	"--header-insertion=iwyu",
  -- 	"--completion-style=detailed",
  -- 	"--experimental-modules-support",
  -- 	"--function-arg-placeholders",
  -- 	"--fallback-style=llvm",
  -- },
  filetypes = { "c", "cpp", "cppm", "h", "proto" },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})

if clangd_mode == "format_only" then
  local full_on_attach = cppconfig.on_attach
  cppconfig.on_attach = function(client, bufnr)
    if full_on_attach then
      full_on_attach(client, bufnr)
    end
    -- Disable everything except formatting so clangd doesn't conflict with cpplsp
    client.server_capabilities.completionProvider = nil
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.definitionProvider = false
    client.server_capabilities.referencesProvider = false
    client.server_capabilities.signatureHelpProvider = nil
    client.server_capabilities.diagnosticProvider = nil
    client.server_capabilities.codeActionProvider = false
    client.server_capabilities.documentHighlightProvider = false
    client.server_capabilities.renameProvider = false
    client.server_capabilities.semanticTokensProvider = nil
    client.server_capabilities.inlayHintProvider = nil
  end
end

vim.lsp.config("clangd", cppconfig)
vim.lsp.enable("clangd")

-- Hide the dianostic virtual text
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = false,
})

-- Show diagnostics on hover
vim.api.nvim_command("autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focusable = false})")

vim.diagnostic.config({ virtual_text = { current_line = true } })
vim.o.winborder = "single"
