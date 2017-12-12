set nocompatible              " be iMproved, required
filetype off                  " required

" Enable vundle to load plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Bundle 'google/vim-maktaba'
Bundle 'majutsushi/tagbar'
Bundle 'ervandew/supertab'
Bundle 'Valloric/YouCompleteMe'
Bundle 'kien/ctrlp.vim'
Bundle 'nanotech/jellybeans.vim'
Bundle 'xolox/vim-misc'
Bundle 'scrooloose/nerdtree'
Bundle 'airblade/vim-gitgutter'
Bundle 'vim-scripts/scons.vim'
Bundle 'Chiel92/vim-autoformat'
Bundle 'vim-scripts/csv.vim'
Bundle 'sjl/splice.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'stephpy/vim-yaml'
Bundle 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'suan/vim-instant-markdown'
Bundle 'bazelbuild/vim-bazel'

" All of your Plugins must be added before the following line
call vundle#end()            " required

syntax on
filetype on
filetype plugin on
filetype indent on

" scons syntax
au BufNewFile,BufRead,BufReadPost sconstruct set syntax=scons
au BufNewFile,BufRead,BufReadPost sconscript set syntax=scons
au BufNewFile,BufRead,BufReadPost SConstruct set syntax=scons
au BufNewFile,BufRead,BufReadPost SConscript set syntax=scons

" Spell checking
set spell spelllang=en_us
au BufRead,BufNewFile *.md setlocal spell
au BufRead,BufNewFile *.markdown setlocal spell

" Tab key configuration (use 2 spaces)
set tabstop=2
set shiftwidth=2
set softtabstop=2
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
set modeline

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
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|depend.*|*.built|CMakeFiles)$',
  \ 'file': '\v(\.(exe|a|so|dll|o|os|lo|Plo|obj|pyc|gcno|html).*$)|(.*_main$)',
  \ }
let g:ctrlp_working_path_mode = 'r'
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_max_files = 0

" Toggle whitespace with ,w
set listchars=tab:>-,trail:?,eol:$
nmap <silent> <leader>w :set nolist!<CR>
nmap <silent> <leader>W :set diffopt+=iwhite<CR>

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
let g:ycm_show_diagnostics_ui = 1
nnoremap <leader>d :YcmCompleter GoTo<CR>
"" turn off YCM
nnoremap <leader>y :let g:ycm_auto_trigger=0<CR>
"" turn on YCM
nnoremap <leader>Y :let g:ycm_auto_trigger=1<CR>

" Gitgutter
let g:gitgutter_enabled = 1
let g:gitgutter_realtime = 1
nnoremap <leader>gg :GitGutterLineHighlightsToggle<CR>

" Autoformat
let g:formatprg_args_c = "--mode=c --style=\"k&r\" -pcHs3"

" 80 column
hi ColorColumn ctermbg=235
set colorcolumn=80
