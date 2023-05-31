local present, gotopreview = pcall(require, "goto-preview")
if not present then
  return
end

gotopreview.setup({
  resizing_mappings = true,
})
