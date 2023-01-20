local cmd =  vim.api.nvim_command

cmd("highlight! link FloatBorder Normal")
cmd("highlight! link NormalFloat Normal")

cmd("highlight! link DiagnosticFloatingError Normal")
cmd("highlight! link DiagnosticFloatingWarn Normal")
cmd("highlight! link DiagnosticFloatingInfo Normal")
cmd("highlight! link DiagnosticFloatingHint Normal")
