local g = vim.g
local opt = vim.opt

opt.hidden=true            -- Allow navigating to buffers without saving
opt.rnu=true               -- Set relative numbering
opt.nu=true                -- Set numbering
opt.ruler=true             -- Show line numbering
opt.number=true            -- Ensure we see line numbers
opt.signcolumn="yes"       -- Always show sign column
opt.tabstop=2
opt.shiftwidth=2
opt.showcmd=true           -- Show (partial) command in status line.
opt.showmatch=true         -- Show matching brackets.
opt.ignorecase=true        -- Do case insensitive matching
opt.smartcase=true         -- Do smart case matching
opt.incsearch=true         -- Incremental search
opt.hlsearch=true          -- Highlight after search finished
opt.smartindent=true       -- Auto detect indenting
opt.expandtab=true         -- Make tab spaces
opt.cursorline=true        -- Highlight the line the cursor is on
opt.hidden=true            -- Hide buffers when they are abandoned
opt.mouse=""               -- Disable the mouse
opt.mousetime=1            -- double click problem
opt.foldenable=false       -- Don't use folding
opt.backupcopy="yes"
opt.updatetime=1000        -- Hold time before file written to disk in ms
opt.ttyfast=true
opt.path=".,src,node_modules"                                             -- Add paths to gf command
opt.suffixesadd=".js,.jsx"                                                -- Specify you can open using gf command
opt.completeopt="preview"
opt.splitright=true        -- Open vertical splits to the right
opt.updatetime=800
opt.laststatus=0
opt.swapfile=false
opt.termguicolors=true
-- opt.filetype=off
