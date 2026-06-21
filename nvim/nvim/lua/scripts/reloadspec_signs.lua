local M = {}

local uv = vim.uv or vim.loop
local NS = vim.api.nvim_create_namespace("reloadspec_signs")
local GROUP = vim.api.nvim_create_augroup("ReloadSpecSigns", { clear = true })

local config = {
	sign_text = "↻",
	sign_hl_group = "ReloadSpecRecorded",
	priority = 25,
}

local roots = {}

local PY_INDEX_SCRIPT = [[
import json
import os
import sys

sidecar = sys.argv[1]
root = sys.argv[2]

with open(sidecar, "r", encoding="utf-8") as f:
    data = json.load(f)

entries_by_file = {}
for entry in data.get("entries", []):
    path = entry.get("path")
    line = entry.get("line")
    if not path or not isinstance(line, int):
        continue

    full_path = path if os.path.isabs(path) else os.path.join(root, path)
    full_path = os.path.realpath(os.path.normpath(full_path))

    entries_by_file.setdefault(full_path, []).append({
        "line": line,
        "column": entry.get("column") or 1,
        "name": entry.get("name") or "",
        "reload": entry.get("reload") or "",
        "location": entry.get("location") or "",
        "matchTokens": entry.get("matchTokens") or [],
    })

print(json.dumps({
    "source": data.get("source") or "",
    "entriesByFile": entries_by_file,
}))
]]

local function notify(message, level)
	vim.notify("reloadspec_signs: " .. message, level or vim.log.levels.INFO)
end

local function set_highlights()
	vim.api.nvim_set_hl(0, config.sign_hl_group, {
		link = "DiagnosticSignHint",
		default = true,
	})
end

local function joinpath(...)
	if vim.fs and vim.fs.joinpath then
		return vim.fs.joinpath(...)
	end
	return table.concat({ ... }, "/")
end

local function readable(path)
	return path and vim.fn.filereadable(path) == 1
end

local function is_directory(path)
	return path and vim.fn.isdirectory(path) == 1
end

local function normalize_path(path)
	if not path or path == "" then
		return nil
	end
	local full = vim.fn.fnamemodify(path, ":p")
	return uv.fs_realpath(full) or full:gsub("/+$", "")
end

local function root_for_buffer(bufnr)
	bufnr = bufnr or 0
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return nil
	end

	local root = vim.fs.root(bufnr, { "reloadspec.yml", ".git" })
	if not root then
		return nil
	end

	local spec = joinpath(root, "reloadspec.yml")
	if not readable(spec) then
		return nil
	end

	return normalize_path(root)
end

local function sidecar_for_root(root)
	return joinpath(root, "build", "reloadspec_index.json")
end

local function state_for_root(root)
	roots[root] = roots[root] or {
		generation = 0,
		index = {},
		loaded = false,
		loading = false,
		watch = nil,
		watch_timer = nil,
	}
	return roots[root]
end

local function clear_buffer(bufnr)
	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
	end
end

local function apply_buffer(root, bufnr)
	bufnr = bufnr or 0
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	clear_buffer(bufnr)

	local state = roots[root]
	if not state or not state.loaded then
		return
	end

	local path = normalize_path(vim.api.nvim_buf_get_name(bufnr))
	if not path then
		return
	end

	local entries = state.index[path]
	if not entries or vim.tbl_isempty(entries) then
		return
	end

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local seen_lines = {}
	for _, entry in ipairs(entries) do
		local line = tonumber(entry.line)
		if line and line >= 1 and line <= line_count and not seen_lines[line] then
			seen_lines[line] = true
			vim.api.nvim_buf_set_extmark(bufnr, NS, line - 1, 0, {
				sign_text = config.sign_text,
				sign_hl_group = config.sign_hl_group,
				priority = config.priority,
			})
		end
	end
end

local function apply_loaded_buffers(root)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and root_for_buffer(bufnr) == root then
			apply_buffer(root, bufnr)
		end
	end
end

local function finalize_load(root, generation, decoded, notify_on_error)
	local state = state_for_root(root)
	if state.generation ~= generation then
		return
	end

	state.loading = false
	state.loaded = true
	state.index = decoded.entriesByFile or {}
	state.source = decoded.source or ""

	apply_loaded_buffers(root)

	if notify_on_error then
		local file_count = 0
		local mark_count = 0
		for _, entries in pairs(state.index) do
			file_count = file_count + 1
			mark_count = mark_count + #entries
		end
		notify(string.format("loaded %d mark(s) in %d file(s)", mark_count, file_count))
	end
end

local function decode_loaded_index(root, generation, stdout, notify_on_error)
	local ok, decoded = pcall(vim.json.decode, stdout or "")
	if not ok or type(decoded) ~= "table" then
		local state = state_for_root(root)
		if state.generation == generation then
			state.loading = false
		end
		if notify_on_error then
			notify("failed to decode async parser output", vim.log.levels.ERROR)
		end
		return
	end

	finalize_load(root, generation, decoded, notify_on_error)
end

local function load_index_async(root, opts)
	opts = opts or {}
	local state = state_for_root(root)
	local sidecar = sidecar_for_root(root)

	state.generation = state.generation + 1
	local generation = state.generation
	state.loading = true

	if not readable(sidecar) then
		state.loading = false
		state.loaded = true
		state.index = {}
		apply_loaded_buffers(root)
		if opts.notify then
			notify("missing " .. sidecar, vim.log.levels.WARN)
		end
		return
	end

	if vim.system and vim.fn.executable("python3") == 1 then
		vim.system({ "python3", "-c", PY_INDEX_SCRIPT, sidecar, root }, { text = true }, function(result)
			vim.schedule(function()
				if state_for_root(root).generation ~= generation then
					return
				end
				if result.code ~= 0 then
					state_for_root(root).loading = false
					if opts.notify then
						local stderr = vim.trim(result.stderr or "")
						notify(stderr ~= "" and stderr or "async parser failed", vim.log.levels.ERROR)
					end
					return
				end
				decode_loaded_index(root, generation, result.stdout, opts.notify)
			end)
		end)
		return
	end

	uv.fs_open(sidecar, "r", 438, function(open_err, fd)
		if open_err or not fd then
			vim.schedule(function()
				if state_for_root(root).generation == generation then
					state_for_root(root).loading = false
				end
				if opts.notify then
					notify(open_err or "failed to open sidecar", vim.log.levels.ERROR)
				end
			end)
			return
		end

		uv.fs_fstat(fd, function(stat_err, stat)
			if stat_err or not stat then
				uv.fs_close(fd)
				vim.schedule(function()
					if state_for_root(root).generation == generation then
						state_for_root(root).loading = false
					end
					if opts.notify then
						notify(stat_err or "failed to stat sidecar", vim.log.levels.ERROR)
					end
				end)
				return
			end

			uv.fs_read(fd, stat.size, 0, function(read_err, data)
				uv.fs_close(fd)
				vim.schedule(function()
					if state_for_root(root).generation ~= generation then
						return
					end
					if read_err then
						state_for_root(root).loading = false
						if opts.notify then
							notify(read_err, vim.log.levels.ERROR)
						end
						return
					end

					local ok, sidecar_data = pcall(vim.json.decode, data or "")
					if not ok or type(sidecar_data) ~= "table" then
						state_for_root(root).loading = false
						if opts.notify then
							notify("failed to decode " .. sidecar, vim.log.levels.ERROR)
						end
						return
					end

					local entries_by_file = {}
					for _, entry in ipairs(sidecar_data.entries or {}) do
						if entry.path and entry.line then
							local full = normalize_path(joinpath(root, entry.path))
							if full then
								entries_by_file[full] = entries_by_file[full] or {}
								table.insert(entries_by_file[full], entry)
							end
						end
					end

					finalize_load(root, generation, {
						source = sidecar_data.source or "",
						entriesByFile = entries_by_file,
					}, opts.notify)
				end)
			end)
		end)
	end)
end

local function start_watch(root)
	local state = state_for_root(root)
	if state.watch then
		return
	end

	local sidecar = sidecar_for_root(root)
	local build_dir = vim.fn.fnamemodify(sidecar, ":h")
	local watch_path = readable(sidecar) and sidecar or build_dir
	if not readable(sidecar) and not is_directory(build_dir) then
		return
	end

	state.watch = uv.new_fs_event()
	state.watch:start(watch_path, {}, function(err, filename)
		if err then
			return
		end
		if watch_path == build_dir and filename and filename ~= "reloadspec_index.json" then
			return
		end

		if state.watch_timer then
			state.watch_timer:stop()
			state.watch_timer:close()
		end

		state.watch_timer = uv.new_timer()
		state.watch_timer:start(120, 0, function()
			state.watch_timer:stop()
			state.watch_timer:close()
			state.watch_timer = nil
			vim.schedule(function()
				load_index_async(root)
			end)
		end)
	end)
end

function M.refresh(bufnr, opts)
	bufnr = bufnr or 0
	local root = root_for_buffer(bufnr)
	if not root then
		clear_buffer(bufnr)
		return
	end

	start_watch(root)

	local state = state_for_root(root)
	if state.loaded and not (opts and opts.force) then
		apply_buffer(root, bufnr)
		return
	end
	if state.loading and not (opts and opts.force) then
		return
	end

	load_index_async(root, opts)
end

function M.refresh_all(opts)
	local roots_seen = {}
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			local root = root_for_buffer(bufnr)
			if root and not roots_seen[root] then
				roots_seen[root] = true
				start_watch(root)
				load_index_async(root, opts)
			end
		end
	end
end

function M.clear()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		clear_buffer(bufnr)
	end
end

function M.show_line()
	local bufnr = 0
	local root = root_for_buffer(bufnr)
	if not root then
		notify("current buffer is not under a reloadspec project", vim.log.levels.WARN)
		return
	end

	local state = roots[root]
	if not state or not state.loaded then
		notify("index is not loaded yet", vim.log.levels.WARN)
		return
	end

	local path = normalize_path(vim.api.nvim_buf_get_name(bufnr))
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local entries = state.index[path] or {}
	local names = {}
	for _, entry in ipairs(entries) do
		if tonumber(entry.line) == line then
			table.insert(names, entry.name ~= "" and entry.name or table.concat(entry.matchTokens or {}, "::"))
		end
	end

	if vim.tbl_isempty(names) then
		notify("no recorded function on this line")
	else
		notify(table.concat(names, "\n"))
	end
end

function M.summary()
	local root = root_for_buffer(0)
	if not root then
		notify("current buffer is not under a reloadspec project", vim.log.levels.WARN)
		return
	end

	local state = roots[root]
	if not state or not state.loaded then
		notify("index is not loaded yet", vim.log.levels.WARN)
		return
	end

	local file_count = 0
	local mark_count = 0
	for _, entries in pairs(state.index) do
		file_count = file_count + 1
		mark_count = mark_count + #entries
	end
	notify(string.format("%d mark(s) in %d file(s)", mark_count, file_count))
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	set_highlights()

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = GROUP,
		callback = set_highlights,
	})

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
		group = GROUP,
		callback = function(args)
			M.refresh(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = GROUP,
		pattern = { "*/reloadspec.yml", "*/reloadspec_index.json" },
		callback = function(args)
			M.refresh(args.buf, { force = true })
			M.refresh_all()
		end,
	})

	vim.api.nvim_create_user_command("ReloadSpecSignsRefresh", function()
		M.refresh(0, { force = true, notify = true })
	end, {})

	vim.api.nvim_create_user_command("ReloadSpecSignsClear", function()
		M.clear()
	end, {})

	vim.api.nvim_create_user_command("ReloadSpecSignsLine", function()
		M.show_line()
	end, {})

	vim.api.nvim_create_user_command("ReloadSpecSignsSummary", function()
		M.summary()
	end, {})

	M.refresh_all()
end

M.setup()

return M
