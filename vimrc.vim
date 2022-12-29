"Because fuck reaching up for the escape key
imap jf <Esc>
imap fj <Esc>

"Indentation. Also, tabs are spaces.
set tabstop=4
set softtabstop=4
set expandtab
set autoindent

"UI stuff
syntax enable
set hlsearch
set incsearch
set cursorline

"Persistant undo
set undofile
set undodir=~/.vim/undo//

" backups
set backup
set backupdir=~/.vim/backup//

"store swp files in the same place
set directory=~/.vim/swap//

"accept mouse events
set mouse=a

"line numbering
set number
set relativenumber

highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

"accept mouse events
set mouse=a

let &t_SI.="\e[5 q"
let &t_SR.="\e[4 q"
let &t_EI.="\e[1 q"

