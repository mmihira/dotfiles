-- build_capture.lua — load xmake build-capture diagnostics into vim.diagnostic
--
-- Pairs with tools/build_capture.lua in projects using xmake. Reads
-- build/diagnostics.json (searched upward from cwd) and pushes entries to
-- a dedicated diagnostic namespace so Trouble/quickfix/etc. pick them up.
--
-- Usage:
--   :BuildCaptureLoad [path]   load JSON (default: ./build/diagnostics.json)
--   :BuildCaptureClear         wipe namespace
--   :BuildCaptureWatch         toggle auto-reload on file change
--   :BuildCaptureSummary       echo build status + diagnostic count
--
-- Then `:Trouble diagnostics` or `:lua vim.diagnostic.setqflist()` etc.

local M = {}

local NS = vim.api.nvim_create_namespace("build_capture")
local SEVERITY = {
    error   = vim.diagnostic.severity.ERROR,
    fatal   = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    note    = vim.diagnostic.severity.HINT,
}

local last_path = nil
local watch_handle = nil

local function find_json()
    local found = vim.fs.find("build/diagnostics.json", {
        upward = true,
        path = vim.fn.getcwd(),
        stop = vim.uv.os_homedir(),
    })
    return found[1]
end

local function read_json(filepath)
    local f = io.open(filepath, "r")
    if not f then return nil, ("cannot open: " .. filepath) end
    local raw = f:read("*a")
    f:close()
    local ok, decoded = pcall(vim.json.decode, raw)
    if not ok then return nil, ("json decode failed: " .. decoded) end
    return decoded
end

-- Build the message body the diagnostic UI will show. Keep it rich:
-- includes the clang caret/source context and any attached notes.
local function format_message(d)
    local parts = { d.message }
    if d.context and #d.context > 0 then
        table.insert(parts, d.context)
    end
    if d.notes then
        for _, n in ipairs(d.notes) do
            table.insert(parts, string.format("note: %s:%d:%d: %s",
                vim.fn.fnamemodify(n.file, ":."), n.line, n.col, n.message))
        end
    end
    return table.concat(parts, "\n")
end

local function to_diag(d)
    return {
        lnum     = math.max((d.line or 1) - 1, 0),
        col      = math.max((d.col or 1) - 1, 0),
        end_lnum = math.max((d.line or 1) - 1, 0),
        end_col  = math.max((d.col or 1) - 1, 0) + 1,
        severity = SEVERITY[d.severity] or vim.diagnostic.severity.ERROR,
        message  = format_message(d),
        source   = "build-capture",
        user_data = { context = d.context, notes = d.notes },
    }
end

function M.clear()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        vim.diagnostic.reset(NS, buf)
    end
end

function M.load(filepath)
    filepath = filepath or find_json()
    if not filepath then
        vim.notify("build_capture: no diagnostics.json found", vim.log.levels.WARN)
        return
    end
    local data, err = read_json(filepath)
    if not data then
        vim.notify("build_capture: " .. err, vim.log.levels.ERROR)
        return
    end
    last_path = filepath

    -- Group diagnostics by absolute file path, then push per-buffer.
    local by_file = {}
    for _, d in ipairs(data.diagnostics or {}) do
        by_file[d.file] = by_file[d.file] or {}
        table.insert(by_file[d.file], to_diag(d))
    end

    M.clear()
    local file_count, diag_count = 0, 0
    for file, items in pairs(by_file) do
        local bufnr = vim.fn.bufadd(file)
        vim.fn.bufload(bufnr)
        vim.diagnostic.set(NS, bufnr, items)
        file_count = file_count + 1
        diag_count = diag_count + #items
    end

    local b = data.build or {}
    local status = b.ok and "ok" or string.format("FAILED (exit=%s)", tostring(b.exitcode))
    vim.notify(string.format("build_capture: build %s — %d diag in %d file(s)",
        status, diag_count, file_count),
        b.ok and vim.log.levels.INFO or vim.log.levels.WARN)
end

function M.show_summary()
    if not last_path then
        print("build_capture: nothing loaded")
        return
    end
    local data = read_json(last_path) or {}
    local b = data.build or {}
    print(string.format("build_capture: %s  exit=%s  diags=%d  log=%s",
        last_path, tostring(b.exitcode), #(data.diagnostics or {}),
        tostring(b.log)))
end

function M.toggle_watch(filepath)
    if watch_handle then
        watch_handle:stop()
        watch_handle:close()
        watch_handle = nil
        vim.notify("build_capture: watch off")
        return
    end
    filepath = filepath or last_path or find_json()
    if not filepath then
        vim.notify("build_capture: no file to watch", vim.log.levels.WARN)
        return
    end
    watch_handle = vim.uv.new_fs_event()
    local timer = nil
    watch_handle:start(filepath, {}, function(err)
        if err then return end
        if timer then timer:stop(); timer:close() end
        timer = vim.uv.new_timer()
        timer:start(120, 0, vim.schedule_wrap(function()
            timer:close(); timer = nil
            M.load(filepath)
        end))
    end)
    vim.notify("build_capture: watching " .. filepath)
end

vim.api.nvim_create_user_command("BuildCaptureLoad", function(opts)
    M.load(opts.args ~= "" and opts.args or nil)
end, { nargs = "?", complete = "file" })

vim.api.nvim_create_user_command("BuildCaptureClear", function() M.clear() end, {})
vim.api.nvim_create_user_command("BuildCaptureWatch", function(opts)
    M.toggle_watch(opts.args ~= "" and opts.args or nil)
end, { nargs = "?", complete = "file" })
vim.api.nvim_create_user_command("BuildCaptureSummary", function() M.show_summary() end, {})

return M
