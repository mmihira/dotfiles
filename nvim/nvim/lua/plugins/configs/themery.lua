local present, themery = pcall(require, "themery")
if not present then
  return
end

themery.setup({
  themes = {
    "gruvbox",
    "gruvbox-material",
    "catppuccin",
    "catppuccin-frappe",
    "catppuccin-macchiato",
    "catppuccin-mocha",
    "catppuccin-nvim",
  },
  livePreview = true,
})
