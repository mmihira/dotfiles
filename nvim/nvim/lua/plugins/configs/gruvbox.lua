local present, gruvbox = pcall(require, "gruvbox")
if not present then
	return
end

gruvbox.setup({
	invert_selection = false,
	contrast = "soft",
})

vim.cmd("colorscheme gruvbox")
