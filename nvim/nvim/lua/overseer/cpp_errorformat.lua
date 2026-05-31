return table.concat({
	"%Eerror: %f:%l:%c: error: %m",
	"%Eerror: %f:%l:%c: fatal error: %m",
	"%Wwarning: %f:%l:%c: warning: %m",
	"%Inote: %f:%l:%c: note: %m",
	"%Eerror: %f:%l:%c: %m",
	"%Wwarning: %f:%l:%c: %m",
	"%Inote: %f:%l:%c: %m",
	"%E%f:%l:%c: error: %m",
	"%E%f:%l:%c: fatal error: %m",
	"%W%f:%l:%c: warning: %m",
	"%I%f:%l:%c: note: %m",
	"%-G%.%#",
}, ",")
