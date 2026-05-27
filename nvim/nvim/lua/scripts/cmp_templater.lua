local M = {}

local COMMAND_NAME = "CmpTemplaterGenerate"

local function notify(msg, level)
	vim.notify("cmp_templater: " .. msg, level or vim.log.levels.INFO)
end

local function trim(text)
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function get_parser(bufnr)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "cpp")
	if not ok then
		return nil, "cpp Tree-sitter parser unavailable for current buffer"
	end

	return parser
end

local function node_text(node, bufnr)
	return vim.treesitter.get_node_text(node, bufnr)
end

local function find_child_of_type(node, wanted_type)
	for child in node:iter_children() do
		if child:type() == wanted_type then
			return child
		end
	end

	return nil
end

local function normalize_base_text(text)
	text = trim(text)

	local prior = nil
	while prior ~= text do
		prior = text
		text = text:gsub("^virtual%s+", "")
		text = text:gsub("^public%s+", "")
		text = text:gsub("^protected%s+", "")
		text = text:gsub("^private%s+", "")
		text = trim(text)
	end

	return text
end

local function extract_struct_name(class_text)
	return class_text:match("^%s*struct%s+([%w_]+)") or class_text:match("^%s*class%s+([%w_]+)")
end

local function extract_struct_header_name(text)
	return text:match("^%s*export%s+struct%s+([%w_]+)%s*:") or
		text:match("^%s*struct%s+([%w_]+)%s*:") or
		text:match("^%s*export%s+class%s+([%w_]+)%s*:") or
		text:match("^%s*class%s+([%w_]+)%s*:")
end

local function qualify_base(base_text, struct_name)
	local prefix, suffix = base_text:match("^(.-::api<)%s*[%w_:]+%s*(>)$")
	if not prefix then
		return nil
	end

	return prefix .. "entity::" .. struct_name .. suffix
end

local function extract_cmp_api_bases(base_clause, bufnr, struct_name)
	local bases = {}
	local seen = {}

	for i = 0, base_clause:named_child_count() - 1 do
		local child = base_clause:named_child(i)
		local base_text = normalize_base_text(node_text(child, bufnr))
		local template_arg = base_text:match("::api<%s*([%w_:]+)%s*>$")

		if base_text:match("^cmp::.+::api<") and template_arg then
			local local_name = template_arg:gsub("^::", ""):gsub("^entity::", "")
			if local_name == struct_name and not seen[base_text] then
				seen[base_text] = true
				bases[#bases + 1] = base_text
			end
		end
	end

	return bases
end

local function extract_cmp_api_bases_from_text(text, struct_name)
	local bases = {}
	local seen = {}
	local header = text:match("^(.-){") or text

	for base_text, template_arg in header:gmatch("(cmp::[%w_:]+::api<%s*([%w_:]+)%s*>)") do
		local local_name = template_arg:gsub("^::", ""):gsub("^entity::", "")
		if local_name == struct_name and not seen[base_text] then
			seen[base_text] = true
			bases[#bases + 1] = normalize_base_text(base_text)
		end
	end

	return bases
end

local function collect_struct_candidates(node, bufnr, out)
	if node:type() == "class_specifier" then
		local class_text = node_text(node, bufnr)
		local struct_name = extract_struct_name(class_text)
		local base_clause = find_child_of_type(node, "base_class_clause")

		if struct_name and base_clause then
			local bases = extract_cmp_api_bases(base_clause, bufnr, struct_name)
			if #bases > 0 then
				local start_row, _, end_row, _ = node:range()
				out[#out + 1] = {
					bases = bases,
					end_row = end_row,
					name = struct_name,
					node = node,
					start_row = start_row,
				}
			end
		end
	end

	if node:type() == "declaration" then
		local decl_text = node_text(node, bufnr)
		local struct_name = extract_struct_header_name(decl_text)
		if struct_name then
			local bases = extract_cmp_api_bases_from_text(decl_text, struct_name)
			if #bases > 0 then
				local start_row, _, end_row, _ = node:range()
				out[#out + 1] = {
					bases = bases,
					end_row = end_row,
					name = struct_name,
					node = node,
					start_row = start_row,
				}
			end
		end
	end

	for child in node:iter_children() do
		collect_struct_candidates(child, bufnr, out)
	end
end

local function choose_candidate(candidates, cursor_row)
	local enclosing = nil
	for _, candidate in ipairs(candidates) do
		if candidate.start_row <= cursor_row and cursor_row <= candidate.end_row then
			enclosing = candidate
		end
	end

	if enclosing then
		return enclosing
	end

	local nearest = nil
	for _, candidate in ipairs(candidates) do
		if candidate.start_row <= cursor_row then
			nearest = candidate
		end
	end

	return nearest or candidates[1]
end

local function get_target_struct(bufnr)
	local parser, err = get_parser(bufnr)
	if not parser then
		return nil, err
	end

	local tree = parser:parse()[1]
	if not tree then
		return nil, "failed to parse current buffer"
	end

	local root = tree:root()
	local candidates = {}
	collect_struct_candidates(root, bufnr, candidates)

	if #candidates == 0 then
		return nil, "no struct with cmp::...::api<T> bases found"
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	return choose_candidate(candidates, cursor[1] - 1)
end

local function render_lines(candidate)
	local externs = {}
	local templates = {}

	for _, base in ipairs(candidate.bases) do
		local qualified = qualify_base(base, candidate.name)
		if qualified then
			externs[#externs + 1] = "extern template struct " .. qualified .. ";"
			templates[#templates + 1] = "template struct " .. qualified .. ";"
		end
	end

	local lines = {}
	vim.list_extend(lines, externs)
	if #externs > 0 and #templates > 0 then
		lines[#lines + 1] = ""
	end
	vim.list_extend(lines, templates)

	return lines
end

local function existing_line_set(bufnr)
	local seen = {}
	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
		seen[line] = true
	end
	return seen
end

local function filter_missing(lines, existing)
	local missing = {}
	for _, line in ipairs(lines) do
		if line == "" or not existing[line] then
			missing[#missing + 1] = line
			if line ~= "" then
				existing[line] = true
			end
		end
	end
	return missing
end

function M.generate_for_current_struct(opts)
	opts = opts or {}

	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	local candidate, err = get_target_struct(bufnr)
	if not candidate then
		notify(err, vim.log.levels.ERROR)
		return nil, err
	end

	local rendered = render_lines(candidate)
	local missing = filter_missing(rendered, existing_line_set(bufnr))

	local has_content = false
	for _, line in ipairs(missing) do
		if line ~= "" then
			has_content = true
			break
		end
	end

	if not has_content then
		notify("no new template instantiations to append")
		return ""
	end

	local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local to_append = {}
	if #current_lines > 0 and current_lines[#current_lines] ~= "" then
		to_append[#to_append + 1] = ""
	end
	vim.list_extend(to_append, missing)

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, to_append)

	notify(string.format("appended template boilerplate for %s", candidate.name))
	return table.concat(missing, "\n")
end

vim.api.nvim_create_user_command(COMMAND_NAME, function()
	M.generate_for_current_struct()
end, {
	desc = "Append cmp api template boilerplate for the current C++ entity struct",
	nargs = 0,
})

return M
