" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
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
set smartindent " Auto detect indenting
set expandtab   " Make tab spaces
set cursorline  " Highligh the line the cursor is on
"set autowrite		" Automatically save before commands like :next and :make
set hidden		  " Hide buffers when they are abandoned
set mouse=c		  " Disable the mouse
set backupdir=~/.tmp " Save swp and tmp files to a different place
set directory=~/.tmp " Save swp and tmp files to a different place

filetype on
" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype. Needed for VUNDLE
filetype plugin indent on
" To ignore plugin indent changes, instead use:
"filetype plugin on

" Font,Visual, etc..
" Set so we can highlight functions in java
let g:java_highlight_functions = "true"

""Default color scheme
set background=dark
if has("gui_running")
    color MDark
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
    set guifont=Droid\ Sans\ Mono\ 13
else
    "color distinguished
    ":colorscheme desertink
    "colorscheme desert256
    set t_Co=256    " Override terminal colors
    color jellybeans
endif


" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

if has("syntax")
  syntax on
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! KEY REMAPPING
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader = "\<Space>"

" NERDTree
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

" Unite
nnoremap <C-l> :Unite file file_rec/async file_mru <CR>
nnoremap <C-k> :Unite buffer<CR>

" Quick Buffer Access
nnoremap <C-i> :b# <CR>
nnoremap <C-o> :bnext<CR>

" Reassign Macro
noremap <Leader>q q
nnoremap q <Nop> 

" Stop mistakingly causing text to lowercase
nnoremap q: <Nop>
"nnoremap Vu <Nop>
vnoremap u <Nop>

" Switch splits 
noremap <Leader>m <C-w>w

" Fugitive Vim
noremap <Leader>gs :Gstatus <CR> <C-w>T
noremap <Leader>gd :Gdiff <CR>

:imap jj <Esc>
:cmap jj <Esc>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! CUSTOM COMMANDS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command Sfd set guifont=Droid\ Sans\ Mono\ 10
command Sfl set guifont=Droid\ Sans\ Mono\ 13


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
Plugin 'gmarik/Vundle.vim'
Plugin 'scrooloose/nerdtree'
" Plugin 'Valloric/YouCompleteMe'
Plugin 'mileszs/ack.vim'
Plugin 'slim-template/vim-slim'
Plugin  'tpope/vim-fugitive'
Plugin  'Shougo/unite.vim'
Plugin  'Shougo/neomru.vim'
Plugin  'Shougo/vimproc.vim'
Plugin  'tpope/vim-surround'
Plugin  'tpope/vim-rails'
Plugin  'isRuslan/vim-es6'
Plugin  'vimwiki/vimwiki'
Plugin  'flazz/vim-colorschemes'
Plugin  'airblade/vim-gitgutter'


" All of your Plugins must be added before the following line
syntax enable
call vundle#end()            " required


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! CUSTOM SCRIPTS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:source ~/.vim/scripts/plugin/matchit.vim
:source ~/.vim/scripts/plugin/setcolors.vim


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
