local dap, dapui = require("dap"), require("dapui")

dapui.setup({
  layouts = {
    {
      elements = {
        {
          id = "scopes",
          size = 0.25,
        },
      },
      position = "bottom",
      size = 10,
    },
  },
})
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
