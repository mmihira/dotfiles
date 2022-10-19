local present, neotree = pcall(require, "neo-tree")
if not present then return end

neotree.setup({
    window = {mappings = {["v"] = "open_vsplit", ["o"] = "open"}},
    filesystem = {
        filterd_items = {
          visible = true,
          hide_dotfiles = false, 
          hide_gitignored = false,
        }
    }
})

