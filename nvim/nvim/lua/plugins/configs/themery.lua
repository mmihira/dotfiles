local present, themery = pcall(require, "themery")
if not present then
  return
end

themery.setup({
  themes = {
    "gruvbox",
    "gruvbox-material",
    "catppuccin-frappe",
    "catppuccin-macchiato",
    "catppuccin-mocha",
    "catppuccin-nvim",
    "kanagawa-wave",
    "kanagawa-lotus",
    "kanagawa-dragon",
    "vague",
    "tokyonight-day",
    "tokyonight-moon",
    "tokyonight-night",
    "tokyonight-storm",
    "rose-pine-dawn",
    "rose-pine-main",
    "rose-pine-moon",
  },
  livePreview = true,
})
