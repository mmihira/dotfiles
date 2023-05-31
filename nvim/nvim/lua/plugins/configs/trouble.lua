local present, trouble = pcall(require, "trouble")
if not present then
  return
end

-- Setup Trouble
trouble.setup({
  icons = true,
  fold_open = "v", -- icon used for open folds
  fold_closed = ">", -- icon used for closed folds
  indent_lines = false, -- add an indent guide below the fold icons
  signs = {
    error = "error",
    warning = "warn",
    hint = "hint",
    information = "info",
  },
})

