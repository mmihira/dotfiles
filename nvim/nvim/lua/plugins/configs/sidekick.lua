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
			},
		},
		tools = {
			claude = {
				cmd = { "/Users/mihira/.claude/local/claude" },
				url = "https://github.com/anthropics/claude-code",
			},
		},
	},
})
