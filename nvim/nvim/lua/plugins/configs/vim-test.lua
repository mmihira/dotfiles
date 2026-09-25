tterm = require("toggleterm")

local floa_vim_test_callback = function(opts)
	if opts:find("go test") then
		tterm.exec(opts, 2, nil, nil, "float", "test_term", false, true)
	else
		local current_file = vim.fn.expand("%:p")
		local file_content = vim.fn.readfile(current_file)
		local is_bench_file = current_file:match("[/\\]benchmarks[/\\]") ~= nil

		local has_gtest = false
		local has_bench = is_bench_file
		local has_ut = false

		for _, line in ipairs(file_content) do
			local has_nanobench_include = line:match('#include%s*[<"]nanobench%.h[>"]')
				or line:match('#include%s*[<"]nanobench/nanobench%.h[>"]')

			if line:match('#include%s*[<"]gtest/gtest%.h[>"]') then
				has_gtest = true
				break
			elseif line:match('import boost.ut') then
				has_ut = true
				break
			elseif has_nanobench_include then
				has_bench = true
				break
			end
		end

		if has_bench then
			local file_dir = vim.fn.expand("%:p:h")
			local file_name = vim.fn.expand("%:t:r")
			local rel_path = file_dir:match("benchmarks/(.*)")
			local target_name = rel_path and (rel_path:gsub("/", "_") .. "_" .. file_name) or file_name
			local cmd = "xmake run bench_" .. target_name
			tterm.exec(cmd, 2, nil, nil, "float", "test_term", false, true)
		elseif has_ut then
			local file_dir = vim.fn.expand("%:p:h")
			local file_name = vim.fn.expand("%:t:r")
			local rel_path = file_dir:match("tests/(.*)")
			local target_name = rel_path and (rel_path:gsub("/", "_") .. "_" .. file_name) or file_name
			local cmd = "xmake run test_" .. target_name
			tterm.exec(cmd, 2, nil, nil, "float", "test_term", false, true)
		elseif has_gtest then
			local file_dir = vim.fn.expand("%:p:h")
			local rel_path = file_dir:match("test/(.*)")
			local file_dir_name = rel_path and rel_path:gsub("/", "_") or ""
			local cmd = "(cd ./out/Debug && ninja run_tests_target_" .. file_dir_name .. " -j 8)"
			tterm.exec(cmd, 2, nil, nil, "float", "test_term", false, true)
		else
			tterm.exec(opts, 2, nil, nil, "float", "test_term", false, true)
		end
	end
end

vim.g["test#custom_strategies"] = { custom_toggleterm = floa_vim_test_callback }
vim.g["test#strategy"] = "custom_toggleterm"
vim.g["test#cpp#catch2#file_pattern"] = [[\v(^|.*/)(test|tests|benchmarks)/.*\.cpp$|[tT]est.*\.cpp$]]
vim.g["test#go#go#options"] = "-v"
vim.g["test#go#gotest#options"] = "-v -count 1"
