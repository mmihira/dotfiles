local present, treesitter = pcall(require, "nvim-treesitter")
if not present then
	return
end

treesitter.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

treesitter.install({ "cpp", "go", "lua" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "go", "lua" },
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
