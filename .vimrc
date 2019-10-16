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

" Settings for coc-vim
set cmdheight=2
set updatetime=300
set shortmess+=c

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! KEY REMAPPING
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Unite
nnoremap <C-k> :CocList --normal buffers <CR>
nnoremap <C-l> :CocList -I --normal grep <CR>
" Quick Buffer Access
" nnoremap <C-i> :b# <CR>
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
nmap <leader>s <Plug>(easymotion-bd-f)

" Hold down alt+shift+>/< to change width
" nmap <Esc>> :vertical res +1<Enter>
" nmap <Esc>< :vertical res -1<Enter>

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
tnoremap ;;a <C-\><C-n>
" Fugitive Vim
noremap <Leader>gs :Gstatus <CR> <C-w>T
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

""""" Python specific maps """""
" Pry
autocmd FileType python command! Pry :normal i import code; code.interact(local=dict(globals(), **locals()))<Esc>^

""""" Javascript specific maps """""
" For my common react-redux-saga filestructure
" Go to src/action/types.js
autocmd FileType javascript,jsx,scss,css,json nmap <leader>gt :e./src/actions/types.js<CR>
" Go to actions in NERDTree
autocmd FileType javascript,jsx,scss,css,json nmap <leader>ga :NERDTreeFind src/actions<CR>
" Go to reducers in NERDTree
autocmd FileType javascript,jsx,scss,css,json nmap <leader>gr :NERDTreeFind src/reducers<CR>
" Go to features in NERDTree
autocmd FileType javascript,jsx,scss,css,json nmap <leader>gf :NERDTreeFind src/features<CR>
" Go to sagas in NERDTree
autocmd FileType javascript,jsx,scss,css,json nmap <leader>gs :NERDTreeFind src/sagas<CR>
" Go to Implementation
autocmd FileType javascript,js,jsx,tss nmap <silent> <leader>gi <Plug>(coc-implementation)
autocmd FileType javascript,js,jsx,tss nmap <silent> <leader>gd <Plug>(coc-definition)

""""" GoLang specific maps """""
autocmd FileType go setlocal tabstop=4
autocmd FileType go setlocal shiftwidth=4
au FileType go noremap <Leader>gd :GoDef <CR>
au FileType go noremap <Leader>gi :GoInfo <CR>
au FileType go noremap <Leader>gl :GoDecls <CR>
au FileType go noremap <Leader>dd :GoDoc <CR>
au FileType go noremap <Leader>gf :GoFillStruct <CR>
au FileType go noremap <Leader>ge :GoIfErr <CR>

""""" Coc Autocommands """""
autocmd ColorScheme highlight CocErrorHighlight ctermfg=DarkGrey guifg=#FAE2E2
autocmd ColorScheme highlight CocWarningHighlight ctermfg=Red  guifg=#FBE6A2

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

command! Tmin :res -20

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
" :CocInstall coc-lists
" :CocInstall coc-json
" :CocInstall coc-tsserver
Plug  'neoclide/coc.nvim', {'branch': 'release' }
Plug  'SirVer/ultisnips'
" To get this working go the ~/.vim/plugged/vim-javacomplete2/libs/ and mvn compile

" Search and Navigation
Plug  'scrooloose/nerdtree'
Plug  'mileszs/ack.vim'
Plug  'https://github.com/alok/notational-fzf-vim' " Need ripgrep for this
Plug  'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug  'junegunn/vim-peekaboo'

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
Plug  'fatih/vim-go'
Plug  'MaxMEllon/vim-jsx-pretty'
Plug  'elixir-editors/vim-elixir'
Plug  'leafgarland/typescript-vim'

" Display
Plug  'szw/vim-maximizer'
Plug   'itchyny/lightline.vim'

" Color Schemes
Plug  'mhartington/oceanic-next'
Plug  'w0ng/vim-hybrid'
Plug  'morhetz/gruvbox'
Plug  'phanviet/vim-monokai-pro'
Plug  'lifepillar/vim-solarized8'

call plug#end()

filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! CUSTOM SCRIPTS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" remove trailing whitespace
:au FocusLost,BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

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

" !! VIM JSX
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" temporary fix for JSX: https://github.com/pangloss/vim-javascript/issues/955#issuecomment-356350901
let g:jsx_ext_required = 0
let g:javascript_plugin_flow = 1

" !! NERD TREE MAPPINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load NERDTree on startup
" autocmd vimenter * NERDTree

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
let test#go#go#options = "-v"
let test#go#gotest#options = "-v"

" !! NEOTERM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:neoterm_size = "15"
let g:neoterm_autoscroll = 1

" !! MUNDO
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable persistent undo so that undo history persists across vim sessions
set undofile
set undodir=~/.vim/undo

" !! ALE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_fixers = { 'go': ['gofmt'], 'javascript': ['prettier', 'eslint'], 'scss': ['prettier', 'eslint'], 'rust': ['rustc'], 'json': ['prettier'], 'elixir': ['mix_format'], 'typescript': ['prettier', 'eslint'] }
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
let g:gruvbox_contrast_dark = "hard"
let g:gruvbox_invert_selection = 0
let g:gruvbox_invert_selection = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! NOTATIONAL
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:nv_search_paths = ['/home/mihira/Dropbox/notes', '/home/mihira/Dropbox/Knowledge']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! VIM GO
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:go_fmt_autosave = 0
let g:go_code_completion_enabled = 0
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
let g:go_doc_popup_window = 1

" Go specific always define
" au CursorHold *.go :GoInfo

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! ULTI SNIPS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']

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
  colorscheme gruvbox
  " colorscheme OceanicNext
  " set background=light
  " colorscheme solarized8_high
else
  color jellybeans
endif

highlight CocErrorHighlight ctermfg=DarkGrey guifg=#735DD0
highlight CocErrorSign ctermfg=DarkGrey guifg=#EC4C47
highlight CocWarningHighlight ctermfg=Red  guifg=#FBE6A2

" if has("syntax")
"   syntax on
" endif
