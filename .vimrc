set nocompatible

set ruler
set laststatus=2

execute pathogen#infect()

syntax enable
colorscheme solarized
let hour = strftime("%H")
if 6 <= hour && hour <= 17
  set background=light
else
  set background=dark
endif

set expandtab
set sw=4
set tabstop=4
set smarttab

" two character tabs for ruby..
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType eruby setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2

set hlsearch
set incsearch
set smartcase
set ignorecase

set autoindent

set relativenumber
set number

set textwidth=80
set colorcolumn=+1
set cursorline

:highlight ExtraWhitespace ctermbg=7
:match ExtraWhitespace /\s\+$/


let g:indentLine_faster = 1

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
