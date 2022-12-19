local lsplib = require("plugins/configs/lspl")
local lombok_path = vim.fn.expand("~/.m2/repository/org/projectlombok/lombok/1.18.24/lombok-1.18.24.jar")
local datapath = vim.fn.stdpath("data")

config = lsplib.mk_config()
config.cmd = {

  "java", -- or '/path/to/java17_or_newer/bin/java'

  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.protocol=true",
  "-Dlog.level=ALL",
  "-Xms1g",
  "-Xmx2G",

  "--add-modules=ALL-SYSTEM",
  "--add-opens",
  "java.base/java.util=ALL-UNNAMED",
  "--add-opens",
  "java.base/java.lang=ALL-UNNAMED",

  "-javaagent:" .. lombok_path,

  "-jar",
  -- we should automatically find the version here otherwise we have to change it everytime we update jdtls
  datapath .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",  

  "-configuration",
  datapath .. "/mason/packages/jdtls/config_mac",

  "-data",
  datapath .. "/nvim/java_ws",
}

-- This is the default if not provided, you can remove it. Or adjust as needed.
-- One dedicated LSP server & client will be started per unique root_dir
config.root_dir = require("jdtls.setup").find_root({ ".git", "pom.xml", "mvnw", "gradlew" })

-- Here you can configure eclipse.jdt.ls specific settings
-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
-- for a list of options
config.settings = {
  java = {},
}

-- Language server `initializationOptions`
-- You need to extend the `bundles` with paths to jar files
-- if you want to use additional eclipse.jdt.ls plugins.
--
-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
--
-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
config.init_options = {
  bundles = {},
}

-- For picking a file to move to etc
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local pickers = require("telescope.pickers")
require("jdtls.ui").pick_one_async = function(items, prompt, label_fn, cb)
  local opts = {}
  pickers
      .new(opts, {
        prompt_title = prompt,
        finder = finders.new_table({
          results = items,
          entry_maker = function(entry)
            return {
              value = entry,
              display = label_fn(entry),
              ordinal = label_fn(entry),
            }
          end,
        }),
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local action_state = require("telescope.actions.state")
            local selection = action_state.get_selected_entry(prompt_bufnr)
            actions.close(prompt_bufnr)

            cb(selection.value)
          end)

          return true
        end,
      })
      :find()
end

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)

-- Tree Sitter
vim.api.nvim_command("TSEnable highlight")
