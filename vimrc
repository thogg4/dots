" ----------------------------------------------------------------------------
"  Plugins
" ----------------------------------------------------------------------------
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'msanders/snipmate.vim'
"Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-rails'
Plugin 'vim-ruby/vim-ruby'
Plugin 'mileszs/ack.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'kchmck/vim-coffee-script'
Plugin 'altercation/vim-colors-solarized'
Plugin 'pangloss/vim-javascript'
Plugin 'slim-template/vim-slim'
Plugin 'groenewege/vim-less'
Plugin 'juvenn/mustache.vim'
Plugin 'flazz/vim-colorschemes'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'janko-m/vim-test'
Plugin 'elixir-editors/vim-elixir'
Plugin 'slashmili/alchemist.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'vimlab/split-term.vim'
Plugin 'ruanyl/vim-gh-line'

"Plugin 'file:///Users/tim/projects/vim-nav'

call vundle#end()
  

set noswapfile
filetype plugin indent on
filetype plugin on

" Make Vim remember cursor position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

let g:loaded_netrw = 1

" ----------------------------------------------------------------------------
"  Text Formatting
" ----------------------------------------------------------------------------
set autoindent             " automatic indent new lines
set smartindent            " be smart about it
inoremap # X<BS>#
set nowrap                 " do not wrap lines
set softtabstop=2          " yep, two
set shiftwidth=2           " ..
set tabstop=4
set expandtab              " expand tabs to spaces
set nosmarttab             " fuck tabs
set formatoptions+=n       " support for numbered/bullet lists
set textwidth=80           " wrap at 80 chars by default
set virtualedit=block      " allow virtual edit in visual block ..
syntax on
set autoread

" ----------------------------------------------------------------------------
" Persistent Undo
" Keep undo history across sessions, by storing in file.
" Only works all the time.
" ----------------------------------------------------------------------------
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ----------------------------------------------------------------------------
"  Remapping
" ----------------------------------------------------------------------------
" exit to normal mode with 'jj'
inoremap jj <ESC>


" reflow paragraph with Q in normal and visual mode
nnoremap Q gqap
vnoremap Q gq

" sane movement with wrap turned on
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

nmap <S-Up> 10k
vmap <S-Up> 10k
nmap <S-Down> 10j
vmap <S-Down> 10j

" ----------------------------------------------------------------------------
"  UI
" ----------------------------------------------------------------------------
set ruler                  " show the cursor position all the time
set noshowcmd              " don't display incomplete commands
set nolazyredraw           " turn off lazy redraw
set number                 " line numbers
set wildmenu               " turn on wild menu
set wildmode=list:longest,full
set ch=2                   " command line height
set backspace=2            " allow backspacing over everything in insert mode
"set whichwrap+=<,>,h,l,[,] " backspace and cursor keys wrap to
set shortmess=filtIoOA     " shorten messages
set report=0               " tell us about changes
set nostartofline          " don't jump to the start of line when scrolling
syntax enable
colorscheme blackhog
hi Normal guibg=NONE ctermbg=NONE " make background transparent
set mouse-=a
set pastetoggle=<Leader>p
set clipboard+=unnamedplus


" ----------------------------------------------------------------------------
" Visual Cues
" ----------------------------------------------------------------------------
set showmatch              " brackets/braces that is
set mat=5                  " duration to show matching brace (1/10 sec)
set incsearch              " do incremental searching
set laststatus=2           " always show the status line
"set ignorecase             " ignore case when searching
set nohlsearch             " don't highlight searches
set visualbell             " shut the fuck up
set t_vb=


" ---------------------------------------------------------------------------
"  Strip all trailing whitespace in file
" ---------------------------------------------------------------------------
function! StripWhitespace ()
    exec ':%s/ \+$//gc'
endfunction
map <Leader>s :call StripWhitespace ()<CR>


" ---------------------------------------------------------------------------
"  NERDTree
" ---------------------------------------------------------------------------
let g:NERDTreeDirArrows=0
nnoremap <silent> <C-N> :NERDTree<cr>


" ---------------------------------------------------------------------------
"  CTRL P
" ---------------------------------------------------------------------------
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40
let g:ctrlp_match_window = 'min:4,max:20,results=100'
let g:ctrlp_user_command = 'ag %s -l nocolor -g ""'
let g:ctrlp_use_caching = 0


" ---------------------------------------------------------------------------
"  Airline
" ---------------------------------------------------------------------------
set ttimeoutlen=10


" ---------------------------------------------------------------------------
"  Vim Test
" ---------------------------------------------------------------------------
let test#ruby#cucumber#options = '-r features/'
let test#strategy = 'neovim'


" ---------------------------------------------------------------------------
"  Syntastic
" ---------------------------------------------------------------------------
let g:syntastic_ruby_checkers = ['ruby', 'rubocop']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_always_populate_loc_list = 3
let g:syntastic_auto_loc_list = 2
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_highlighting = 0

" ---------------------------------------------------------------------------
" Splits
" ---------------------------------------------------------------------------
set splitbelow
set splitright

nnoremap <C-A> <C-W>
nnoremap <C-A>" :sp<cr>
nnoremap <silent> <C-A>: :vsp<cr>

let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-Right> <c-w>l
nnoremap <silent> <C-Left> <c-w>h
nnoremap <silent> <C-Up> <c-w>k
nnoremap <silent> <C-Down> <c-w>j

" ---------------------------------------------------------------------------
" Terminal
" ---------------------------------------------------------------------------
nnoremap <silent> <C-T> :VTerm<cr>
