local tterm = require("toggleterm")

return function(command)
	tterm.exec(command, 1, nil, nil, "float", "main_term", false, true)
end
