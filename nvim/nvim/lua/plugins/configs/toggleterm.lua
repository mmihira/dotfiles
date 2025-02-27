local present, tterm = pcall(require, "toggleterm")
if not present then
  return
end

function strsplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

MAX_LOOKBACK = 100

function populate_qf_with_go_stack(bn)
  qlistresults = {}

  endinx = vim.api.nvim_buf_line_count(bn)
  inx = vim.api.nvim_buf_line_count(bn)

  while inx > 0 and (endinx - inx) < MAX_LOOKBACK do
    local bufrlines = vim.api.nvim_buf_get_lines(bn, inx - 1, inx, false)

    if string.match(bufrlines[1], ".+/.*.go:") then
      local strsplit0 = strsplit(bufrlines[1], ":")
      local lsplit = strsplit(strsplit0[2], " ")
      local txt = vim.api.nvim_buf_get_lines(bn, inx - 2, inx - 1, false)
      local item = {
        filename = string.gsub(strsplit0[1], "%s+", ""),
        lnum = tonumber(lsplit[1]),
        col = 1,
        pos = inx,
        text = string.gsub(txt[1], "%s+", ""),
      }
      table.insert(qlistresults, item)
    end

    if string.match(bufrlines[1], "goroutine.*[running]") then
      inx = -1
    end

    inx = inx - 1
  end

  qlistresultsordered = {}
  inx = #qlistresults
  while inx > 0 do
    table.insert(qlistresultsordered, qlistresults[inx])
    inx = inx - 1
  end

  vim.fn.setqflist({}, " ", { title = "StackTrace", id = "$", items = qlistresultsordered })
end

tterm.setup({
  on_close = function(t)
    if t.display_name == "test_term" then
      populate_qf_with_go_stack(t.bufnr)
    end
    if t.display_name == "main_term" then
      populate_qf_with_go_stack(t.bufnr)
    end
  end,
})
