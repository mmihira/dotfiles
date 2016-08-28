runtime! debian.vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! BASE VIM SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set hidden      " Allow navigating to buffers without saving
set rnu         " Set relative numbering
set nu          " Set numbering
set number      " Ensure we see line numbers
set tabstop=2
set shiftwidth=2
set showcmd		  " Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase  " Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set hlsearch    " Highlight after search finished
"set smartindent " Auto detect indenting
set foldmethod=manual " Makes vim faster
set expandtab   " Make tab spaces
set cursorline  " Highligh the line the cursor is on
set hidden		  " Hide buffers when they are abandoned
set mouse=c		  " Disable the mouse
set backupdir=~/.tmp " Save swp and tmp files to a different place
set directory=~/.tmp " Save swp and tmp files to a different place
set ttyfast

filetype on
" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype. Needed for VUNDLE
filetype plugin indent on
" To ignore plugin indent changes, instead use:
"filetype plugin on

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

nnoremap <silent> <F4> :let @+=expand("%")<CR>

" Map line matching omnicomplete
inoremap <C-l> <C-x><C-l>

" !! LEADER REMAPS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"
" NERDTree
nnoremap <leader>nn :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>
" Reassign macro key
noremap <Leader>! q<CR>
nnoremap q <Nop>
" Remap exit
noremap <Leader>q :q<CR>
" Switch splits
noremap <Leader>m <C-w>w
" Fugitive Vim
noremap <Leader>gs :Gstatus <CR> <C-w>T
noremap <Leader>gd :Gdiff <CR>
" Remap cancel highlight
nnoremap <Leader>8 :noh<CR>
" Remap save
nnoremap <Leader>2 :w<CR>
" Remap paste from + buffer
nnoremap <Leader>= "+gP
" Gundo map
nnoremap <Leader>0 :GundoToggle <CR>
" Jump to anywhere you want with minimal keystrokes, with just one key binding." `s{char}{label}`
nmap s <Plug>(easymotion-bd-f)
" Remap copy one line to system buffer
nnoremap <Leader>cc V"+yyv <CR>
vnoremap <Leader>cc "+yyv <CR>
" Search for highlighted text in dir
vnoremap <Leader>cs "0y :Ack! <C-r>0
" Replace highlighted text buffer global
vnoremap <Leader>r "0y :%s/<C-r>0

:imap jj <Esc>
:cmap jj <Esc>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! CUSTOM COMMANDS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! Sfd set guifont=Droid\ Sans\ Mono\ 10
command! Sfl set guifont=Droid\ Sans\ Mono\ 13
command! Spwd cd %:p:h

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! BUNDLE SETUP
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

" let Vundle manage Vundle, required
Plugin  'gmarik/Vundle.vim'
Plugin  'scrooloose/nerdtree'
" Plugin 'Valloric/YouCompleteMe'
Plugin  'mileszs/ack.vim'
Plugin  'slim-template/vim-slim'
Plugin  'tpope/vim-fugitive'
Plugin  'Shougo/unite.vim'
Plugin  'Shougo/neomru.vim'
Plugin  'Shougo/vimproc.vim'
Plugin  'tpope/vim-surround'
Plugin  'tpope/vim-rails'
Plugin  'isRuslan/vim-es6'
Plugin  'vimwiki/vimwiki'
Plugin  'airblade/vim-gitgutter'
Plugin  'sjl/gundo.vim'
Plugin  'crusoexia/vim-javascript-lib'
Plugin  'pangloss/vim-javascript'
Plugin  'easymotion/vim-easymotion'
Plugin  'szw/vim-maximizer'

" Color Schemes
Plugin  'flazz/vim-colorschemes'
Plugin  'freeo/vim-kalisi'
Plugin  'altercation/vim-colors-solarized'

" All of your Plugins must be added before the following line
syntax enable
call vundle#end()            " required


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! CUSTOM SCRIPTS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:source ~/.vim/scripts/plugin/matchit.vim
:source ~/.vim/scripts/plugin/setcolors.vim

" save file on loss of focus
autocmd FocusLost * :wa
" remove trailing whitespace
autocmd FocusLost,BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif


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
	        \   'direction': 'botright',
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

" !! NERD TREE MAPPINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load NERDTree on startup
" autocmd vimenter * NERDTree


" !! VIM-WIKI MAPPINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vimwiki_list = [{'path': '~/Dropbox/vim_wiki',
                       \ 'path_html': '~/Dropbox/vim_wiki_html/'}]

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
                  \ --ignore-dir={log,tmp,.git,tags}'
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! COLOURSCHEME
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Font,Visual, etc..
" Set so we can highlight functions in java
let g:java_highlight_functions = "true"
let g:monokai_gui_italic = 1

"Default color scheme
set background=dark
if has("gui_running")
    color monokaiImproved
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
    set guifont=Droid\ Sans\ Mono\ 13
elseif has('nvim')
  set t_Co=256    " Override terminal colors
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
  colorscheme monokai-chris
else
    set t_Co=256    " Override terminal colors
    color jellybeans
endif

if has("syntax")
  syntax on
endif
