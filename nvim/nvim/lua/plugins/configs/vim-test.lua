tterm = require("toggleterm")

local floa_vim_test_callback = function(opts)
	if opts:find("go test") then
		tterm.exec(opts, 2, nil, nil, "float", "test_term", false, true)
	else
		local current_file = vim.fn.expand("%:p")
		local file_content = vim.fn.readfile(current_file)

		local has_gtest = false
		local has_bench = false
		local has_ut = false

		for _, line in ipairs(file_content) do
			if line:match('#include%s*[<"]gtest/gtest%.h[>"]') then
				has_gtest = true
				break
			elseif line:match('import boost.ut') then
				has_ut = true
				break
			elseif line:match('#include%s*[<"]benchmark/benchmark%.h[>"]') then
				has_bench = true
				break
			end
		end

		if has_ut then
			local file_dir = vim.fn.expand("%:p:h")
			local file_name = vim.fn.expand("%:t:r")
			local rel_path = file_dir:match("tests/(.*)")
			local target_name = rel_path and (rel_path:gsub("/", "_") .. "_" .. file_name) or file_name
			local cmd = "cmake --build out/Debug --target run_tests_target_" .. target_name
			tterm.exec(cmd, 2, nil, nil, "float", "test_term", false, true)
		elseif has_gtest then
			local file_dir = vim.fn.expand("%:p:h")
			local rel_path = file_dir:match("test/(.*)")
			local file_dir_name = rel_path and rel_path:gsub("/", "_") or ""
			local cmd = "(cd ./out/Debug && ninja run_tests_target_" .. file_dir_name .. " -j 8)"
			tterm.exec(cmd, 2, nil, nil, "float", "test_term", false, true)
		elseif has_bench then
			local file_dir = vim.fn.expand("%:p:h")
			local file_dir_name = vim.fn.fnamemodify(file_dir, ":t")
			-- local cmd = "(cd ./out/Debug && make run_benchmarks_target_" .. file_dir_name .. " -j 8)"
			print("Running benchmarks for " .. file_dir_name)
			local cmd = "(cd ./out/Debug && ninja run_benchmark_" .. file_dir_name .. " -j 8)"
			-- local cmd = "(cd ./out/Debug && make run_benchmark_entt -j 8)"
			tterm.exec(cmd, 2, nil, nil, "float", "test_term", false, true)
		else
			tterm.exec(opts, 2, nil, nil, "float", "test_term", false, true)
		end
	end
end

vim.g["test#custom_strategies"] = { custom_toggleterm = floa_vim_test_callback }
vim.g["test#strategy"] = "custom_toggleterm"
vim.g["test#go#go#options"] = "-v"
vim.g["test#go#gotest#options"] = "-v -count 1"
