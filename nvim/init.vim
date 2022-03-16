" ----------------------------------------------------------------------------
"  Plugins
" ----------------------------------------------------------------------------
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'msanders/snipmate.vim'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-rails'
Plugin 'vim-ruby/vim-ruby'
Plugin 'mileszs/ack.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'kchmck/vim-coffee-script'
Plugin 'pangloss/vim-javascript'
Plugin 'slim-template/vim-slim'
Plugin 'groenewege/vim-less'
Plugin 'juvenn/mustache.vim'
Plugin 'flazz/vim-colorschemes'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

Plugin 'tpope/vim-fugitive'

Plugin 'janko-m/vim-test'
Plugin 'kassio/neoterm'

Plugin 'elixir-editors/vim-elixir'
Plugin 'slashmili/alchemist.vim'
Plugin 'vimlab/split-term.vim'
Plugin 'ruanyl/vim-gh-line'
Plugin 'junegunn/fzf', { 'rtp': '/opt/homebrew/opt/fzf' }
Plugin 'junegunn/fzf.vim'
Plugin 'tpope/vim-eunuch'
Plugin 'majutsushi/tagbar'
call vundle#end()

set noswapfile
filetype plugin indent on
filetype plugin on

" Make Vim remember cursor position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" ----------------------------------------------------------------------------
"  Ale
" ----------------------------------------------------------------------------
let g:ale_linters = {
      \  'javascript': ['standard']
      \}

let g:ale_fixers = {
      \  'javascript': ['standard']
      \}

" ----------------------------------------------------------------------------
"  Airline
" ----------------------------------------------------------------------------
let g:airline_section_b = ''
set ttimeoutlen=10
let g:airline_theme = 'wombat'

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
set nosmarttab             " no tabs
set formatoptions+=n       " support for numbered/bullet lists
set textwidth=120          " wrap at 80 chars by default
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
nmap <S-Down> 10j

vmap <S-Up> 10k
vmap <S-Down> 10j

imap <S-Up> <Esc>10ki
imap <S-Down> <Esc>10ji


" ----------------------------------------------------------------------------
" Debuggers
" ----------------------------------------------------------------------------

imap <silent> <Leader>b <Esc>obinding.pry<Esc>:w<CR>
nmap <silent> <Leader>b obinding.pry<Esc>:w<CR>

function! ClearDebuggers ()
  exec ':%s/binding.pry//gi'
endfunction
nmap <silent> <Leader>B :call ClearDebuggers ()<CR>


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
"set ignorecase            " ignore case when searching
set nohlsearch             " don't highlight searches
set visualbell             " shut up
set t_vb=


" ---------------------------------------------------------------------------
"  Strip all trailing whitespace in file
" ---------------------------------------------------------------------------
function! StripWhitespace ()
    exec ':%s/ \+$//gc'
endfunction
map <Leader>s :call StripWhitespace ()<CR>


" ---------------------------------------------------------------------------
"  FZF
" ---------------------------------------------------------------------------
set rtp+=/opt/homebrew/opt/fzf

function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

command! ProjectFiles execute 'Files' s:find_git_root()

nnoremap <C-P> :ProjectFiles<CR>
let $FZF_DEFAULT_COMMAND = 'ag --hidden -g ""'
let g:fzf_layout = { 'window': { 'width': 1, 'height': 0.5, 'relative': v:false, 'yoffset': 0.9 } }

" ---------------------------------------------------------------------------
"  Vim Test
" ---------------------------------------------------------------------------
let test#ruby#cucumber#options = '-r features/'
let test#strategy = 'neoterm'

nmap <silent> <Leader>t :TestNearest<CR>
nmap <silent> <Leader>T :TestFile<CR>
nmap <silent> <Leader>l :TestLast<CR>

" ---------------------------------------------------------------------------
"  Neoterm
" ---------------------------------------------------------------------------
let g:neoterm_shell = '$SHELL -l' " use the login shell
let g:neoterm_default_mod = 'belowright' " open the split below and to the right
let g:neoterm_autoscroll = 1      " autoscroll to the bottom
let g:neoterm_fixedsize = 1       " fixed size. The autosizing was wonky for me
let g:neoterm_keep_term_open = 0  " when buffer closes, exit the terminal too.

tnoremap <Esc> <C-\><C-N>

nnoremap <Leader>c :TcloseAll<CR>


" ---------------------------------------------------------------------------
"  Syntastic
" ---------------------------------------------------------------------------
let g:syntastic_ruby_checkers = ['ruby', 'reek']
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
nnoremap <C-Right> <c-w>l
nnoremap <C-Left> <c-w>h
nnoremap <silent> <C-Up> <c-w>k
nnoremap <silent> <C-Down> <c-w>j

" ---------------------------------------------------------------------------
" Terminal
" ---------------------------------------------------------------------------
nnoremap <silent> <C-T> :VTerm<cr>
