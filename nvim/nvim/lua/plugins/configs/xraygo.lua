local present, xray = pcall(require, "go")
if not present then
	return
end

local path = require("mason-core.path")
local install_root_dir = path.concat({ vim.fn.stdpath("data"), "lsp_servers" })

xray.setup({
	gopls_cmd = { install_root_dir .. "/go/gopls" },
	fillstruct = "gopls",
	dap_debug = false,
	dap_debug_gui = false,
	lsp_diag_hdlr = false, 
	lsp_diag_underline = false,
	lsp_diag_signs = false,
	lsp_diag_update_in_insert = false,
	lsp_document_formatting = false,
  textobjects = true, -- enable default text jobects through treesittter-text-objects
	lsp_inlay_hints = {
		enable = false,
	},
})

-- local foo = require("mason-lspconfig").get_installed_servers()
-- print(vim.inspect(foo))

-- local mason_servers = require'mason.servers'

-- local server_available, requested_server = mason_servers.get_server("gopls")
-- print(server_available)
-- print(requested_server)
-- if server_available then
--     requested_server:on_ready(function ()
--         local opts = require'go.lsp'.config()
--         requested_server:setup(opts)
--     end)
--     if not requested_server:is_installed() then
--         -- Queue the server to be installed
--         requested_server:install()
--     end
-- end
