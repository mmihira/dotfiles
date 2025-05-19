local trouble = {
  "folke/trouble.nvim",
  opts = { use_diagnostic_signs = true },
}

local telescope = {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>fp",
      function()
        require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
      end,
      desc = "Find Plugin File",
    },
  },
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
    },
  },
}

local gruvbox = { "ellisonleao/gruvbox.nvim" }

local nvim_cmp = {
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-emoji" },
  opts = function(_, opts)
    table.insert(opts.sources, { name = "emoji" })
  end,
}

local lspconfig_tsserver = {
  "neovim/nvim-lspconfig",
  dependencies = {},
}

local treesitter = {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    },
  },
}

return {
  trouble,
  telescope,
  gruvbox,
  -- nvim_cmp,
  lspconfig_tsserver,
  treesitter,
}
