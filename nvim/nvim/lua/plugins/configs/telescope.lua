local present, tele_actions = pcall(require, "telescope.actions")
if not present then
  return
end

local present, telescope = pcall(require, "telescope")
if not present then
  return
end

local present, trouble = pcall(require, "trouble")
if not present then
  return
end

local actions = require("telescope.actions")
local trouble = require("trouble.providers.telescope")

telescope.setup({
  defaults = {
    initial_mode = "normal",
    layout_config = { prompt_position = "top" },
    mappings = {
      n = {
        ["<leader>q"] = "close",
        ["<c-t>"] = trouble.open_with_trouble,
      },
      i = { ["<c-t>"] = trouble.open_with_trouble },
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
      -- pseudo code / specification for writing custom displays, like the one
      -- for "codeactions"
      -- specific_opts = {
      --   [kind] = {
      --     make_indexed = function(items) -> indexed_items, width,
      --     make_displayer = function(widths) -> displayer
      --     make_display = function(displayer) -> function(e)
      --     make_ordinal = function(e) -> string
      --   },
      --   -- for example to disable the custom builtin "codeactions" display
      --      do the following
      --   codeactions = false,
      -- }
    },
  },
})

telescope.load_extension("ui-select")
