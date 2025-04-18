tterm = require("toggleterm")

local floa_vim_test_callback = function(opts)
  if opts:find("go test") then
    tterm.exec(opts, 2, nil, nil, "float", "test_term", false, true)
  else
    cmd = "(cd ./out/Debug && make run_tests_target)"
    tterm.exec(cmd, 2, nil, nil, "float", "test_term", false, true)
  end
end

vim.g["test#custom_strategies"] = { custom_toggleterm = floa_vim_test_callback }
vim.g["test#strategy"] = "custom_toggleterm"
vim.g["test#go#go#options"] = "-v"
vim.g["test#go#gotest#options"] = "-v -count 1"
