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
set showcmd           " Show (partial) command in status line.
set showmatch         " Show matching brackets.
" set ignorecase      " Do case insensitive matching
set smartcase		      " Do smart case matching
set incsearch         " Incremental search
set hlsearch          " Highlight after search finished
"set smartindent      " Auto detect indenting
set expandtab         " Make tab spaces
set cursorline        " Highligh the line the cursor is on
set hidden            " Hide buffers when they are abandoned
set mouse=""          " Disable the mouse
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
set splitright        " Open vertical splits to the right
set updatetime=800

filetype off

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! KEY REMAPPING
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Telescope
nnoremap <C-k> <cmd>Telescope buffers<cr>
:command Lg Telescope live_grep
:command Ref Telescope lsp_references
:command Sym Telescope lsp_document_symbols symbols=function,method
:command Ghist 0Gclog

" Stop mistakingly causing text to lowercase
nnoremap q: <Nop>
nnoremap q: <Nop>
" nnoremap Vu <Nop>
vnoremap u <Nop>

" Map line matching omnicomplete
inoremap <C-l> <C-x><C-o>
" JJ
imap jj <Esc>
cmap jj <Esc>

" Hold down alt+shift+>/< to change width
" nmap <Esc>> :vertical res +1<Enter>
" nmap <Esc>< :vertical res -1<Enter>

" !! LEADER REMAPS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"
" NERDTree
nnoremap <leader>nn :Neotree position=float toggle=true reveal_force_cwd=true<CR>
" Reassign macro key
nnoremap Q q
nnoremap q <Nop>
" Remap exit
noremap <Leader>q :q<CR>
tnoremap ;;q <C-\><C-n>:q<CR>
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
nnoremap <Leader>r :Run <CR>
" Copy file path to buffer
nnoremap <silent> <leader>cp :let @+ = expand('%:p')<CR>
" Ale fix
nnoremap <Leader>lf :ALEFix<CR>
" Floaterm
nnoremap <Leader>mm :StartMainFloat<CR>
tnoremap <Leader>mm <C-\><C-n>:FloatermToggle<CR>
tnoremap <silent> <F9> <C-\><C-n>:FloaTermToggleLayout<CR>
tnoremap <leader>qq <C-\><C-n><CR>


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

""""" GoLang specific maps """""
autocmd FileType go setlocal tabstop=4
autocmd FileType go setlocal shiftwidth=4
au FileType go noremap <Leader>gi :GoImports <CR>
au FileType go noremap <Leader>gf :GoFillStruct <CR>

""""" Coc Autocommands """""
autocmd ColorScheme highlight CocErrorHighlight ctermfg=DarkGrey guifg=#FAE2E2
autocmd ColorScheme highlight CocWarningHighlight ctermfg=Red  guifg=#FBE6A2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! CUSTOM COMMANDS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! Spwd cd %:p:h
command! Vimfile :e ~/.config/nvim/init.vim

function! GitStatus()
    :Neotree position=float toggle=true source=git_status
endfunction
command! Gitstatus :call GitStatus()

function! Run()
  :w
  let combined = [join(['~/bin/nvim_run.sh ', expand('%:p')])]
  if floaterm#terminal#get_bufnr("main_term")
    :FloatermToggle main_term
  else
    :FloatermNew! --wintype=float --name=main_term
  end

  let bufnr = floaterm#terminal#get_bufnr("main_term")
  call floaterm#terminal#send(bufnr, combined)
endfunction
command! Run :call Run()

let FLOAT_TERM_HEIGHT = 0.8
" For staring a floaterm
function! StartMainFloat()
if floaterm#terminal#get_bufnr("main_term")
  :FloatermToggle main_term
else
  :FloatermNew! --wintype=float --name=main_term --width=0.8 --height=0.8
end
endfunction
command! StartMainFloat :call StartMainFloat()

" Toggle floaterm layout between float and vsplit right
function! FloaTermToggleLayout()
  let bufnr = floaterm#terminal#get_bufnr("main_term")
  let wintype = floaterm#config#get(bufnr, 'wintype')
  if wintype == 'float'
    :FloatermUpdate --wintype=vsplit --position=botright --width=0.4 <CR>
  else
    :FloatermUpdate --wintype=float --position=center --width=0.8 <CR>
  end
  :stopinsert
endfunction
command! FloaTermToggleLayout :call FloaTermToggleLayout()

" Command to do test in floaterm
function! CustomFloatermTest(cmd)
  if floaterm#terminal#get_bufnr("main_term")
    :FloatermToggle main_term
  else
    :FloatermNew! --wintype=float --name=main_term --width=0.8 --height=FLOAT_TERM_HEIGHT
  end
  let bufnr = floaterm#terminal#get_bufnr("main_term")
  call floaterm#terminal#send(bufnr, [a:cmd])
  :stopinsert
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! PluginSetup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

" Builds and testing
Plug  'janko-m/vim-test'

" Terminal
Plug 'voldikss/vim-floaterm'

" Code Helpers
" Plug  'rstacruz/vim-closer'
Plug  'tpope/vim-surround'
Plug  'tpope/vim-repeat'
Plug  'tpope/vim-commentary'
Plug  'simnalamburt/vim-mundo'
Plug  'SirVer/ultisnips'

" Search and Navigation
Plug  'nvim-neo-tree/neo-tree.nvim'
Plug  'kyazdani42/nvim-web-devicons' "Required: install a nerd-font
Plug  'MunifTanjim/nui.nvim'
Plug  'mileszs/ack.vim'
Plug  'https://github.com/alok/notational-fzf-vim' " Need ripgrep for this
Plug  'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug  'kwkarlwang/bufjump.nvim'
Plug  'nvim-lua/popup.nvim'
Plug  'nvim-lua/plenary.nvim'
Plug  'nvim-telescope/telescope.nvim'
Plug  'nvim-telescope/telescope-fzy-native.nvim'
Plug  'neovim/nvim-lspconfig'
Plug  'hrsh7th/cmp-nvim-lsp'
Plug  'hrsh7th/cmp-buffer'
Plug  'hrsh7th/cmp-path'
Plug  'hrsh7th/cmp-cmdline'
Plug  'hrsh7th/nvim-cmp'
Plug  'hrsh7th/cmp-nvim-lsp-signature-help'
Plug  'folke/trouble.nvim'

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
Plug  'udalov/kotlin-vim'
Plug  'mechatroner/rainbow_csv'

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
let g:test#custom_strategies = {'custom_floaterm': function('CustomFloatermTest')}
let g:test#strategy = 'custom_floaterm'
let test#go#go#options = "-v"
let test#go#gotest#options = "-v"

" !! FLOATERM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:floaterm_autoclose = 0

" !! MUNDO
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable persistent undo so that undo history persists across vim sessions
set undofile
set undodir=~/.vim/undo

" !! ALE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_fixers = { 'sql': ['sqlformat'], 'go': ['gofmt'], 'javascript': ['prettier', 'eslint'], 'scss': ['prettier', 'eslint'], 'rust': ['rustc'], 'json': ['prettier'], 'elixir': ['mix_format'], 'typescript': ['prettier', 'eslint'], 'xml':['xmllint'] }
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0
let g:ale_disable_lsp = 1

" !! RACER RUST
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" show the complete function definition (e.g. its arguments and return type)
" experimetnal completer feature
let g:racer_experimental_completer = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! COLOURSCHEME
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! NOTATIONAL
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:nv_search_paths = [ '/home/mihira/Dropbox/notes', '/home/mihira/Dropbox/Knowledge', '~/notes', '~/c/dotfiles/vim_cheatsheet.md']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! VIM GO
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:go_imports_autosave = 0
let g:go_fmt_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:go_code_completion_enabled = 0
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
let g:go_doc_popup_window = 1
let g:go_def_mapping_enabled = 0
" Go specific always define
" au CursorHold *.go :GoInfo

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! Enhanced Jumps
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EnhancedJumps_CaptureJumpMessages = 0
let g:EnhancedJumps_no_mappings = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! ULTI SNIPS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" !! TELESCOPE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set completeopt=menu,menuone,noselect

lua <<EOF
  require('telescope').setup{
        defaults = {
          initial_mode = 'normal',
        },
      }

  local cmp = require'cmp'
  cmp.setup({
    snippet = {
      expand = function(args)
         vim.fn["UltiSnips#Anon"](args.body)
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'ultisnips' },
    }, {
      { name = 'buffer', keyword_length = 3 },
    }, {
      { name = 'nvim_lsp_signature_help' },
    }),
    experimental = {
      native_menu = false,
      ghost_text = true,
    },
  })

  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  local nvim_lsp = require('lspconfig')
  nvim_lsp.gopls.setup{}
  nvim_lsp.tsserver.setup{}
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'ci', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    -- buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    -- Use :Ref for below
    -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    -- buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    -- buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    -- buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  end

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = { 'gopls' }
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 150,
      }
    }
  end

  -- Popup for dianostic
  -- vim.o.updatetime = 250
  -- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
  -- Hide the dianostic virtual text
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics,
      {
        virtual_text = false,
        signs = true,
        update_in_insert = false,
        underline = true,
      }
    )

  -- Setup Trouble
  require("trouble").setup {
    icons = false,
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    indent_lines = false, -- add an indent guide below the fold icons
    signs = {
        -- icons / text used for a diagnostic
        error = "error",
        warning = "warn",
        hint = "hint",
        information = "info"
    },
  }

  require'nvim-web-devicons'.setup {
   override = {
    zsh = {
      icon = "",
      color = "#428850",
      cterm_color = "65",
      name = "Zsh"
    }
   };
   default = true;
  }

  require("neo-tree").setup({
    window = {
      mappings = {
        ["v"] = "open_vsplit",
        ["o"] = "open"
      }
    },
    filesystem = {
      filterd_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      }
    }
  })

  require("bufjump").setup({
      forward = "<C-p>",
      backward = "<C-n>",
      on_success = nil,
  })

EOF

if has("gui_running")
  set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  set guioptions-=r  "remove right-hand scroll bar
  set guioptions-=L  "remove left-hand scroll bar
  set guifont=Droid\ Sans\ Mono\ 13
elseif has('nvim')
  set termguicolors
  set guicursor=
  let g:gruvbox_invert_selection = 0
  let g:gruvbox_contrast_dark='medium'
  colorscheme gruvbox
  " colorscheme OceanicNext
  " set background=light
  " colorscheme solarized8_high
else
  color jellybeans
endif
