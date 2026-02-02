local present, sidekick = pcall(require, "sidekick")
if not present then
	return
end

sidekick.setup({
	nes = {
		enabled = function(buf)
			return false
		end,
	},
	cli = {
		win = {
			layout = "float",
			keys = {
				hide_t = { "<c-,>", "hide" },
				files = { "<c-f>", "files", mode = "nt", desc = "open file picker" },
				buffers = { "<c-b>", "buffers", mode = "nt", desc = "open buffer picker" },
			},
		},
		tools = {
			claude = {
				cmd = { "/Users/mihira/.local/bin/claude" },
				url = "https://github.com/anthropics/claude-code",
			},
		},
	},
})
