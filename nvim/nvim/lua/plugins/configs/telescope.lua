local present, tele_actions = pcall(require, "telescope.actions")
if not present then
	return
end

local present, telescope = pcall(require, "telescope")
if not present then
	return
end

telescope.setup({
	defaults = {
		initial_mode = "normal",
		layout_config = { prompt_position = "top" },
		mappings = { n = { ["<leader>q"] = "close" } },
	},
})
