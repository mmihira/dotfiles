local present, gotopreview = pcall(require, "goto-preview")
if not present then
  return
end

gotopreview.setup({
  resizing_mappings = true,
  post_open_hook = function (buffer, _)
    vim.api.nvim_buf_set_keymap(buffer, 'n', 'v', '<C-w>L', {noremap = true})
  end
})
