local dap, dapui = require("dap"), require("dap-view")

dapui.setup({
  winbar = {
    show = true,
    sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
    default_section = "watches",
    show_keymap_hints = true,
    base_sections = {
      breakpoints = { label = "Breakpoints", keymap = "B" },
      scopes = { label = "Scopes", keymap = "S" },
      exceptions = { label = "Exceptions", keymap = "E" },
      watches = { label = "Watches", keymap = "W" },
      threads = { label = "Threads", keymap = "T" },
      repl = { label = "REPL", keymap = "R" },
      sessions = { label = "Sessions", keymap = "K" },
      console = { label = "Console", keymap = "C" },
    },
    custom_sections = {},
    controls = {
      enabled = false,
      position = "right",
      buttons = {
        "play",
        "step_into",
        "step_over",
        "step_out",
        "step_back",
        "run_last",
        "terminate",
        "disconnect",
      },
      custom_buttons = {},
    },
  },
  windows = {
    size = 0.25,
    position = "below",
    terminal = {
      size = 0.5,
      position = "left",
      hide = {},
    },
  },
  icons = {
    collapsed = "󰅂 ",
    disabled = "",
    disconnect = "",
    enabled = "",
    expanded = "󰅀 ",
    filter = "󰈲",
    negate = " ",
    pause = "",
    play = "",
    run_last = "",
    step_back = "",
    step_into = "",
    step_out = "",
    step_over = "",
    terminate = "",
  },
  help = {
    border = nil,
  },
  render = {
    sort_variables = nil,
    threads = {
      format = function(name, lnum, path)
        return {
          { part = name, separator = " " },
          { part = path, hl = "FileName",  separator = ":" },
          { part = lnum, hl = "LineNumber" },
        }
      end,
      align = false,
    },
    breakpoints = {
      format = function(line, lnum, path)
        return {
          { part = path, hl = "FileName" },
          { part = lnum, hl = "LineNumber" },
          { part = line, hl = true },
        }
      end,
      align = false,
    },
  },
  switchbuf = "usetab,uselast",
  auto_toggle = true,
  follow_tab = false,
})

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
          local out = vim.fn.system({ "cd", "./out/debug" }, { "make", "build -j 8" })
          -- Check for errors
          if vim.v.shell_error ~= 0 then
            vim.notify(out, vim.log.levels.ERROR)
            return nil
          end
          return "${workspaceFolder}/out/debug/ove"
        end,
      },
    },
  },
}

require("dap-lldb").setup(cfg)
require("nvim-dap-virtual-text").setup {
  enabled = true,                       -- enable this plugin (the default)
  enabled_commands = true,              -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
  highlight_changed_variables = true,   -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
  highlight_new_as_changed = false,     -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
  show_stop_reason = true,              -- show stop reason when stopped for exceptions
  commented = false,                    -- prefix virtual text with comment string
  only_first_definition = true,         -- only show virtual text at first definition (if there are multiple)
  all_references = false,               -- show virtual text on all all references of the variable (not only definitions)
  clear_on_continue = false,            -- clear virtual text on "continue" (might cause flickering when stepping)
  --- A callback that determines how a variable is displayed or whether it should be omitted
  --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
  --- @param buf number
  --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
  --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
  --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
  --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
  display_callback = function(variable, buf, stackframe, node, options)
    -- by default, strip out new line characters
    if options.virt_text_pos == 'inline' then
      return ' = ' .. variable.value:gsub("%s+", " ")
    else
      return variable.name .. ' = ' .. variable.value:gsub("%s+", " ")
    end
  end,
  -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
  virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

  -- experimental features:
  all_frames = false,       -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
  virt_lines = false,       -- show virtual lines instead of virtual text (will flicker!)
  virt_text_win_col = nil   -- position the virtual text at a fixed window column (starting from the first text column) ,
  -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
}
