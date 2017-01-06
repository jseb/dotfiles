set nocompatible

set ruler
set laststatus=2

set mouse=a

execute pathogen#infect()

syntax enable

set expandtab
set sw=4
set tabstop=4
set smarttab

" two character tabs for ruby..
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType eruby setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2

" two character tabs for javascript..
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2

set hlsearch
set incsearch
set smartcase
set ignorecase

set autoindent

set relativenumber
set number

" enables line numbering in the file browser
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'
let g:netrw_liststyle=3
let g:netrw_browse_split=2

" sane regexes
nnoremap / /\v
vnoremap / /\v

set timeoutlen=1000 ttimeoutlen=0
ino <C-C> <Esc>

set colorcolumn=+1
set cursorline

autocmd InsertEnter * highlight  CursorLine cterm=None
autocmd InsertLeave * highlight  CursorLine cterm=underline

highlight ExtraWhitespace ctermbg=3
call matchadd('ExtraWhitespace', '\s\+$\|\t', 11)

highlight OverLength ctermbg=lightgrey
call matchadd('OverLength', '\%>80v.\+')

let g:indentLine_faster = 1
" set statusline+=%F

" Save your swp files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
  set directory=./.vim-swap//
  set directory+=~/.vim/swap//
  set directory+=~/tmp//
  set directory+=.
