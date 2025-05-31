local present, lspconfig = pcall(require, "lspconfig")
if not present then
	return
end

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

-- Gopls
lspconfig.gopls.setup(goplsconfig)

-- Lua
luaconfig = lsplib.mk_config()
luaconfig.settings = { Lua = { diagnostics = { globals = { "vim" } } } }
lspconfig.lua_ls.setup(luaconfig)

-- Python
lspconfig.pyright.setup({})

-- HTML
lspconfig.html.setup({})

-- HTML
lspconfig.ts_ls.setup(defaultconfig)

local cppconfig = {
	on_attach = lsplib.mk_config().on_attach,
	keys = {
		{ "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
	},
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern(
			"Makefile",
			"configure.ac",
			"configure.in",
			"config.h.in",
			"meson.build",
			"meson_options.txt",
			"build.ninja"
		)(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname) or require(
			"lspconfig.util"
		).find_git_ancestor(fname)
	end,
	capabilities = {
		offsetEncoding = { "utf-16" },
	},
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--fallback-style=llvm",
	},
	init_options = {
		usePlaceholders = true,
		completeUnimported = true,
		clangdFileStatus = true,
	},
}
-- C++
lspconfig.clangd.setup(cppconfig)
-- vim.lsp.set_log_level("debug")
-- vim.lsp.config('clangd', cppconfig)
-- vim.lsp.enable('clangd')

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
