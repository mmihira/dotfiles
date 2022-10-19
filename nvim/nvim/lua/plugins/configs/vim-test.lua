local floa_vim_test_callback = function(opts)
    local main = vim.api.nvim_call_function("floaterm#terminal#get_bufnr",{"main_term"})
    if main then
        vim.api.nvim_command(':FloatermToggle main_term')
    else
        vim.api.nvim_command(
            ':FloatermNew! --wintype=float --name=main_term --width=0.8 --height=0.8')
    end

  main = vim.api.nvim_call_function("floaterm#terminal#get_bufnr",{"main_term"})
  vim.call("floaterm#terminal#send", main, {opts})
  vim.api.nvim_command(':stopinsert')

end

vim.g['test#custom_strategies'] = { custom_floaterm = floa_vim_test_callback }
vim.g['test#strategy'] = 'custom_floaterm'
vim.g['test#go#go#options'] = "-v"
vim.g['test#go#gotest#options'] = "-v"
