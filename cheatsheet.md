Tmux
--------------------------------------------------------------------------------------
**************************************************************************************

<C>a <Enter>        Switch to copy mode with vim bindings, visual select and <Enter> to copy
<C>a ;              Swtich to last buffer
<C>a h,l            Switch buffers left, right
<C>-                Split vertical
<C>_                Split horizontal

Vim
--------------------------------------------------------------------------------------
**************************************************************************************

:Old                Telescope file history
:Cheat              Open this page
:Vimfile            Open init.vim
:Nocmp              Disable autocompletion for the session
:OpenData           Open the data file directory in NeoTree
:Snip               Open the snippet directory
:Settings           Open keymaps

Movement
--------------------------------------------------------------------------------------
zz                  Center current line

Snippets
--------------------------------------------------------------------------------------
<Tab>               In insert mode tab to next node.

Cmp
--------------------------------------------------------------------------------------
<Ctr>e              Exit cmp selection, without screwing up snippets

Notes
--------------------------------------------------------------------------------------
:NV                 Open up a rigpgrep for searching your notes

Telescope
--------------------------------------------------------------------------------------
<C-k>               List all buffers in telescope
:Old                Search oldfiles
<Space>k            Live grep search
                    j,k if not typing. Else C-n,p for up/down

Lsp
--------------------------------------------------------------------------------------
:Ref                Find all references for under cursor
:Sym                List all functions in this file
<space>cl           Code Lens

Git
--------------------------------------------------------------------------------------
:Diff               Open up a diff view of current changes
:Ghist              Show git history of current file
<leader>q           Quit the diff
gf                  Open file
<C-h>               Jump to next hunk
-                   To stage the file

Floaterm
--------------------------------------------------------------------------------------
<leader>mm          Open a new floating terminal, or open the existing one
<leader>qq          Exit out of insert mode in terminal
F9                  Toggle between float, and botright

NeoTree
--------------------------------------------------------------------------------------
<leader>nn          Opens up the tree, focusing on current directory
backspace           Reveal more of dir
o                   Open up file or dir
v                   Vertical split file
.                   Make directory root

Surround
--------------------------------------------------------------------------------------
selection s, [b or ' or "]
