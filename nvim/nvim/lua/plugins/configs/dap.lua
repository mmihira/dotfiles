local dap, dapui = require("dap"), require("dapui")

dapui.setup()
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

local cfg = {
   configurations = {
      -- C lang configurations
      cpp = {
         {
            name = "Launch debugger",
            type = "lldb",
            request = "launch",
            cwd = "${workspaceFolder}",
            program = function()
               -- Build with debug symbols
               local out = vim.fn.system({"cd", "./out/debug"}, {"make", "build -j 8"})
               -- Check for errors
               if vim.v.shell_error ~= 0 then
                  vim.notify(out, vim.log.levels.ERROR)
                  return nil
               end
              return "~/c/ove/out/Debug/ove"
            end,
         },
      },
   },
}

require("dap-lldb").setup(cfg)
