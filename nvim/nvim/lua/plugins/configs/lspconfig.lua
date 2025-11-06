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
		"/Users/mihira/.local/share/nvim/mason/bin/clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--fallback-style=llvm",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	init_options = {
		usePlaceholders = true,
		completeUnimported = true,
		clangdFileStatus = true,
	},
})

-- C++
vim.lsp.config("clangd", cppconfig)
vim.lsp.enable("clangd")

vim.lsp.config("copilot", {})
vim.lsp.enable("copilot")

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
