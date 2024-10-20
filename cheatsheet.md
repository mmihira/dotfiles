Vim
--------------------------------------------------------------------------------------
**************************************************************************************

:Old                Telescope file history
:Cheat              Open this page
:Vimfile            Open init.vim
:Settings           Open keymaps
:Nocmp              Disable autocompletion for the session
:OpenData           Open the data file directory in NeoTree
:Snip               Open the snippet directory
:GhistFile          View history for current file
:GhistBranch        View history for current branch

Movement
--------------------------------------------------------------------------------------
zz                  Center current line
<Ctr> a             Last Buffer
<Ctr> p             Next Buffer

Snippets
--------------------------------------------------------------------------------------
<Tab>               In insert mode tab to next node.
<Ctr>l              When in insert mode go to next alternative
<Ctr>i              When in insert mode go to next input section of snippet

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
<C-t>               To send file list to trouble quickfix list

Lsp
--------------------------------------------------------------------------------------
:Ref                Find all references for under cursor, then <C-t> to send to quickfix list
:Imp                Find all implementations for this interface
:Sym                List all functions in this file
<space>cl           Code Lens
<space>gd           Open definition window
<C-w>L              Open definiton in new tab
<space>im           Implement a go interface for a type 
<C-a>               Switch to alternatve in golang
:Sp                 TSJToggle
:Issues             See list of diagnositcs
:Stack              Trouble qflist specifically for stacktraces
<Ctrl-a>            Alternative file

Debug
--------------------------------------------------------------------------------------

Git
--------------------------------------------------------------------------------------
:Diff               Open up a diff view of current changes
:GhistFile          View history for current file
:GhistBranch        View history for current branch
<leader>q           Quit the diff
gf                  Open file
<leader>ss          Diff in telescope
<leader>sg          View diff overlay
0                   Jump to next hunk

ToggleTerm
--------------------------------------------------------------------------------------
<leader>mm          Toggle a terminal, or open the existing one. Can be used even when in insert mode in terminal
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
ysiw"               Surround the word
ys$"                Surround till end of line
s"                  In visual mode just press s then "
ds"                 Use d followed by s then " to remove a surround

Macquarie
--------------------------------------------------------------------------------------

:ProdConfig         Open neotree in product config registry
:GhistPCR           Show commit affecting ci-platform

Command
--------------------------------------------------------------------------------------

Ctr+F               in command screen to open up buffer

