set nocompatible              " be iMproved, required
filetype off                  " required

" Enable vundle to load plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Bundle 'majutsushi/tagbar'
Bundle 'ervandew/supertab'
Bundle 'Valloric/YouCompleteMe'
Bundle 'kien/ctrlp.vim'
Bundle 'nanotech/jellybeans.vim'
Bundle 'xolox/vim-misc'
Bundle 'bling/vim-airline'
Bundle 'scrooloose/nerdtree'
Bundle 'airblade/vim-gitgutter'
Bundle 'vim-scripts/scons.vim'
Bundle 'Chiel92/vim-autoformat'
Bundle 'vim-scripts/csv.vim'
Bundle 'sjl/splice.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'seletskiy/ashium'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'stephpy/vim-yaml'
Bundle 'ingydotnet/yaml-vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required

syntax on
filetype on
filetype plugin on
filetype indent on

" Spell checking
"set spell spelllang=en_us

" Tab key configuration (use 3 spaces)
set tabstop=3
set shiftwidth=3
set softtabstop=3
set expandtab       " Use spaces instead of tabs
set autoindent
set copyindent

" Search options
set smartcase
set showmatch
set hlsearch
set incsearch

" Allow buffer traversal without saving
set hidden

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" keep 4 lines off the edges of the screen when scrolling
set scrolloff=8

" enable using the mouse if terminal emulator supports it
set mouse=a
if has("mouse_sgr")
   set ttymouse=sgr
else
   set ttymouse=xterm2
end

set history=1000                " remember more commands and search history
set undolevels=1000             " use many muchos levels of undo
set visualbell                  " don't beep
set noerrorbells                " don't beep
set cursorline                  " underline the current line, for quick orientation

" enable xterm colors
set term=xterm-256color
highlight PmenuSel ctermfg=black ctermbg=cyan
highlight Pmenu ctermfg=green ctermbg=black

" Setup vim temp and swap directory to a common location to keep swaps from
" littering the source tree.
set directory=~/.vim/tmp

" Swap colon and semicolon
nore ; :
nore , ;

" Set hybrid line numbers
set number
set rnu

" Jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

augroup NO_CURSOR_MOVE_ON_FOCUS
   au!
   au FocusLost * let g:oldmouse=&mouse | set mouse=
   au FocusGained * if exists('g:oldmouse') | let &mouse=g:oldmouse | unlet g:oldmouse | endif
augroup END

" ash color config
augroup syntax_hacks
   au!
   au FileType diff syn match DiffComment "^#.*"
   au FileType diff syn match DiffCommentIgnore "^###.*"
   au FileType diff call g:ApplySyntaxForDiffComments()
augroup end


fun! g:ApplySyntaxForDiffComments()
   if &background == 'light'
      hi DiffCommentIgnore ctermfg=249 ctermbg=none
      hi DiffComment ctermfg=16 ctermbg=254
   else
      hi DiffCommentIgnore ctermfg=249 ctermbg=none
      hi DiffComment ctermfg=15 ctermbg=237
   endif
endfun

" Equalize splits by default
autocmd VimResized * wincmd =

" Colors
colorscheme jellybeans

" Map leader key
let mapleader = ","

" Filter out binary files
set wildignore+=*.o,*.obj,*.os,*.lo,*.Plo,.*.pyc,*.gdca,*.gcno,git,depend.*,*.built,CMakeFiles
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|depend.*|*.built|CMakeFiles|bsp_zynq-linux-cortexa9|working)$',
  \ 'file': '\v(\.(exe|a|so|dll|o|os|lo|Plo|obj|pyc|gcno|html).*$)|(.*_main$)',
  \ }
let g:ctrlp_working_path_mode = 'r'
"let g:ctrlp_by_filename = 1
let g:ctrlp_root_markers = ['.arkyd_root']
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_max_files = 0

" Toggle whitespace with ,w
set listchars=tab:>-,trail:?,eol:$
nmap <silent> <leader>w :set nolist!<CR>

" Toggle line numbers with ,n
nmap <silent> <leader>n :set nornu!<CR>

" Close buffers with nerdtree easily
nnoremap <leader>q :bp<cr>:bd #<cr>
let NERDTreeIgnore = ['\.pyc$']

" Navigate between buffers using arrow keys
nnoremap <C-S-Left> :bp<cr>
nnoremap <C-S-Right> :bn<cr>

" Enable indent guides by default
let g:indent_guides_enable_on_vim_startup = 1

" Indent guides toggle
nmap <silent> <Leader>ig <Plug>IndentGuidesToggle

" Toggle paste mode with F3
set pastetoggle=<F3>

" Kill all trailing whitespace if F5 is pressed
nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

" Press F4 to toggle highlighting on/off, and show current value.
noremap <F4> :set hlsearch! hlsearch?<CR>

" Nerdtree
map <C-n> :NERDTreeToggle<CR>

" Airline
let g:airline#extensions#tabline#enabled = 1
set laststatus=2 " Don't know why this helps to always have a status bar but it does

" Tagbar stuff
nmap <F8> :TagbarToggle<CR>

" Auto-complete
let g:ycm_confirm_extra_conf = 0
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_filetype_whitelist = { 'c': 1, 'cpp': 1, 'python': 1, 'bash': 1 }
set completeopt-=preview
nnoremap <leader>d :YcmCompleter GoTo<CR>
"" turn off YCM
nnoremap <leader>y :let g:ycm_auto_trigger=0<CR>
"" turn on YCM
nnoremap <leader>Y :let g:ycm_auto_trigger=1<CR>

let g:ycm_server_use_vim_stdout = 1
let g:ycm_server_log_level = 'debug'

" Gitgutter
let g:gitgutter_enabled = 1
let g:gitgutter_realtime = 1
nnoremap <leader>gg :GitGutterLineHighlightsToggle<CR>

" Autoformat
let g:formatprg_args_c = "--mode=c --style=\"k&r\" -pcHs3"

" 80 column
hi ColorColumn ctermbg=235
set colorcolumn=80
