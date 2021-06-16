" ui
set number
set ruler
set showmode
set showmatch
set visualbell

" wrapping
set nowrap
set showbreak=+++
set textwidth=120

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
set expandtab
set softtabstop=4
set shiftwidth=4

" trailing spaces are errors
match ErrorMsg '\s\+$'

" disable relative line numbers
set norelativenumber

" start at last sessions position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" functions keys
map <F4> :set list!<CR>
map <F5> :set cursorline!<CR>

" wrap lines on cursor movement
set whichwrap+=<,>,h,l,[,]
set backspace=indent,eol,start

" mousewheel scrolling
set mouse=a
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>
