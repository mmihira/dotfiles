runtime! debian.vim

" Setup plug if not allready
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! BASE VIM SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hidden            " Allow navigating to buffers without saving
set rnu               " Set relative numbering
set nu                " Set numbering
set ruler             " Show line numbering
set number            " Ensure we see line numbers
set tabstop=2
set shiftwidth=2
set showcmd		        " Show (partial) command in status line.
set showmatch		      " Show matching brackets.
set ignorecase        " Do case insensitive matching
set smartcase		      " Do smart case matching
set incsearch		      " Incremental search
set hlsearch          " Highlight after search finished
"set smartindent      " Auto detect indenting
set expandtab         " Make tab spaces
set cursorline        " Highligh the line the cursor is on
set hidden		        " Hide buffers when they are abandoned
set mouse=""		      " Disable the mouse
set mousetime=1       " double click problem
set backupdir=~/.tmp  " Save swp and tmp files to a different place
set directory=~/.tmp  " Save swp and tmp files to a different place
set nofoldenable      " Don't use folding
set backupcopy=yes
set updatetime=1000   " Hold time before file written to disk in ms
"set ttyfast
set path=.,src,node_modules                                             " Add paths to gf command
set suffixesadd=.js,.jsx                                                " Specify you can open using gf command
set includeexpr=substitute(v:fname,'::\\(.*\\)','\\1\/index\.js','')    " Open javascript files when index is not specified (Fix, not working)
set completeopt-=preview
filetype off

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! KEY REMAPPING
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Unite
nnoremap <C-l> :Unite file file_rec/async <CR>
nnoremap <C-k> :Unite buffer<CR>
nnoremap <C-j> :Unite bookmark file_mru<CR>
" Quick Buffer Access
nnoremap <C-i> :b# <CR>
" Stop mistakingly causing text to lowercase
nnoremap q: <Nop>
"nnoremap Vu <Nop>
vnoremap u <Nop>

" Map line matching omnicomplete
inoremap <C-l> <C-x><C-l>
" JJ
:imap jj <Esc>
:cmap jj <Esc>

" Jump to anywhere you want with minimal keystrokes, with just one key binding." `s{char}{label}`
nmap s <Plug>(easymotion-bd-f)

" !! LEADER REMAPS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"
" NERDTree
nnoremap <leader>nn :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>
" Reassign macro key
nnoremap <Leader>z q<CR>
nnoremap q <Nop>
" Remap exit
noremap <Leader>q :q<CR>
tnoremap ;;q <C-\><C-n>:q<CR>
" Switch splits
noremap <Leader>m <C-w>w
tnoremap ;;a <C-\><C-n><C-w>w
" Fugitive Vim
noremap <Leader>gs :Gstatus <CR> <C-w>T
au FileType go noremap <Leader>gd :GoDef <CR>
" Remap cancel highlight
nnoremap <Leader>8 :noh<CR>
" Remap save
nnoremap <Leader>f :w<CR>
" Remap paste from + buffer
nnoremap <Leader>= "+gP
" Gundo map
nnoremap <Leader>0 :MundoToggle<CR>
" Remap copy one line to system buffer
nnoremap <Leader>cc V"+yyv <CR>
vnoremap <Leader>cc "+yyv <CR>
" Search for highlighted text in dir
vnoremap <Leader>cs "0y :Ack! <C-r>0
" Replace highlighted text buffer global
vnoremap <Leader>r "0y :%s/<C-r>0
" Copy file path to buffer
nnoremap <silent> <leader>cp :let @+ = expand('%:p')<CR>
" Ale fix
nnoremap <Leader>lf :ALEFix<CR>

""""" NeoTerm Leader map """""
" Run the run.sh script
nnoremap <Leader>r :Run <CR>
" Vim-Test
nnoremap <silent> <Leader>t :TestNearest<CR>
nnoremap <silent> <Leader>T :TestFile<CR>
nnoremap <silent> <Leader>C :T clear<CR>

""""" Rust Specific maps """""
" Insert println!
autocmd FileType rust noremap <silent> <Leader>rp iprintln!("{:?}", )<Esc>^

" Rust Racer
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)

""""" Python specific maps """""
" Pry
autocmd FileType python command! Pry :normal i import code; code.interact(local=dict(globals(), **locals()))<Esc>^

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! CUSTOM COMMANDS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! Spwd cd %:p:h

function Run()
  :w
  if g:neoterm.has_any()
    let combined = join(['T', '~/bin/nvim_run.sh ', expand('%:p')])
    :exe combined
  else
    :vert Topen
    :exe "normal \<C-w>\h"
    :exe "normal \<C-w>\L"
    let combined = join(['T', '~/bin/nvim_run.sh ', expand('%:p')])
    :exe combined
  end
endfunction
command! Run :call Run()

command! Jsi :ImportJSFix

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! PluginSetup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

" Builds and testing
Plug  'janko-m/vim-test'

" Terminal
Plug  'kassio/neoterm'

" Code Helpers
Plug  'tpope/vim-surround'
Plug  'tpope/vim-commentary'
Plug  'simnalamburt/vim-mundo'
Plug  'racer-rust/vim-racer'
Plug  'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Search and Navigation
Plug  'scrooloose/nerdtree'
Plug  'Shougo/unite.vim'
Plug  'Shougo/neomru.vim'
Plug  'Shougo/vimproc.vim', {'do' : 'make'}
Plug  'mileszs/ack.vim'

" Movement/
Plug  'easymotion/vim-easymotion'

" Git
Plug  'airblade/vim-gitgutter'
Plug  'tpope/vim-fugitive'

" Framework Plugs
Plug  'tpope/vim-rails'
Plug  'vim-scripts/ruby-matchit'

" Syntax Plugs
Plug  'rust-lang/rust.vim'
Plug  'slim-template/vim-slim'
Plug  'pangloss/vim-javascript'
Plug  'mattn/emmet-vim'
Plug  'othree/javascript-libraries-syntax.vim'
Plug  'w0rp/ale', { 'do': 'yarn global add prettier' }
Plug  'carlitux/deoplete-ternjs', { 'do': 'yarn global add tern' }
Plug  'fatih/vim-go'
Plug  'zchee/deoplete-go', { 'do': 'make' }
Plug  'stamblerre/gocode', { 'rtp': 'nvim', 'do': '~/.vim/plugged/gocode/nvim/symlink.sh' }
Plug  'mxw/vim-jsx'

" Display
Plug  'szw/vim-maximizer'

" Color Schemes
Plug  'mhartington/oceanic-next'
Plug  'w0ng/vim-hybrid'
Plug  'morhetz/gruvbox'
Plug  'phanviet/vim-monokai-pro'

call plug#end()

filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! CUSTOM SCRIPTS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" remove trailing whitespace
:au FocusLost,BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! PLUGIN CONFIGURATION
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" !! UNITE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call unite#custom#profile('default', 'context', {
            \ 'start_insert'      : 0,
            \ 'no_quit'           : 1,
            \ 'keep_focus'        : 1,
            \ 'force_redraw'      : 1,
	          \ 'direction'        : 'botright',
            \ 'no_empty'          : 1,
            \ 'toggle'            : 1,
            \ 'vertical_preview'  : 1,
            \ 'winheight'         : 20,
            \ 'prompt'            : '▸ ',
            \ 'prompt_focus'      : 1,
            \ 'candidate_icon'    : '  ▫ ',
            \ 'marked_icon'       : '  ▪ ',
            \ 'no_hide_icon'      : 1
        \ })

" Use ag for search
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
    let g:unite_source_rec_async_command =
        \ ['ag', '--follow', '--nocolor', '--nogroup',
        \  '--hidden', '-g', '']
endif

" Fuzzy file search
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
call unite#custom#source('line,file,file/new,buffer,file_rec,file_mru',
	\ 'matchers', 'matcher_fuzzy')

" Speed up NEOMRU
let g:neomru#do_validate = 0

" !! SLIM FILE DETECT
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufNewFile,BufRead *.slim set ft=slim
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endi

" !! DETECT ES6
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufRead,BufNewFile *.es6 set filetype=javascript

" !! DETECT EJS ( Express templates )
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufRead,BufNewFile *.ejs setf javascript.jsx


" !! Go specific always define
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au CursorHold *.go :GoInfo

" !! NERD TREE MAPPINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load NERDTree on startup
" autocmd vimenter * NERDTree

" !! VIM-WIKI MAPPINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vimwiki_list = [{'path': '~/Dropbox/VimWiki',
                       \ 'path_html': '~/Dropbox/vim_wiki_html/'}]

let g:vimwiki_default_mappings='0'

" !! EASYMOTION SETUP
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EasyMotion_do_mapping = 0 " Disable default mappings
" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1

" !! ACK VIM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use ag for text search
if executable('ag')
  let g:ackprg = 'ag --follow --nocolor --nogroup --hidden
                  \ --ignore-dir={log,dist,tmp,.git,tags,node_modules}'
endif
" Ack is same as Ack!
cnoreabbrev Ack Ack!

" !! VIM MAXIMISER
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:maximizer_set_default_mapping = 1

" !! GIT GUTTER
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0

" !! VIM TEST
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let test#strategy = "neoterm"

" !! VIMTERM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:neoterm_size = "15"
let g:neoterm_autoscroll = 1

" !! MUNDO
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable persistent undo so that undo history persists across vim sessions
set undofile
set undodir=~/.vim/undo

" !! DEOPLETE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use deoplete.
let g:deoplete#enable_at_startup = 1

" !! ALE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_fixers = { 'java': ['javac'], 'go': ['gofmt'], 'javascript': ['prettier', 'eslint'], 'sass': ['prettier', 'eslint'] }
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0

" !! RACER RUST
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" show the complete function definition (e.g. its arguments and return type)
" experimetnal completer feature
let g:racer_experimental_completer = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! COLOURSCHEME
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:java_highlight_functions = "true"
let g:gruvbox_contrast_dark = "hard"
let g:gruvbox_invert_selection = 0
let g:gruvbox_invert_selection = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! VIM GO
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:go_fmt_autosave = 0

syntax enable

if has("gui_running")
  set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  set guioptions-=r  "remove right-hand scroll bar
  set guioptions-=L  "remove left-hand scroll bar
  set guifont=Droid\ Sans\ Mono\ 13
elseif has('nvim')
  set termguicolors
  set guicursor=
  set background=dark

  " colorscheme OceanicNext
  colorscheme gruvbox
else
  color jellybeans
endif

" if has("syntax")
"   syntax on
" endif
