" Enable filetype plugins and indentation
filetype plugin on
filetype indent on

" Turn on syntax highlighting
syntax on

" Set backspace to work intuitively
set backspace=indent,eol,start

" Enable line numbers
set number
" set relativenumber     " Uncomment if you want relative line numbers

" Use 2 spaces for indentation
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent

" Highlight trailing whitespace
autocmd BufRead,BufNewFile * match Error /\s\+$/

" Highlight current line
set cursorline

" Show matching brackets
set showmatch

" Enable mouse
set mouse=a

" Enable clipboard support
set clipboard=unnamedplus

" Enable syntax highlighting
syntax on

" Enable true color support (24-bit colors)
set termguicolors

" Set colorscheme
colorscheme desert " or something like elflord, peachpuff, etc.
