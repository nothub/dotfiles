" TODO: make categories
set nocompatible
set nostartofline

" automatically write files when changing when multiple files open
set autowrite

" ui
set number
set ruler
set showcmd
set showmode
set showmatch
set visualbell

" wrapping
set nowrap
set showbreak=+++
set textwidth=80

" undo
set undolevels=1000

" search
set smartcase
set ignorecase
set incsearch
set wrapscan
set hlsearch

" indent
set smartindent
set autoindent
set smarttab
set expandtab " replace tabs with spaces automatically
set tabstop=2
set softtabstop=2
set shiftwidth=2

" trailing spaces are errors
match ErrorMsg '\s\+$'

" line numbers
set number
set relativenumber

" start at last sessions position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" functions keys
set pastetoggle=<F3>
map <F4> :set list!<CR>
map <F5> :set cursorline!<CR>

" wrap lines on cursor movement
set whichwrap+=<,>,h,l,[,]
set backspace=indent,eol,start

" mousewheel scrolling
set mouse=a
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

" command history
set history=200
