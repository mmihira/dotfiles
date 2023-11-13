local fn = vim.fn
-- Automatically install packer on initial startup
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  Packer_Bootstrap = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("---------------------------------------------------------")
  print("Press Enter to install packer and plugins.")
  print("After install -- close and reopen Neovim to load configs!")
  print("---------------------------------------------------------")
  vim.cmd([[packadd packer.nvim]])
end

-- Use a protected call
local present, packer = pcall(require, "packer")

if not present then
  return
end

packer.startup(function(use)
  -- Util
  use("wbthomason/packer.nvim")
  use("nvim-lua/plenary.nvim")
  use("nvim-lua/popup.nvim")

  -- Terminal
  use("voldikss/vim-floaterm")

  -- LSP
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
  })
  use("williamboman/mason.nvim")
  use("williamboman/mason-lspconfig.nvim")
  use("neovim/nvim-lspconfig")
  use("folke/trouble.nvim")
  use("mfussenegger/nvim-jdtls")
  use({
    "j-hui/fidget.nvim", -- for nicely displaying lsp startup progress
    tag = "legacy",
    config = function()
      require("fidget").setup({})
    end,
  })
  use({ "rmagatti/goto-preview" })
  use({ "ThePrimeagen/refactoring.nvim" })
  use({
    "edolphin-ydf/goimpl.nvim",
    config = function()
      require("telescope").load_extension("goimpl")
    end,
  })

  -- Syntax
  use("euclidianAce/BetterLua.vim")
  use("tpope/vim-commentary")
  use({ "kylechui/nvim-surround", tag = "*" })
  use("jose-elias-alvarez/null-ls.nvim")
  use("cohama/lexima.vim")
  use("mechatroner/rainbow_csv")
  use("hashivim/vim-terraform")

  -- Completion
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("hrsh7th/cmp-nvim-lsp")
  -- use("hrsh7th/cmp-nvim-lsp-signature-help")
  use("ray-x/lsp_signature.nvim")
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")
  use("rafamadriz/friendly-snippets")

  -- Testing
  use("janko-m/vim-test")

  -- Git
  use("itchyny/vim-gitbranch")
  use("lewis6991/gitsigns.nvim")
  use("sindrets/diffview.nvim")

  -- Finders
  use("nvim-telescope/telescope.nvim") -- finder, requires fzf and ripgrep
  use("nvim-telescope/telescope-ui-select.nvim")

  -- Navigation
  use("kwkarlwang/bufjump.nvim")
  use("folke/flash.nvim")

  -- Tree
  use({
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  })

  -- Display
  use("itchyny/lightline.vim")
  use("echasnovski/mini.starter")
  use("MunifTanjim/nui.nvim")
  use("CosmicNvim/cosmic-ui")
  use({
    "b0o/incline.nvim",
    config = function()
      require("incline").setup()
    end,
  }) -- floating status line

  -- Color Schemes
  use("ellisonleao/gruvbox.nvim")
  use("EdenEast/nightfox.nvim")
  use({
    "ray-x/starry.nvim",
    setup = function()
      vim.g.starry_italic_comments = true
    end,
  })

  -- Notes
  use({
    "renerocksai/telekasten.nvim",
  })

  -- Automatically set up your configuration after cloning packer.nvim
  if Packer_Bootstrap then
    require("packer").sync()
  end
end)
