local function calculate_hash(filepath)
	local handle = io.popen("shasum -a 256 '" .. filepath .. "'")
	if not handle then
		return nil, "Cannot execute shasum command"
	end

	local result = handle:read("*a")
	handle:close()

	if result then
		local hash = result:match("^(%w+)")
		return hash
	end
	return nil, "Failed to get hash"
end

local function is_cpp_file(filepath)
	return filepath:match("%.cpp$")
		or filepath:match("%.h$")
		or filepath:match("%.hpp$")
		or filepath:match("%.cc$")
		or filepath:match("%.cxx$")
end

local function get_class_from_lsp(filepath, line_number, column)
	-- This function uses Neovim's LSP to get the class type of a variable
	-- Returns the class name if the variable is a class instance, nil otherwise

	-- First, we need to open the file in a buffer to use LSP
	local bufnr = vim.fn.bufadd(filepath)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		vim.fn.bufload(bufnr)
	end

	local current_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_set_current_buf(bufnr)

	-- Position in LSP is 0-indexed
	local lsp_line = line_number - 1
	local lsp_col = column - 1

	-- Request hover information from LSP
	local params = {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
		position = { line = lsp_line, character = lsp_col },
	}

	local result = nil
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	for _, client in pairs(clients) do
		if client.supports_method("textDocument/hover") then
			local response = client.request_sync("textDocument/hover", params, 1000)
			if response and response.result and response.result.contents then
				local contents = response.result.contents
				local hover_text = ""

				if type(contents) == "string" then
					hover_text = contents
				elseif contents.value then
					hover_text = contents.value
				elseif contents[1] and contents[1].value then
					hover_text = contents[1].value
				end

				-- Extract class name from hover information
				-- Look for patterns like "variable_name: ClassName" or "ClassName variable_name"
				local class_name = hover_text:match(":%s*([%w_:]+)")
					or hover_text:match("^([%w_:]+)%s+[%w_]+")
					or hover_text:match("class%s+([%w_:]+)")

				if class_name then
					-- Remove namespace prefixes if present, keep only the class name
					class_name = class_name:match("([%w_]+)$") or class_name
					result = class_name
					break
				end
			end
		end
	end

	-- Restore original buffer
	vim.api.nvim_set_current_buf(current_buf)

	return result
end

local function find_enclosing_class(content, dispatch_line)
	local lines = {}
	local line_num = 1

	-- Split content into lines array for easier access
	for line in content:gmatch("[^\r\n]+") do
		lines[line_num] = line
		line_num = line_num + 1
	end

	local class_stack = {}

	for i = dispatch_line, 1, -1 do
		local line = lines[i]
		if not line then
			break
		end

		-- Case: Method implementation (Class::method, Class::~Class, etc)
		-- Handle various method definition patterns:
		-- void Class::method(
		-- auto Class::method( -> returntype
		-- returntype namespace::Class::method(
		local class_from_method =
			-- Pattern 1: namespace::Class::method
			line:match("^%s*[%w_<>:*&%s]*%s+[%w_]+::([%w_]+)::[%w_~<>]+%s*%(")
			-- Pattern 2: Class::method (no namespace)
			or line:match("^%s*[%w_<>:*&%s]*%s+([%w_]+)::[%w_~<>]+%s*%(")
			-- Pattern 3: auto Class::method (trailing return type)
			or line:match("^%s*auto%s+[%w_]+::([%w_]+)::[%w_~<>]+%s*%(")
			or line:match("^%s*auto%s+([%w_]+)::[%w_~<>]+%s*%(")
			-- Pattern 4: Direct Class::method at start
			or line:match("^%s*([%w_]+)::[%w_~<>]+%s*%(")

		if class_from_method then
			-- Make sure it's not a function call, declaration, or assignment
			-- Method definitions should NOT end with semicolon
			if
				not line:match(";%s*$") -- not ending with semicolon
				and not line:match("^%s*auto%s+[%w_]+%s*=") -- not a variable assignment
				and not line:match("^%s*[%w_]+%s*=")
			then -- not a simple assignment
				return class_from_method
			end
		end

		-- Case: Class definition
		local class_name = line:match("^%s*class%s+([%w_]+)")
		if class_name then
			table.insert(class_stack, 1, class_name)
			return table.concat(class_stack, "::")
		end

		-- Case: Struct definition (treat like class)
		local struct_name = line:match("^%s*struct%s+([%w_]+)")
		if struct_name then
			table.insert(class_stack, 1, struct_name)
			return table.concat(class_stack, "::")
		end

		-- Track scope with braces (for nested classes)
		local close_braces = select(2, line:gsub("}", ""))
		for j = 1, close_braces do
			if #class_stack > 0 then
				table.remove(class_stack, 1)
			end
		end
	end

	-- If we found classes in the stack, return the innermost one
	if #class_stack > 0 then
		return table.concat(class_stack, "::")
	end

	return "global"
end

local function parse_dispatcher_calls(filepath)
	if not is_cpp_file(filepath) then
		return {}
	end

	local file = io.open(filepath, "r")
	if not file then
		return {}
	end

	local content = file:read("*all")
	file:close()

	local dispatcher_calls = {}
	local line_number = 1

	for line in content:gmatch("[^\r\n]+") do
		-- Match sceneDispatcher.enqueue<Type> or gameDispatcher.enqueue<Type>
		local type_match = line:match("(sceneDispatcher%.enqueue%s*<%s*[^>]+%s*>)") or line:match("(gameDispatcher%.enqueue%s*<%s*[^>]+%s*>)")
		if type_match then
			local class_name = find_enclosing_class(content, line_number)
			table.insert(dispatcher_calls, {
				type = type_match:match("<%s*([^>]+)%s*>"):gsub("%s+", ""), -- Remove extra whitespace
				column = line:find("dispatcher%.enqueue") or 1,
				class = class_name,
			})
		end
		line_number = line_number + 1
	end

	return dispatcher_calls
end

local function parse_hash_file(hash_file)
	local existing_hashes = {}
	local file = io.open(hash_file, "r")
	if not file then
		return existing_hashes -- Return empty table if file doesn't exist
	end

	local content = file:read("*all")
	file:close()

	if content and content:match("%S") then
		local success, data = pcall(vim.json.decode, content)
		if success and data and data.files then
			-- Handle both old format (string hash) and new format (object with hash field)
			for filepath, file_info in pairs(data.files) do
				if type(file_info) == "string" then
					-- Old format: convert to new format
					existing_hashes[filepath] = {
						hash = file_info,
						last_modified = "unknown",
						dispatcher_calls = {},
					}
				else
					-- New format: ensure dispatcher_calls field exists
					existing_hashes[filepath] = file_info
					if not existing_hashes[filepath].dispatcher_calls then
						existing_hashes[filepath].dispatcher_calls = {}
					end
				end
			end
		end
	end

	return existing_hashes
end

local function scan_directory(dir_path, hash_data)
	local handle = io.popen("find '" .. dir_path .. "' -type f")
	if not handle then
		error("Cannot execute find command")
	end

	for filepath in handle:lines() do
		local hash, err = calculate_hash(filepath)
		if hash then
			local dispatcher_calls = parse_dispatcher_calls(filepath)
			hash_data[filepath] = {
				hash = hash,
				last_modified = os.date("%Y-%m-%d %H:%M:%S"),
				dispatcher_calls = dispatcher_calls,
			}
		else
			print("Error hashing " .. filepath .. ": " .. (err or "unknown error"))
		end
	end

	handle:close()
end

local function compare_and_update_hashes(current_hashes, existing_hashes)
	local changes_found = false

	for filepath, current_file_info in pairs(current_hashes) do
		local existing_file_info = existing_hashes[filepath]
		if existing_file_info and existing_file_info.hash ~= current_file_info.hash then
			print("File changed: " .. filepath)
			changes_found = true
		elseif not existing_file_info then
			print("New file: " .. filepath)
			changes_found = true
		end
	end

	-- Check for deleted files
	for filepath, _ in pairs(existing_hashes) do
		if not current_hashes[filepath] then
			print("File deleted: " .. filepath)
			changes_found = true
		end
	end

	return changes_found
end

local function build_class_dispatcher_map(hash_data)
	local class_map = {}

	for filepath, file_info in pairs(hash_data) do
		if file_info.dispatcher_calls then
			for _, call in ipairs(file_info.dispatcher_calls) do
				local class_name = call.class
				if class_name and class_name ~= "global" then
					if not class_map[class_name] then
						class_map[class_name] = {}
					end

					-- Add call info with file context
					table.insert(class_map[class_name], {
						type = call.type,
						file = filepath,
						line = call.line,
						column = call.column,
					})
				end
			end
		end
	end

	return class_map
end

local function write_hash_file(hash_data, output_file)
	local file = io.open(output_file, "w")
	if not file then
		error("Cannot create output file: " .. output_file)
	end

	local class_dispatcher_map = build_class_dispatcher_map(hash_data)

	local data = {
		_metadata = {
			generated = os.date("%Y-%m-%d %H:%M:%S"),
			format = "file_hash_registry",
		},
		files = hash_data,
		class_dispatcher_map = class_dispatcher_map,
	}

	local json_content = vim.json.encode(data)
	file:write(json_content)
	file:close()
end

local function main()
	local src_dir = "src"
	local output_file = "file_hashes.json"

	-- Check if source directory exists
	local handle = io.popen("test -d '" .. src_dir .. "' && echo 'exists'")
	local dir_check = handle:read("*a"):gsub("%s+", "")
	handle:close()

	if dir_check ~= "exists" then
		error("Source directory '" .. src_dir .. "' does not exist")
	end

	print("Parsing existing hash file...")
	local existing_hashes = parse_hash_file(output_file)

	print("Scanning files in " .. src_dir .. " directory...")
	local current_hashes = {}
	scan_directory(src_dir, current_hashes)

	local file_count = 0
	for _ in pairs(current_hashes) do
		file_count = file_count + 1
	end

	print("Found " .. file_count .. " files")

	print("Comparing with existing hashes...")
	local changes_found = compare_and_update_hashes(current_hashes, existing_hashes)

	if changes_found then
		print("Changes detected - updating hash file...")
	else
		print("No changes detected")
	end

	print("Writing hash data to " .. output_file .. "...")
	write_hash_file(current_hashes, output_file)
	print("Hash data saved to " .. output_file)
end

-- Export the LSP function for external use
if not _G.hash_files_utils then
	_G.hash_files_utils = {}
end

local function get_dispatcher_calls_for_class(class_name, hash_file_path)
	-- This function reads the hash file and shows all dispatcher calls for a given class in a Telescope window

	hash_file_path = hash_file_path or "file_hashes.json"
	print("Looking for class: " .. class_name .. " in file: " .. hash_file_path)

	local file = io.open(hash_file_path, "r")
	if not file then
		print("Hash file not found: " .. hash_file_path)
		return
	end

	local content = file:read("*all")
	file:close()

	if not content or not content:match("%S") then
		print("Hash file is empty")
		return
	end

	local success, data = pcall(vim.json.decode, content)
	if not success then
		print("Failed to parse JSON: " .. (data or "unknown error"))
		return
	end

	if not data.class_dispatcher_map then
		print("No class_dispatcher_map found in hash file")
		return
	end

	local calls = data.class_dispatcher_map[class_name]
	if not calls or #calls == 0 then
		print("No dispatcher calls found for class: " .. class_name)
		return
	end

	-- Create telescope picker for the calls
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local entries = {}
	for _, call in ipairs(calls) do
		table.insert(entries, {
			display = string.format("%s:%d - %s", vim.fn.fnamemodify(call.file, ":t"), call.line, call.type),
			filename = call.file,
			lnum = call.line,
			col = call.column,
			text = call.type,
		})
	end

	-- print("Created " .. #entries .. " entries for telescope")
	-- print(vim.print(entries))

	pickers
		.new({}, {
			prompt_title = "Dispatcher Calls for " .. class_name,
			finder = finders.new_table({
				results = entries,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.display,
						filename = entry.filename,
						lnum = entry.lnum,
						col = entry.col,
						ordinal = entry.display,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.grep_previewer({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					vim.cmd("edit " .. selection.filename)
					vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
				end)
				return true
			end,
		})
		:find()
end

-- Module exports
local M = {}

M.get_class_from_lsp = get_class_from_lsp
M.get_dispatcher_calls_for_class = get_dispatcher_calls_for_class
M.main = main

return M
