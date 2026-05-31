local present, lualine = pcall(require, "lualine")
if not present then
	return
end

local overseer = require("overseer")

local modes = {
	n = "N",
	no = "O",
	nov = "O",
	noV = "O",
	["no\22"] = "O",
	niI = "N",
	niR = "N",
	niV = "N",
	nt = "N",
	v = "V",
	vs = "V",
	V = "VL",
	Vs = "VL",
	["\22"] = "VB",
	["\22s"] = "VB",
	s = "S",
	S = "SL",
	["\19"] = "SB",
	i = "I",
	ic = "I",
	ix = "I",
	R = "R",
	Rc = "R",
	Rx = "R",
	Rv = "VR",
	Rvc = "VR",
	Rvx = "VR",
	c = "C",
	cv = "EX",
	ce = "EX",
	r = "P",
	rm = "M",
	["r?"] = "?",
	["!"] = "!",
	t = "T",
}

local function short_mode()
	return modes[vim.fn.mode()] or vim.fn.mode():upper()
end

lualine.setup({
	sections = {
		lualine_a = {
			short_mode,
		},
		lualine_b = {},
		lualine_c = {
			"filename",
		},
		lualine_x = {
			{
				"overseer",
				label = "", -- Prefix for task counts
				colored = true, -- Color the task icons and counts
				-- symbols = {
				--   [overseer.STATUS.FAILURE] = "F:",
				--   [overseer.STATUS.CANCELED] = "C:",
				--   [overseer.STATUS.SUCCESS] = "S:",
				--   [overseer.STATUS.RUNNING] = "R:",
				-- },
				unique = false, -- Unique-ify non-running task count by name
				status = nil, -- List of task statuses to display
				filter = nil, -- Function to filter out tasks you don't wish to display
			},
		},
		lualine_y = {},
		lualine_z = {
			"location",
		},
	},
})
