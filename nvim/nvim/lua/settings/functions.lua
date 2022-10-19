local present, diffview = pcall(require, "diffview")
if present then
    vim.api.nvim_create_user_command('Diff', function(opts) diffview.open() end,
                                     {nargs = 0})
end

vim.api.nvim_create_user_command('Vimfile', function(opts)
    vim.api.nvim_command(':e ~/.config/nvim/init.vim')
end, {nargs = 0})

vim.api.nvim_create_user_command('StartMainFloat', function(opts)
    local main = vim.api.nvim_call_function("floaterm#terminal#get_bufnr",
                                            {"main_term"})
    if main then
        vim.api.nvim_command(':FloatermToggle main_term')
    else
        vim.api.nvim_command(
            ':FloatermNew! --wintype=float --name=main_term --width=0.8 --height=0.8')

    end
end, {nargs = 0})

vim.api.nvim_create_user_command('Ses', function(opts)
  require("persistence").load({last = true})
end, {nargs = 0})
