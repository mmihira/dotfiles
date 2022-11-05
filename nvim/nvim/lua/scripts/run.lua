local M = {}

local exec_floaterm = function(command)
  local main = vim.api.nvim_call_function("floaterm#terminal#get_bufnr", { "main_term" })
  if main then
    vim.api.nvim_command(":FloatermToggle main_term")
  else
    vim.api.nvim_command(":FloatermNew! --wintype=float --name=main_term --width=0.8 --height=0.8")
  end

  local main = vim.api.nvim_call_function("floaterm#terminal#get_bufnr", { "main_term" })
  vim.call("floaterm#terminal#send", main, { command })
  vim.api.nvim_command(":stopinsert")
end

local run_lua = function()
  vim.api.nvim_command(":luafile %")
end

local run_bash = function(file_path)
  local parent_path = file_path:parent()
  local rel = file_path:make_relative(parent_path:absolute())
  local _cmd = "(cd " .. parent_path:absolute() .. "; " .. "./" .. rel .. ")"
  exec_floaterm(_cmd)
end

local run_go = function(file_path)
  -- Should traverse up the directory until main.go is found
  local parent_path = file_path:parent()
  local rel = file_path:make_relative(parent_path:absolute())
  local go_build_cmd = "go build -o go_app"
  local _cmd = "(cd " .. parent_path:absolute() .. "; " .. go_build_cmd .. ";" .. "./go_app" .. ")"
  exec_floaterm(_cmd)
end

local run_file = function()
  local plenary = require("plenary")
  local path = require("plenary.path")

  local file_full_path = vim.api.nvim_buf_get_name(0)
  local file_path = path.new(file_full_path)
  local filetype = plenary.filetype.detect_from_extension(file_full_path)

  if filetype == "lua" then
    run_lua()
  end
  if filetype == "sh" then
    run_bash(file_path)
  end
  if filetype == "go" then
    run_go(file_path)
  end
end
M.run_file = run_file

return M
