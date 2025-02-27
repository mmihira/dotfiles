tterm = require("toggleterm")

local floa_vim_test_callback = function(opts)
  tterm.exec(opts, 2, nil, nil, "float", "test_term", false, true)
end

vim.g["test#custom_strategies"] = { custom_toggleterm = floa_vim_test_callback }
vim.g["test#strategy"] = "custom_toggleterm"
vim.g["test#go#go#options"] = "-v"
vim.g["test#go#gotest#options"] = "-v -count 1"
