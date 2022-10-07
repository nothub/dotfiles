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
"set relativenumber

" show context around cursor
set scrolloff=4

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

" Start NERDTree. If a file is specified, move the cursor to its window.
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif

" Start NERDTree, unless a file or session is specified, eg. vim -S session_file.vim.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') && v:this_session == '' | NERDTree | endif

" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
