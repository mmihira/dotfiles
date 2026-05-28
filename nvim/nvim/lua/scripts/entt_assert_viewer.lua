-- entt_assert_viewer.lua — render the most recent ENTT_ASSERT block from a log
-- file in a single nui popup with every frame inlined.
--
-- Companion to src/wrappers/entt_assert_override.h in projects that override
-- ENTT_ASSERT to print a cpptrace dump on failure. Parses the cpptrace dump
-- bottom-up so re-runs that pile multiple aborts into one log file resolve to
-- the latest crash by default.
--
-- Usage:
--   :EnttAssertView [path]   open the most recent assert (default: ./logs)
--   :EnttAssertList [path]   pick among all assert blocks in the file
--   :EnttAssertClose         tear down the viewer

local Menu = require("nui.menu")

local M = {}

local NS = vim.api.nvim_create_namespace("entt_assert_viewer")
local NS_BOX = vim.api.nvim_create_namespace("entt_assert_viewer_active_box")

local state = {
	tabpage = nil,
	winid = nil,
	bufnr = nil,
	blocks = nil,
	block_idx = nil,
	visible_frames = nil,
	targets = nil,
	at_rows = nil,
	boxes = nil,
	cursor_au = nil,
	user_only = false,
	prev_win = nil,
	prev_tab = nil,
	source_path = nil,
}

-- Solid-bar bg highlights so section headers and the focus snippet line
-- read as distinct rows regardless of fg saturation. Re-applied on
-- ColorScheme so a `:colorscheme …` swap doesn't blank them.
local function set_highlights()
	vim.api.nvim_set_hl(0, "EnttAssertCursorLine", { bg = "#44475a" })
	vim.api.nvim_set_hl(0, "EnttAssertBanner", { bg = "#2f3343", fg = "#fd8095", bold = true })
	vim.api.nvim_set_hl(0, "EnttAssertUserFrame", { bg = "#353a51", fg = "#97dc8d", bold = true })
	vim.api.nvim_set_hl(0, "EnttAssertExtFrame", { bg = "#1d2a3a", fg = "#8fbfff" })
	vim.api.nvim_set_hl(0, "EnttAssertFocusLine", { bg = "#393342", fg = "#ffa577", bold = true })
	vim.api.nvim_set_hl(0, "EnttAssertSepRule", { fg = "#6c7086" })
	vim.api.nvim_set_hl(0, "EnttAssertBoxBorder", { fg = "#5a637a" })
	vim.api.nvim_set_hl(0, "EnttAssertBoxBorderActive", { fg = "#ffa577", bold = true })
	vim.api.nvim_set_hl(0, "Comment", { fg = "#eff5fc" })
end
set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })

----------------------------------------------------------------------
-- File discovery
----------------------------------------------------------------------

local function find_logs()
	local found = vim.fs.find("logs", {
		upward = true,
		path = vim.fn.getcwd(),
		stop = vim.uv.os_homedir(),
	})
	return found[1]
end

local function read_lines(filepath)
	local f = io.open(filepath, "r")
	if not f then
		return nil, ("cannot open: " .. filepath)
	end
	local lines = {}
	for line in f:lines() do
		lines[#lines + 1] = line
	end
	f:close()
	return lines
end

----------------------------------------------------------------------
-- Parser
----------------------------------------------------------------------

local ASSERT_HEADER = "^ENTT_ASSERT failed: (.*)$"
local ASSERT_CONDITION = "^  condition: (.*)$"
local ASSERT_SOURCE = "^  (/.+):(%d+)$"
local FRAME_HEADER = "^#(%d+)%s+in%s+(.*)$"
local FRAME_AT_WITH_COL = "^%s*at%s+(.-):(%d+):(%d+)%s*$"
local FRAME_AT_WITH_LINE = "^%s*at%s+(.-):(%d+)%s*$"
local FRAME_AT_PLAIN = "^%s*at%s+(.+)%s*$"
local SNIPPET_LINE = "^(%s*[>%s])%s*(%d+):%s?(.*)$"
local CARET_LINE = "^%s*%^%s*$"
local FATAL_SIGNAL = "^=== FATAL SIGNAL"
local END_DELIMITER = "^=== ENTT_ASSERT END ==="
local LOG_TIMESTAMP = "^%[%d%d%d%d%-"

-- A block ends at any of these so the parser is robust to the missing
-- end-delimiter that older builds produce.
local function is_block_end(line)
	return line:match(ASSERT_HEADER)
		or line:match(FATAL_SIGNAL)
		or line:match(END_DELIMITER)
		or line:match(LOG_TIMESTAMP)
end

local function parse_block(lines, start_lnum)
	local header = { message = lines[start_lnum]:match(ASSERT_HEADER) or "" }
	local i = start_lnum + 1

	if lines[i] then
		header.condition = lines[i]:match(ASSERT_CONDITION) or ""
		i = i + 1
	end
	if lines[i] then
		local src, srcline = lines[i]:match(ASSERT_SOURCE)
		header.source_file = src or lines[i]:gsub("^%s+", "")
		header.source_line = tonumber(srcline)
		i = i + 1
	end

	-- Skip the "EnTT assert stack trace..." banner line if present.
	if lines[i] and lines[i]:match("^EnTT assert stack trace") then
		i = i + 1
	end

	local frames = {}
	local current = nil

	while lines[i] do
		local line = lines[i]
		if is_block_end(line) and i > start_lnum + 1 then
			break
		end

		local n, symbol = line:match(FRAME_HEADER)
		if n then
			if current then
				frames[#frames + 1] = current
			end
			current = {
				n = tonumber(n),
				symbol = symbol,
				file = nil,
				line = nil,
				col = nil,
				snippet = {},
				focus_idx = nil,
			}
		elseif current and not current.file then
			local f, ln, col = line:match(FRAME_AT_WITH_COL)
			if f then
				current.file, current.line, current.col = f, tonumber(ln), tonumber(col)
			else
				local f2, ln2 = line:match(FRAME_AT_WITH_LINE)
				if f2 then
					current.file, current.line = f2, tonumber(ln2)
				else
					local f3 = line:match(FRAME_AT_PLAIN)
					if f3 then
						current.file = f3
					end
				end
			end
		elseif current then
			local prefix, snline, snrest = line:match(SNIPPET_LINE)
			if prefix then
				local entry = {
					lnum = tonumber(snline),
					text = snrest or "",
					focus = prefix:find(">") ~= nil,
				}
				current.snippet[#current.snippet + 1] = entry
				if entry.focus then
					current.focus_idx = #current.snippet
				end
			elseif line:match(CARET_LINE) then
				-- Carets re-anchor the focus marker for the previously-listed
				-- snippet line; keep them so the rendering matches cpptrace.
				current.snippet[#current.snippet + 1] = { caret = true, text = line }
			end
		end
		i = i + 1
	end

	if current then
		frames[#frames + 1] = current
	end
	return {
		start_lnum = start_lnum,
		header = header,
		frames = frames,
		end_lnum = i - 1,
	}
end

local function find_assert_blocks(lines)
	local starts = {}
	for i = #lines, 1, -1 do
		if lines[i]:match(ASSERT_HEADER) then
			starts[#starts + 1] = i
		end
	end
	local blocks = {}
	for _, s in ipairs(starts) do
		blocks[#blocks + 1] = parse_block(lines, s)
	end
	return blocks
end

----------------------------------------------------------------------
-- Symbol cleanup (display-only)
----------------------------------------------------------------------

local function collapse_templates(s, max_inner)
	max_inner = max_inner or 40
	local depth, out, buf = 0, {}, {}
	for ch in s:gmatch(".") do
		if ch == "<" then
			depth = depth + 1
			if depth == 1 then
				out[#out + 1] = "<"
				buf = {}
			else
				buf[#buf + 1] = ch
			end
		elseif ch == ">" then
			if depth == 1 then
				local inner = table.concat(buf)
				if #inner > max_inner then
					inner = "…"
				end
				out[#out + 1] = inner
				out[#out + 1] = ">"
				buf = {}
			else
				buf[#buf + 1] = ch
			end
			depth = depth - 1
		else
			if depth == 0 then
				out[#out + 1] = ch
			else
				buf[#buf + 1] = ch
			end
		end
	end
	return table.concat(out)
end

local function short_symbol(sym)
	if not sym or sym == "" then
		return ""
	end
	local s = sym
	s = s:gsub("@[%w_]+", "")
	s = s:gsub("std::__1::", "std::")
	s = s:gsub("%[abi:[%w_]+%]", "")
	s = s:gsub("'lambda'%b()", "λ")
	s = collapse_templates(s, 40)
	if #s > 90 then
		s = s:sub(1, 87) .. "..."
	end
	return s
end

----------------------------------------------------------------------
-- Project-path helpers
----------------------------------------------------------------------

local function project_root()
	local found = vim.fs.find({ ".git", "xmake.lua" }, {
		upward = true,
		path = vim.fn.getcwd(),
		stop = vim.uv.os_homedir(),
	})
	if found[1] then
		return vim.fs.dirname(found[1])
	end
	return vim.fn.getcwd()
end

local function is_user_frame(frame)
	if not frame.file then
		return false
	end
	if frame.file:find("/", 1, true) then
		return frame.file:find(project_root(), 1, true) ~= nil
	end
	-- Bare basename: cpptrace already stripped the path. Treat anything
	-- without an obvious entt/std prefix as user code.
	local sym = frame.symbol or ""
	if sym:match("^entt::") or sym:match("^std::") then
		return false
	end
	return true
end

local resolve_cache = {}

local function glob_first(root, basename)
	if vim.fn.isdirectory(root) ~= 1 then
		return nil
	end
	local matches = vim.fn.globpath(root, "**/" .. basename, false, true)
	return matches[1]
end

-- Resolve a frame's file (often just a basename like `entity.cppm`) to a real
-- path. Caches results since cpptrace emits the same basenames many times in
-- one trace.
local function resolve_path(file)
	if not file then
		return nil
	end
	if file:sub(1, 1) == "/" then
		return file
	end
	if resolve_cache[file] then
		return resolve_cache[file]
	end

	local root = project_root()
	local quick = {
		root .. "/src/" .. file,
		root .. "/" .. file,
	}
	for _, c in ipairs(quick) do
		if vim.fn.filereadable(c) == 1 then
			resolve_cache[file] = c
			return c
		end
	end

	-- Walk the project tree (src/ first since most user frames live there),
	-- then fall back to xmake's package cache for entt/std headers.
	local found = glob_first(root .. "/src", file)
		or glob_first(root, file)
		or glob_first(vim.fn.expand("~/.xmake/packages"), file)
	if found then
		resolve_cache[file] = found
		return found
	end
	return file
end

----------------------------------------------------------------------
-- Rendering
----------------------------------------------------------------------

local function build_visible_frames(block, user_only)
	if not user_only then
		return block.frames
	end
	local out = {}
	for _, f in ipairs(block.frames) do
		if is_user_frame(f) then
			out[#out + 1] = f
		end
	end
	if #out == 0 then
		return block.frames
	end
	return out
end

local SEP_RULE = string.rep("─", 300) -- long enough to span any window width

local function render_all(block, visible_frames)
	local lines = {}
	local hl = {} -- list of { row (0-indexed), line_hl_group }
	local targets = {} -- row → { file, line, col }
	local at_rows = {} -- 1-indexed rows of "  at <file>:<line>" entries, in order
	local boxes = {} -- list of { at_row, top, bot, side_rows, left_col, right_col }

	local function add(line, group, target)
		lines[#lines + 1] = line
		if group then
			hl[#hl + 1] = { line_hl_group = group, row = #lines - 1 }
		end
		if target then
			targets[#lines] = target
		end
	end

	-- Banner: every row on a dark red bg so the assert info reads as one block.
	local header_target = block.header.source_file
			and {
				file = block.header.source_file,
				line = block.header.source_line,
			}
		or nil
	add(" ENTT_ASSERT  " .. (block.header.message or ""), "EnttAssertBanner", header_target)
	if block.header.condition and block.header.condition ~= "" then
		add("   condition: " .. block.header.condition, "EnttAssertBanner", header_target)
	end
	if block.header.source_file then
		add(
			string.format("   %s:%d", block.header.source_file, block.header.source_line or 0),
			"EnttAssertBanner",
			header_target
		)
	end
	add("")

	for _, f in ipairs(visible_frames) do
		local user = is_user_frame(f)
		local marker = user and "●" or "·"
		local title = string.format(" %s #%d  %s", marker, f.n, short_symbol(f.symbol))
		local frame_target = f.file and { file = f.file, line = f.line, col = f.col } or nil

		-- Section header as a solid colored bar (bg via line_hl_group fills past EOL).
		add(title, user and "EnttAssertUserFrame" or "EnttAssertExtFrame", frame_target)
		if user then
			add(SEP_RULE, "EnttAssertSepRule", frame_target)
		end

		local frame_at_row = nil
		if f.file then
			local loc = f.file
			if f.line then
				loc = loc .. ":" .. f.line
			end
			if f.col then
				loc = loc .. ":" .. f.col
			end
			add("    at " .. loc, "Comment", frame_target)
			at_rows[#at_rows + 1] = #lines
			frame_at_row = #lines
		end

		if #f.snippet > 0 then
			-- Snippet rows use indent "    │ " (6 cols), caret rows use "    │" (5 cols)
			-- — the 1-col difference preserves the original alignment between source
			-- text and cpptrace's caret. Pad each row to a common width so the right
			-- "│" lines up.
			local max_total = 0
			for _, sn in ipairs(f.snippet) do
				local cols = sn.caret and (5 + #sn.text) or (15 + #sn.text)
				if cols > max_total then
					max_total = cols
				end
			end

			local rule = string.rep("─", max_total - 4)
			-- Borders are intentionally added without a highlight group; paint_active_box
			-- is the single source of truth and repaints both inactive and active states
			-- in NS_BOX on every CursorMoved.
			add("    ┌" .. rule .. "┐", nil, frame_target)
			local box_top = #lines
			local side_rows = {}

			for _, sn in ipairs(f.snippet) do
				local content, cols, hl_group, target
				if sn.caret then
					content = "    │" .. sn.text
					cols = 5 + #sn.text
					target = frame_target
				else
					local prefix = sn.focus and ">" or " "
					content = string.format("    │ %s %5d: %s", prefix, sn.lnum, sn.text)
					cols = 15 + #sn.text
					hl_group = sn.focus and "EnttAssertFocusLine" or nil
					target = f.file and { file = f.file, line = sn.lnum, col = nil } or frame_target
				end
				local pad = string.rep(" ", max_total - cols)
				add(content .. pad .. " │", hl_group, target)
				side_rows[#side_rows + 1] = #lines
			end

			add("    └" .. rule .. "┘", nil, frame_target)
			local box_bot = #lines

			-- "│" is 3 bytes, 1 col. After padding, every content row is max_total+2
			-- cols / max_total+6 bytes, so the left/right "│" byte ranges are fixed.
			local left_col_start, left_col_end = 4, 7
			local right_col_start, right_col_end = max_total + 3, max_total + 6

			boxes[#boxes + 1] = {
				at_row = frame_at_row,
				top = box_top,
				bot = box_bot,
				side_rows = side_rows,
				left_col = { left_col_start, left_col_end },
				right_col = { right_col_start, right_col_end },
			}
		end
		add("")
	end

	return lines, hl, targets, at_rows, boxes
end

local function set_buf_lines(bufnr, lines)
	vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	vim.api.nvim_set_option_value("modified", false, { buf = bufnr })
end

local function apply_highlights(bufnr, hl)
	vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
	for _, h in ipairs(hl) do
		pcall(vim.api.nvim_buf_set_extmark, bufnr, NS, h.row, 0, {
			line_hl_group = h.line_hl_group,
		})
	end
end

local function paint_active_box()
	if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
		return
	end
	vim.api.nvim_buf_clear_namespace(state.bufnr, NS_BOX, 0, -1)
	if not state.boxes or not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
		return
	end
	local cursor_row = vim.api.nvim_win_get_cursor(state.winid)[1]
	for _, box in ipairs(state.boxes) do
		local group = (box.at_row == cursor_row) and "EnttAssertBoxBorderActive" or "EnttAssertBoxBorder"
		pcall(vim.api.nvim_buf_set_extmark, state.bufnr, NS_BOX, box.top - 1, 0, {
			line_hl_group = group,
		})
		pcall(vim.api.nvim_buf_set_extmark, state.bufnr, NS_BOX, box.bot - 1, 0, {
			line_hl_group = group,
		})
		for _, srow in ipairs(box.side_rows) do
			pcall(vim.api.nvim_buf_set_extmark, state.bufnr, NS_BOX, srow - 1, box.left_col[1], {
				end_col = box.left_col[2],
				hl_group = group,
			})
			pcall(vim.api.nvim_buf_set_extmark, state.bufnr, NS_BOX, srow - 1, box.right_col[1], {
				end_col = box.right_col[2],
				hl_group = group,
			})
		end
	end
end

----------------------------------------------------------------------
-- View controller
----------------------------------------------------------------------

local function close()
	if state.tabpage and vim.api.nvim_tabpage_is_valid(state.tabpage) then
		local cur = vim.api.nvim_get_current_tabpage()
		if cur == state.tabpage then
			pcall(vim.cmd, "tabclose")
		else
			-- Closing from another tab: find a window in the viewer tab and wipe its buf.
			for _, w in ipairs(vim.api.nvim_tabpage_list_wins(state.tabpage)) do
				local b = vim.api.nvim_win_get_buf(w)
				pcall(vim.api.nvim_buf_delete, b, { force = true })
			end
		end
	end
	state.tabpage = nil
	state.winid = nil
	state.bufnr = nil
	state.blocks = nil
	state.block_idx = nil
	state.visible_frames = nil
	state.targets = nil
	state.at_rows = nil
	state.boxes = nil
	if state.cursor_au then
		pcall(vim.api.nvim_del_autocmd, state.cursor_au)
		state.cursor_au = nil
	end
end

local function current_target()
	if not state.winid or not state.targets then
		return nil
	end
	if not vim.api.nvim_win_is_valid(state.winid) then
		return nil
	end
	local row = vim.api.nvim_win_get_cursor(state.winid)[1]
	return state.targets[row]
end

local function refresh_view()
	local block = state.blocks[state.block_idx]
	state.visible_frames = build_visible_frames(block, state.user_only)

	local lines, hl, targets, at_rows, boxes = render_all(block, state.visible_frames)
	set_buf_lines(state.bufnr, lines)
	apply_highlights(state.bufnr, hl)
	state.targets = targets
	state.at_rows = at_rows
	state.boxes = boxes
	paint_active_box()

	local hint = "<CR>/gf jump · J/U next/prev frame · c copy · u user-only · q close"
	local title =
		string.format(" ENTT_ASSERT [%d/%d]  logs:%d   %s ", state.block_idx, #state.blocks, block.start_lnum, hint)
	vim.api.nvim_set_option_value("winbar", title, { win = state.winid })

	pcall(vim.api.nvim_win_set_cursor, state.winid, { 1, 0 })
end

local function jump_to_current()
	local target = current_target()
	if not target or not target.file then
		vim.notify("entt_assert: no file for this line", vim.log.levels.WARN)
		return
	end
	local resolved = resolve_path(target.file)
	if vim.fn.filereadable(resolved) ~= 1 then
		vim.notify("entt_assert: cannot find " .. target.file, vim.log.levels.WARN)
		return
	end

	-- Switch back to the originating tab/window so the file opens where the
	-- user invoked the viewer from, not as a buffer inside the viewer tab.
	local prev_win = state.prev_win
	local prev_tab = state.prev_tab
	close()
	if prev_tab and vim.api.nvim_tabpage_is_valid(prev_tab) then
		vim.api.nvim_set_current_tabpage(prev_tab)
	end
	if prev_win and vim.api.nvim_win_is_valid(prev_win) then
		vim.api.nvim_set_current_win(prev_win)
	end
	vim.cmd(string.format("edit %s", vim.fn.fnameescape(resolved)))
	if target.line then
		pcall(vim.api.nvim_win_set_cursor, 0, { target.line, (target.col or 1) - 1 })
		vim.cmd("normal! zz")
	end
end

local function copy_current_location()
	local target = current_target()
	if not target or not target.file then
		return
	end
	local loc = target.file
	if target.line then
		loc = loc .. ":" .. target.line
	end
	vim.fn.setreg("+", loc)
	vim.notify("entt_assert: copied " .. loc)
end

local function step_block(delta)
	local new_idx = state.block_idx + delta
	if new_idx < 1 or new_idx > #state.blocks then
		return
	end
	state.block_idx = new_idx
	refresh_view()
end

local function step_at_line(delta)
	if not state.at_rows or #state.at_rows == 0 or not state.winid then
		return
	end
	local cur = vim.api.nvim_win_get_cursor(state.winid)[1]
	local target
	if delta > 0 then
		for _, r in ipairs(state.at_rows) do
			if r > cur then
				target = r
				break
			end
		end
	else
		for i = #state.at_rows, 1, -1 do
			local r = state.at_rows[i]
			if r < cur then
				target = r
				break
			end
		end
	end
	if target then
		pcall(vim.api.nvim_win_set_cursor, state.winid, { target, 0 })
	end
end

local function toggle_user_only()
	state.user_only = not state.user_only
	refresh_view()
end

local function bind_keys(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "q", close, opts)
	vim.keymap.set("n", "<Esc>", close, opts)
	vim.keymap.set("n", "<CR>", jump_to_current, opts)
	vim.keymap.set("n", "gf", jump_to_current, opts)
	vim.keymap.set("n", "c", copy_current_location, opts)
	vim.keymap.set("n", "u", toggle_user_only, opts)
	vim.keymap.set("n", "J", function()
		step_at_line(1)
	end, opts)
	vim.keymap.set("n", "U", function()
		step_at_line(-1)
	end, opts)
end

local function open_viewer(blocks, idx)
	close()
	state.blocks = blocks
	state.block_idx = idx
	state.user_only = false
	state.prev_win = vim.api.nvim_get_current_win()
	state.prev_tab = vim.api.nvim_get_current_tabpage()

	vim.cmd("tabnew")
	state.tabpage = vim.api.nvim_get_current_tabpage()
	state.winid = vim.api.nvim_get_current_win()
	state.bufnr = vim.api.nvim_get_current_buf()

	pcall(vim.api.nvim_buf_set_name, state.bufnr, "enttassert://viewer")
	vim.bo[state.bufnr].buftype = "nofile"
	vim.bo[state.bufnr].bufhidden = "wipe"
	vim.bo[state.bufnr].swapfile = false
	vim.bo[state.bufnr].filetype = "enttassert"

	vim.wo[state.winid].cursorline = true
	vim.wo[state.winid].wrap = false
	vim.wo[state.winid].number = false
	vim.wo[state.winid].relativenumber = false
	vim.wo[state.winid].signcolumn = "no"
	vim.wo[state.winid].scrolloff = 4
	-- Remap CursorLine to our muted bg so it doesn't combine with the red
	-- DiagnosticError highlight on the banner rows.
	vim.wo[state.winid].winhighlight = "CursorLine:EnttAssertCursorLine"

	bind_keys(state.bufnr)

	state.cursor_au = vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = state.bufnr,
		callback = paint_active_box,
	})

	-- If the user closes the tab manually (e.g. :tabclose), clear state.
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = state.bufnr,
		once = true,
		callback = function()
			vim.schedule(function()
				state.tabpage = nil
				state.winid = nil
				state.bufnr = nil
			end)
		end,
	})

	refresh_view()
end

----------------------------------------------------------------------
-- Public entry points
----------------------------------------------------------------------

local function load_blocks(path)
	path = path or find_logs()
	if not path then
		vim.notify("entt_assert: no logs file found", vim.log.levels.WARN)
		return nil, nil
	end
	local lines, err = read_lines(path)
	if not lines then
		vim.notify("entt_assert: " .. err, vim.log.levels.ERROR)
		return nil, nil
	end
	local blocks = find_assert_blocks(lines)
	if #blocks == 0 then
		vim.notify("entt_assert: no ENTT_ASSERT blocks in " .. path, vim.log.levels.INFO)
		return nil, nil
	end
	return blocks, path
end

function M.view(path)
	local blocks, p = load_blocks(path)
	if not blocks then
		return
	end
	state.source_path = p
	open_viewer(blocks, 1)
end

function M.list(path)
	local blocks, p = load_blocks(path)
	if not blocks then
		return
	end
	state.source_path = p

	local items = {}
	for i, b in ipairs(blocks) do
		local label = string.format("[%d] line %-6d  %s", i, b.start_lnum, b.header.message or "")
		items[#items + 1] = Menu.item(label, { idx = i })
	end

	local menu = Menu({
		position = "50%",
		size = { width = math.min(120, vim.o.columns - 8), height = math.min(#items + 2, 20) },
		border = {
			style = "rounded",
			text = { top = string.format(" ENTT_ASSERT blocks in %s ", p), top_align = "center" },
		},
		win_options = { cursorline = true },
	}, {
		lines = items,
		max_width = 200,
		keymap = {
			focus_next = { "j", "<Down>" },
			focus_prev = { "k", "<Up>" },
			close = { "<Esc>", "q" },
			submit = { "<CR>" },
		},
		on_submit = function(item)
			open_viewer(blocks, item.idx)
		end,
	})

	menu:mount()
end

function M.close()
	close()
end

----------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------

vim.api.nvim_create_user_command("EnttAssertView", function(opts)
	M.view(opts.args ~= "" and opts.args or nil)
end, { nargs = "?", complete = "file" })

vim.api.nvim_create_user_command("EnttAssertList", function(opts)
	M.list(opts.args ~= "" and opts.args or nil)
end, { nargs = "?", complete = "file" })

vim.api.nvim_create_user_command("EnttAssertClose", function()
	M.close()
end, {})

return M
