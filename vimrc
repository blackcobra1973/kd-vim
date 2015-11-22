"Modeline and Notes {
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer:
"       Kurt Dillen
"
" Version:
"       2.0.0 - 2015-11-22
"
" Awesome_version:
"       Get this config, nice color schemes and lots of plugins!
"
" Sections:
"     -> Vundle Install + Bundles
"     -> General
"     -> VIM user interface
"     -> Colors and Fonts
"     -> Files and backups
"     -> Text, tab and indent related
"     -> Visual mode related
"     -> Moving around, tabs and buffers
"     -> Status line
"     -> Vim Airline
"     -> Syntastic
"     -> Editing mappings
"     -> Automatically chmod +x for files starting with #! .../bin/
"     -> Automatically compile less files
"     -> Show what syntax is used
"     -> vimgrep searching and cope displaying
"     -> Spell checking
"     -> Misc
"     -> Helper functions
"     -> GUI Related
"     -> Fast editing and reloading of vimrc configs
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" }

" Environment {

  " Identify platform {
    silent function! OSX()
      return has('macunix')
    endfunction
    silent function! LINUX()
      return has('unix') && !has('macunix') && !has('win32unix')
    endfunction
    silent function! WINDOWS()
      return  (has('win32') || has('win64'))
    endfunction
  " }

  " Basics {
    set nocompatible        " Must be first line
    set background=dark     " Assume a dark background
    if !WINDOWS()
      set shell=/bin/sh
    endif
  " }

  " Windows Compatible {
    " On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
    " across (heterogeneous) systems easier.
    if WINDOWS()
      set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

      " Be nice and check for multi_byte even if the config requires
      " multi_byte support most of the time
      if has("multi_byte")
        " Windows cmd.exe still uses cp850. If Windows ever moved to
        " Powershell as the primary terminal, this would be utf-8
        set termencoding=cp850
        " Let Vim use utf-8 internally, because many scripts require this
        set encoding=utf-8
        setglobal fileencoding=utf-8
        " Windows has traditionally used cp1252, so it's probably wise to
        " fallback into cp1252 instead of eg. iso-8859-15.
        " Newer Windows files might contain utf-8 or utf-16 LE so we might
        " want to try them first.
        set fileencodings=ucs-bom,utf-8,utf-16le,cp1252,iso-8859-15
      endif
    endif
  " }

  " Arrow Key Fix {
    if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
        inoremap <silent> <C-[>OC <RIGHT>
    endif
  " }
" }

" kd options {

  " Prevent automatically changing to open file directory
  "   let g:kd_no_autochdir = 1

  " Disable views
  "   let g:kd_no_views = 1

  " Leader keys
  "   let g:kd_leader='\'
  "   let g:kd_localleader='_'

  " Disable easier moving in tabs and windows
  "   let g:kd_no_easyWindows = 1

  " Disable wrap relative motion for start/end line motions
  "   let g:kd_no_wrapRelMotion = 1

  " Disable fast tab navigation
  "   let g:kd_no_fastTabs = 1

  " Clear search highlighting
  "   let g:kd_clear_search_highlight = 1

  " Disable neosnippet expansion
  " This maps over <C-k> and does some Supertab
  " emulation with snippets
  "   let g:kd_no_neosnippet_expand = 1

  " Disable whitespace stripping
  "   let g:kd_keep_trailing_whitespace = 1

  " Enable powerline symbols
  "   let g:airline_powerline_fonts = 1

  " vim files directory
  "   let g:kd_consolidated_directory = <full path to desired directory>
  "   eg: let g:kd_consolidated_directory = $HOME . '/.vim/'

  " This makes the completion popup strictly passive.
  " Keypresses acts normally. <ESC> takes you of insert mode, words don't
  " automatically complete, pressing <CR> inserts a newline, etc. Iff the
  " menu is open, tab will cycle through it. If a snippet is selected, <C-k>
  " expands it and jumps between fields.
  "   let g:kd_noninvasive_completion = 1

  " Don't turn conceallevel or concealcursor
  "   let g:kd_no_conceal = 1

  " For some colorschemes, autocolor will not work (eg: 'desert', 'ir_black')
  " Indent guides will attempt to set your colors smartly. If you
  " want to control them yourself, do it here.
  "   let g:indent_guides_auto_colors = 0
  "   autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#212121 ctermbg=233
  "   autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#404040 ctermbg=234

  " Leave the default font and size in GVim
  " To set your own font, do it from ~/.vimrc.local
  "   let g:kd_no_big_font = 1

  " Disable  omni complete
  "   let g:kd_no_omni_complete = 1

  " Don't create default mappings for multicursors
  " See :help multiple-cursors-mappings
  "   let g:multi_cursor_use_default_mapping=0
  "   let g:multi_cursor_next_key='<C-n>'
  "   let g:multi_cursor_prev_key='<C-p>'
  "   let g:multi_cursor_skip_key='<C-x>'
  "   let g:multi_cursor_quit_key='<Esc>'
  " Require a special keypress to enter multiple cursors mode
  "   let g:multi_cursor_start_key='+'

  " Mappings for editing/applying kd config
  "   let g:kd_edit_config_mapping='<leader>ev'
  "   let g:kd_apply_config_mapping='<leader>sv'
" }

" Use local before if available {
  if filereadable(expand("~/.vimrc.before.local"))
    source ~/.vimrc.before.local
  endif
" }

" Vundle Install {
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vundle Install
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Install Vundle {
    " Required for Vundle Install
    filetype off

    " Setting up Vundle - the vim plugin bundler
    let iCanHazVundle=1
    let vundle_readme=expand('~/.vim/bundle/vundle/README.md')

    if !filereadable(vundle_readme)
      echo "Installing Vundle.."
      echo ""
      silent !mkdir -p ~/.vim/bundle
      silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
      let iCanHazVundle=0
    endif
  " }

  " Setup Bundle Support {
    " The next three lines ensure that the ~/.vim/bundle/ system works
    filetype off
    set rtp+=~/.vim/bundle/vundle
    call vundle#rc()
  " }

  " Add an UnBundle command {
    function! UnBundle(arg, ...)
      let bundle = vundle#config#init_bundle(a:arg, a:000)
      call filter(g:vundle#bundles, 'v:val["name_spec"] != "' . a:arg . '"')
    endfunction

    com! -nargs=+         UnBundle
    \ call UnBundle(<args>)
  " }
" }

" Bundles {
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Bundles
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Deps {
      Bundle 'gmarik/vundle'
      Bundle 'MarcWeber/vim-addon-mw-utils'
      Bundle 'tomtom/tlib_vim'
      if executable('ag')
          Bundle 'mileszs/ack.vim'
          let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
      elseif executable('ack-grep')
          let g:ackprg="ack-grep -H --nocolor --nogroup --column"
          Bundle 'mileszs/ack.vim'
      elseif executable('ack')
          Bundle 'mileszs/ack.vim'
      endif
  " }

  " In your .vimrc.before.local file
  " list only the plugin groups you will use
  if !exists('g:kd_bundle_groups')
      " Original spf13 default bundle set
      "let g:kd_bundle_groups=['general', 'writing', 'neocomplete', 'programming', 'php', 'ruby', 'python', 'javascript', 'html', 'misc',]
      " KD default bundle set
      let g:kd_bundle_groups=['general', 'neocomplcache', 'programming', 'php', 'ruby', 'python', 'javascript', 'html', 'misc',]

  endif

  " To override all the included bundles, add the following to your
  " .vimrc.bundles.local file:
  "   let g:override_kd_bundles = 1
  if !exists("g:override_kd_bundles")

  " General {
    if count(g:kd_bundle_groups, 'general')
      Bundle 'scrooloose/nerdtree'
      Bundle 'blackcobra1973/kd-vim-colors'
      Bundle 'tpope/vim-surround'
      Bundle 'tpope/vim-repeat'
      Bundle 'rhysd/conflict-marker.vim'
      Bundle 'jiangmiao/auto-pairs'
      Bundle 'ctrlpvim/ctrlp.vim'
      Bundle 'tacahiroy/ctrlp-funky'
      Bundle 'terryma/vim-multiple-cursors'
      Bundle 'vim-scripts/sessionman.vim'
      Bundle 'matchit.zip'
      if (has("python") || has("python3")) && exists('g:kd_use_powerline') && !exists('g:kd_use_old_powerline')
        Bundle 'Lokaltog/powerline', {'rtp':'/powerline/bindings/vim'}
      elseif exists('g:kd_use_powerline') && exists('g:kd_use_old_powerline')
        Bundle 'Lokaltog/vim-powerline'
      else
        Bundle 'bling/vim-airline'
      endif
      Bundle 'powerline/fonts'
      Bundle 'bling/vim-bufferline'
      Bundle 'easymotion/vim-easymotion'
      Bundle 'jistr/vim-nerdtree-tabs'
      Bundle 'flazz/vim-colorschemes'
      if has("python") || has("python3")
        Bundle 'sjl/gundo.vim'
      else
        Bundle 'mbbill/undotree'
      endif
      Bundle 'nathanaelkane/vim-indent-guides'
      if !exists('g:kd_no_views')
        Bundle 'vim-scripts/restore_view.vim'
      endif
      Bundle 'mhinz/vim-signify'
      Bundle 'tpope/vim-abolish.git'
      Bundle 'osyo-manga/vim-over'
      Bundle 'kana/vim-textobj-user'
      Bundle 'kana/vim-textobj-indent'
      Bundle 'gcmt/wildfire.vim'
      " KD Extra general bundles
      Bundle 'spf13/vim-autoclose'
      Bundle 'bronson/vim-trailing-whitespace'
    endif
  " }

  " Extra Color schemes {
    if count(g:kd_bundle_groups, 'colorschemes')
      Bundle 'altercation/vim-colors-solarized'
      Bundle 'spf13/vim-colors'
      Bundle 'flazz/vim-colorschemes'
    endif
  " }

  " Writing {
    if count(g:kd_bundle_groups, 'writing')
      Bundle 'reedes/vim-litecorrect'
      Bundle 'reedes/vim-textobj-sentence'
      Bundle 'reedes/vim-textobj-quote'
      Bundle 'reedes/vim-wordy'
    endif
  " }

  " General Programming {
    if count(g:kd_bundle_groups, 'programming')
      " Pick one of the checksyntax, jslint, or syntastic
      Bundle 'scrooloose/syntastic'
      Bundle 'tpope/vim-fugitive'
      Bundle 'mattn/webapi-vim'
      Bundle 'mattn/gist-vim'
      Bundle 'scrooloose/nerdcommenter'
      Bundle 'tpope/vim-commentary'
      Bundle 'godlygeek/tabular'
      Bundle 'luochen1990/rainbow'
      if executable('ctags')
        Bundle 'majutsushi/tagbar'
      endif
    endif
  " }

  " Snippets & AutoComplete {
    if count(g:kd_bundle_groups, 'snipmate')
      Bundle 'garbas/vim-snipmate'
      Bundle 'honza/vim-snippets'
      " Source support_function.vim to support vim-snippets.
      if filereadable(expand("~/.vim/bundle/vim-snippets/snippets/support_functions.vim"))
        source ~/.vim/bundle/vim-snippets/snippets/support_functions.vim
      endif
      elseif count(g:kd_bundle_groups, 'youcompleteme')
        Bundle 'Valloric/YouCompleteMe'
        Bundle 'SirVer/ultisnips'
        Bundle 'honza/vim-snippets'
      elseif count(g:kd_bundle_groups, 'neocomplcache')
        Bundle 'Shougo/neocomplcache'
        Bundle 'Shougo/neosnippet'
        Bundle 'Shougo/neosnippet-snippets'
        Bundle 'honza/vim-snippets'
      elseif count(g:kd_bundle_groups, 'neocomplete')
        Bundle 'Shougo/neocomplete.vim.git'
        Bundle 'Shougo/neosnippet'
        Bundle 'Shougo/neosnippet-snippets'
        Bundle 'honza/vim-snippets'
      endif
  " }

  " PHP {
    if count(g:kd_bundle_groups, 'php')
      Bundle 'spf13/PIV'
      Bundle 'arnaud-lb/vim-php-namespace'
      Bundle 'beyondwords/vim-twig'
    endif
  " }

" Python
"
"Bundle 'klen/python-mode'
"Bundle 'yssource/python.vim'
"Bundle 'python_match.vim'
"Bundle 'pythoncomplete'
"
" Javascript
"
Bundle 'elzr/vim-json'
Bundle 'groenewege/vim-less'
Bundle 'pangloss/vim-javascript'
Bundle 'briancollins/vim-jst'
Bundle 'kchmck/vim-coffee-script'
"
" Scala
"
"Bundle 'derekwyatt/vim-scala'
"Bundle 'derekwyatt/vim-sbt'
"Bundle 'xptemplate'
"
" Haskell
"
"Bundle 'travitch/hasksyn'
"Bundle 'dag/vim2hs'
"Bundle 'Twinside/vim-haskellConceal'
"Bundle 'Twinside/vim-haskellFold'
"Bundle 'lukerandall/haskellmode-vim'
"Bundle 'eagletmt/neco-ghc'
"Bundle 'eagletmt/ghcmod-vim'
"Bundle 'Shougo/vimproc'
"Bundle 'adinapoli/cumino'
"Bundle 'bitc/vim-hdevtools'
"
" HTML
"
Bundle 'amirh/HTML-AutoCloseTag'
Bundle 'hail2u/vim-css3-syntax'
Bundle 'gorodinskiy/vim-coloresque'
Bundle 'tpope/vim-haml'
"
" Ruby
"
Bundle 'tpope/vim-rails'
let g:rubycomplete_buffer_loading = 1
"let g:rubycomplete_classes_in_global = 1
"let g:rubycomplete_rails = 1
"
" Puppet Related
"
Bundle 'rodjek/vim-puppet'
"
" Go Lang
"
"Bundle 'Blackrush/vim-gocode'
"Bundle 'fatih/vim-go'
"
" Elixer
"
"Bundle 'elixir-lang/vim-elixir'
"Bundle 'carlosgaldino/elixir-snippets'
"Bundle 'mattreduce/vim-mix'
"
" Docker
"
Bundle 'blackcobra1973/Dockerfile.vim'
"
" Asciidoc
"
Bundle 'blackcobra1973/asciidoc-vim'
"
" Misc
"
Bundle 'wting/rust.vim'
Bundle 'tpope/vim-markdown'
Bundle 'spf13/vim-preview'
Bundle 'tpope/vim-cucumber'
"Bundle 'cespare/vim-toml'
Bundle 'quentindecock/vim-cucumber-align-pipes'
"Bundle 'saltstack/salt-vim'

" }

if iCanHazVundle == 0
  echo "Installing Bundles, please ignore key map error messages"
  echo ""
  :BundleInstall
  endif
" Setting up Vundle - the vim plugin bundler end

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Sets how many lines of history VIM has to remember
set history=1000

" Allow backspacing over everything in insert mode
set bs=2

" Enable filetype plugins
filetype plugin on
"filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

" Enable modeline (Vim settings in a file)
set modeline

" Hide the default mode text (e.g. -- INSERT -- below the statusline)
set noshowmode

" enable per-directory .vimrc files
"set exrc
"set secure

if has('clipboard')
  if has('unnamedplus')  " When possible use + register for copy-paste
    set clipboard=unnamed,unnamedplus
  else " On mac and Windows, use * register for copy-paste
    set clipboard=unnamed
  endif
endif

" Automatically enable mouse usage
"set mouse=a
" Hide the mouse cursor while typing
"set mousehide

" Set encoding to UTF8
scriptencoding utf-8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7
" Set 10 lines to the cursor
"set so=10

" Turn on the WiLd menu with Bash style tab completion
set wildmenu
set wildmode=longest:full

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

" Always show current position
set ruler

" A ruler on Steroids
" set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show numbers in the margin
set number

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
"set foldcolumn=1
"set foldcolumn=3    " Fold column is three bits wide

" When displaying line numbers, don't use an annoyingly wide number column. This
" doesn't enable line numbers -- :set number will do that. The value given is a
" minimum width to use for the number column, not a fixed size.
if v:version >= 700
  set numberwidth=3
endif

" Misc
set showfulltag     " Auto-complete things?

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

"try
"    colorscheme desert
"catch
"endtry

set background=dark

" Solarized Colorscheme
"colorscheme solarized

" Codeschool Colorscheme
"colorscheme codeschool

" Distinguished Colorscheme
"colorscheme distinguished

" PeakSea colorscheme
"colorscheme peaksea

" ir_black colorscheme
"colorscheme ir_black
colorscheme grb256

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Misc
highlight FoldColumn ctermfg=darkyellow ctermbg=darkgrey

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

" Linebreak on 500 characters
"set lbr
"set tw=500
set tw=0

" Paste toggle allows you paste large amounts of text into vim
" without risk for AI
set pastetoggle=<F2>

set noai "Disable Auto indent
"set ai "Auto indent
"set si "Smart indent
"set wrap "Wrap lines


""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f', '')<CR>
vnoremap <silent> # :call VisualSelection('b', '')<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat long lines as break lines (useful when moving around in them)
"map j gj
"map k gk

" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
"map <space> /
"map <c-space> ?

" Disable highlight when <leader><cr> is pressed
"map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
"map <C-j> <C-W>j
"map <C-k> <C-W>k
"map <C-h> <C-W>h
"map <C-l> <C-W>l

" Close the current buffer
"map <leader>bd :Bclose<cr>

" Close all the buffers
"map <leader>ba :1,1000 bd!<cr>

" Useful mappings for managing tabs
"map <leader>tn :tabnew<cr>
"map <leader>to :tabonly<cr>
"map <leader>tc :tabclose<cr>
"map <leader>tm :tabmove
"map <leader>t<leader> :tabnext

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
"map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
"map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers try
"  set switchbuf=useopen,usetab,newtab
"  set stal=2
"catch
"endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Uncomment the following to have Vim jump to the last position when reopening a file
" if has("autocmd")
"   function! s:JumpToLastLine()
"       if line("'\"") > 1 && line("'\"") <= line("$")
"      execute "normal! g'\""
"    endif
"  endfunction

"  au BufReadPost * call s:JumpToLastLine()
"endif

" Keep a .viminfo file.
set viminfo='20,\"500

" Save marks and stuff
set viminfo+='100,f1

" Remember info about open buffers on close
set viminfo^=%

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
" Improved status line: always visible, shows [+] modification, read only
" status, git branch, etc.
set laststatus=2

" Format the status line
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l
" set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

set statusline=%<%f\                          " Filename
set statusline+=%w%h%m%r                      " Options
set statusline+=%{SyntasticStatuslineFlag()}  " Syntastic
set statusline+=%{fugitive#statusline()}      " Git Hotness
set statusline+=\ [%{&ff}/%Y]                 " Filetype
set statusline+=\ [%{getcwd()}]               " Current dir
set statusline+=%=%-14.(%l,%c%V%)\ %p%%       " Right aligned file nav info

hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red

" Show (partial) command in status line.
set showcmd

"""""""""""""""""""""""""""""
" => Vim Airline
"""""""""""""""""""""""""""""
" Change the theme (available options: dark, light, simple, badwolf, solarized)
"let g:airline_theme='badwolf'
"let g:airline_theme='base16'
"let g:airline_theme='bubblegum'
"let g:airline_theme='dark'
"let g:airline_theme='jellybeans'
"let g:airline_theme='laederon'
"let g:airline_theme='luna'
"let g:airline_theme='monochrome'
"let g:airline_theme='serene'
"let g:airline_theme='sol'
"let g:airline_theme='tomorrow'
"let g:airline_theme='ubaryd'
"let g:airline_theme='understated'
"let g:airline_theme='wombat'
"let g:airline_theme='zenburn'

" Best Themes
"let g:airline_theme='molokai'
let g:airline_theme='murmur'
"let g:airline_theme='powerlineish'
"let g:airline_theme='simple'
"let g:airline_theme='solarized'

" The separator used on the left side
"let g:airline_left_sep='>'

" The separator used on the right side
"let g:airline_right_sep='<'

" enable modified detection
let g:airline_detect_modified=1

" enable paste detection
let g:airline_detect_paste=1

" enable iminsert detection
let g:airline_detect_iminsert=0

" determine whether inactive windows should have the left section collapsed to
"  only the filename of that buffer.
let g:airline_inactive_collapse=1

" enable/disable usage of patched powerline font symbols
let g:airline_powerline_fonts=0

" unicode symbols - OLD
"let g:airline_left_sep = '»'
"let g:airline_left_sep = '▶'
"let g:airline_right_sep = '«'
"let g:airline_right_sep = '◀'
"let g:airline_linecolumn_prefix = '␊ '
"let g:airline_linecolumn_prefix = '␤ '
"let g:airline_linecolumn_prefix = '¶ '
"let g:airline_branch_prefix = '⎇ '
"let g:airline_paste_symbol = 'ρ'
"let g:airline_paste_symbol = 'Þ'
"let g:airline_paste_symbol = '∥'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
"let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
"let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
"let g:airline_symbols.linenr = '␊'
"let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
"let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
"let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" configure the title text for quickfix buffers
let g:airline#extensions#quickfix#quickfix_text = 'Quickfix'
" configure the title text for location list buffers
let g:airline#extensions#quickfix#location_text = 'Location'

" enable/disable bufferline integration
let g:airline#extensions#bufferline#enabled = 1
" determine whether bufferline will overwrite customization variables
let g:airline#extensions#bufferline#overwrite_variables = 1

" enable/disable fugitive/lawrencium integration
let g:airline#extensions#branch#enabled = 1
" change the text for when no branch is detected
let g:airline#extensions#branch#empty_message = ''
" use vcscommand.vim if available
let g:airline#extensions#branch#use_vcscommand = 0
" truncate long branch names to a fixed length
let g:airline#extensions#branch#displayed_head_limit = 10
" customize formatting of branch name >
" default value leaves the name unmodifed
let g:airline#extensions#branch#format = 0

" to only show the tail, e.g. a branch 'feature/foo' show 'foo'
let g:airline#extensions#branch#format = 1

" if a string is provided, it should be the name of a function that
" takes a string and returns the desired value
let g:airline#extensions#branch#format = 'CustomBranchName'
function! CustomBranchName(name)
  return '[' . a:name . ']'
endfunction

" enable/disable syntastic integration
let g:airline#extensions#syntastic#enabled = 1

" enable/disable tagbar integration
let g:airline#extensions#tagbar#enabled = 1
" change how tags are displayed (:help tagbar-statusline)
"let g:airline#extensions#tagbar#flags = ''  (default)
"let g:airline#extensions#tagbar#flags = 'f'
"let g:airline#extensions#tagbar#flags = 's'
"let g:airline#extensions#tagbar#flags = 'p'

" enable/disable showing a summary of changed hunks under source control.
let g:airline#extensions#hunks#enabled = 1
" enable/disable showing only non-zero hunks.
let g:airline#extensions#hunks#non_zero_only = 1
" set hunk count symbols.
let g:airline#extensions#hunks#hunk_symbols = ['+', '~', '-']

" Solarized options
let g:solarized_termcolors=256

""""""""""""""""""""""""""""""""""""
" => Syntastic
""""""""""""""""""""""""""""""""""""

" If enabled, syntastic will do syntax checks when buffers are first loaded as
" well as on saving >
let g:syntastic_check_on_open=1

" Normally syntastic runs syntax checks whenever buffers are written to disk.
" If you want to skip these checks when you issue |:wq|, |:x|, and |:ZZ|, set this
" variable to 0. >
"let g:syntastic_check_on_wq=0

" If enabled, syntastic will echo the error associated with the current line to
" the command window. If multiple errors are found, the first will be used. >
let g:syntastic_echo_current_error=1

" Use this option to tell syntastic whether to use the |:sign| interface to mark
" syntax errors: >
let g:syntastic_enable_signs=1

let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'

"let g:syntastic_full_redraws=0

" Use this option to tell syntastic whether to display error messages in balloons
" when the mouse is hovered over erroneous lines: >
let g:syntastic_enable_balloons = 1

" Use this option to tell syntastic whether to use syntax highlighting to mark
" errors (where possible). Highlighting can be turned off with the following >
let g:syntastic_enable_highlighting = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
"nmap <M-j> mz:m+<cr>`z
"nmap <M-k> mz:m-2<cr>`z
"vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
"vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

"if has("mac") || has("macunix")
"  nmap <D-j> <M-j>
"  nmap <D-k> <M-k>
"  vmap <D-j> <M-j>
"  vmap <D-k> <M-k>
"endif

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
"func! DeleteTrailingWS()
"  exe "normal mz"
"  %s/\s\+$//ge
"  exe "normal `z"
"endfunc
"autocmd BufWrite *.py :call DeleteTrailingWS()
"autocmd BufWrite *.coffee :call DeleteTrailingWS()

"Move a line or selection of text using Crtl+[jk] or Comamnd+[jk] on mac
nmap <silent> <C-j> mz:m+<CR>`z
nmap <silent> <C-k> mz:m-2<CR>`z
nmap <silent> <C-down> mz:m+<CR>`z
nmap <silent> <C-up> mz:m-2<CR>`z
vmap <silent> <C-j> :m'>+<CR>`<my`>mzgv`yo`z
vmap <silent> <C-k> :m'<-2<CR>`>my`<mzgv`yo`z
vmap <silent> <C-down> :m'>+<CR>`<my`>mzgv`yo`z
vmap <silent> <C-up> :m'<-2<CR>`>my`<mzgv`yo`z

" Nul (aka. Ctrl-Space) does dicky things. Lets stop that.
imap <Nul> <Nop>

" :W - Write then make. Usefull for compiling automatically
command! -nargs=0 WM :w | :!make


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Automatically chmod +x for files starting with #! .../bin/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:AutoChmodX()
  if getline(1) =~ "^#!"
    execute "silent !chmod +x " . shellescape(expand('%:h'), 1)
  endif
endfunction

au BufWritePost * call s:AutoChmodX()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Automatically compile less files
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:compile_less()
  let l:less = expand('%:p')
  let l:css = substitute(l:less, "\\<less\\>", "css", "g")
  let l:outfile = tempname()
  let l:errorfile = "/dev/null"
  let l:cmd = printf("!lessc --no-color %s > %s 2> %s",
  \ shellescape(l:less, 1),
  \ shellescape(l:outfile, 1),
  \ shellescape(l:errorfile, 1)
  \)
  silent execute l:cmd

  if v:shell_error
    call delete(l:outfile)
  else
    call rename(l:outfile, l:css)
  endif
endfunction
au BufWritePost *.less call s:compile_less()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Show what syntax is used
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vimgrep searching and cope displaying
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press gv you vimgrep after the selected text
"vnoremap <silent> gv :call VisualSelection('gv', '')<CR>

" Open vimgrep and put the cursor in the right position
"map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

" Vimgreps in the current file
"map <leader><space> :vimgrep // <C-R>%<C-A><right><right><right><right><right><right><right><right><right>

" When you press <leader>r you can search and replace the selected text
"vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with vimgrep, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p
"
"map <leader>cc :botright cope<cr>
"map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
"map <leader>n :cn<cr>
"map <leader>p :cp<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
"map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
"map <leader>sn ]s
"map <leader>sp [s
"map <leader>sa zg
"map <leader>s? z=


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
"noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scripbble
"map <leader>q :e ~/buffer<cr>

" Toggle paste mode on and off
"map <leader>pp :setlocal paste!<cr>



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.' . a:extra_filter)
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

" Don't close window, when deleting a buffer
"command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GUI related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set background=dark

"colorscheme peaksea

" Set font according to system
"if has("mac") || has("macunix")
"    set gfn=Menlo:h15
"elseif has("win16") || has("win32")
"    set gfn=Bitstream\ Vera\ Sans\ Mono:h11
"elseif has("linux")
"    set gfn=Monospace\ 11
"endif

" Open MacVim in fullscreen mode
"if has("gui_macvim")
"    set fuoptions=maxvert,maxhorz
"    au GUIEnter * set fullscreen
"endif

" Disable scrollbars (real hackers don't use scrollbars for navigation!)
"set guioptions-=r
"set guioptions-=R
"set guioptions-=l
"set guioptions-=L

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fast editing and reloading of vimrc configs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"map <leader>e :e! ~/.vim_runtime/my_configs.vim<cr>
"autocmd! bufwritepost vimrc source ~/.vim_runtime/my_configs.vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Turn persistent undo on
"    means that you can undo even when you close a buffer/VIM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"try
"    set undodir=~/.vim_runtime/temp_dirs/undodir
"    set undofile
"catch
"endtry


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Command mode related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart mappings on the command line
"cno $h e ~/
"cno $d e ~/Desktop/
"cno $j e ./
"cno $c e <C-\>eCurrentFileDir("e")<cr>

" $q is super useful when browsing on the command line
" it deletes everything until the last slash
"cno $q <C-\>eDeleteTillSlash()<cr>

" Bash like keys for the command line
"cnoremap <C-A>   <Home>
"cnoremap <C-E>   <End>
"cnoremap <C-K>   <C-U>

"cnoremap <C-P> <Up>
"cnoremap <C-N> <Down>

" Map ½ to something useful
"map ½ $
"cmap ½ $
"imap ½ $


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Parenthesis/bracket
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"vnoremap $1 <esc>`>a)<esc>`<i(<esc>
"vnoremap $2 <esc>`>a]<esc>`<i[<esc>
"vnoremap $3 <esc>`>a}<esc>`<i{<esc>
"vnoremap $$ <esc>`>a"<esc>`<i"<esc>
"vnoremap $q <esc>`>a'<esc>`<i'<esc>
"vnoremap $e <esc>`>a"<esc>`<i"<esc>

" Map auto complete of (, ", ', [
"inoremap $1 ()<esc>i
"inoremap $2 []<esc>i
"inoremap $3 {}<esc>i
"inoremap $4 {<esc>o}<esc>O
"inoremap $q ''<esc>i
"inoremap $e ""<esc>i
"inoremap $t <><esc>i


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General abbreviations
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Omni complete functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"func! DeleteTillSlash()
"    let g:cmd = getcmdline()

"    if has("win16") || has("win32")
"        let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\]\\).*", "\\1", "")
"    else
"        let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
"    endif

"    if g:cmd == g:cmd_edited
"        if has("win16") || has("win32")
"            let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*\[\\\\\]", "\\1", "")
"        else
"            let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
"        endif
"    endif

"    return g:cmd_edited
"endfunc

"func! CurrentFileDir(cmd)
"    return a:cmd . " " . expand("%:p:h") . "/"
"endfunc


"""""""""""""""""""""""""""""""""""""""""""""""
" => Custom filetype settings
"""""""""""""""""""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.cjs setfiletype javascript
au BufNewFile,BufRead *.thtml setfiletype php
au BufNewFile,BufRead *.pl setfiletype prolog
au BufNewFile,BufRead *.json setfiletype json
"au BufNewFile,BufRead *.asc setfiletype asciidoc
autocmd BufNewFile,BufRead *.csv setf csv
autocmd BufNewFile,BufRead *.txt setlocal textwidth=0
au FileType * setl fo-=cro        " disable autocomment

autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
" preceding line best in a plugin but here for now.

autocmd BufNewFile,BufRead *.coffee set filetype=coffee

" Workaround vim-commentary for Haskell
autocmd FileType haskell setlocal commentstring=--\ %s
" Workaround broken colour highlighting in Haskell
autocmd FileType haskell,rust setlocal nospell

"filetype plugin indent on


"""""""""""""""""""""""""""""
" => XML syntax folding
""""""""""""""""""""""""""""""
"let g:xml_syntax_folding=1
"au FileType xml setlocal foldmethod=syntax

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Objective-C settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType objc set foldmethod=syntax foldnestmax=1

""""""""""""""""""""""""""""""
" => Python section
""""""""""""""""""""""""""""""
let python_highlight_all = 1
au FileType python syn keyword pythonDecorator True None False self

au BufNewFile,BufRead *.jinja set syntax=htmljinja
au BufNewFile,BufRead *.mako set ft=mako

au FileType python map <buffer> F :set foldmethod=indent<cr>

au FileType python inoremap <buffer> $r return
au FileType python inoremap <buffer> $i import
au FileType python inoremap <buffer> $p print
au FileType python inoremap <buffer> $f #--- PH ----------------------------------------------<esc>FP2xi
au FileType python map <buffer> <leader>1 /class
au FileType python map <buffer> <leader>2 /def
au FileType python map <buffer> <leader>C ?class
au FileType python map <buffer> <leader>D ?def

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Python settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.py set expandtab
au BufNewFile,BufRead *.py set nosmartindent
let g:pyindent_open_paren = '&sw'
let g:pyindent_nested_paren = '&sw'
let g:pyindent_continue = '&sw'

""""""""""""""""""""""""""""""
" => JavaScript section
"""""""""""""""""""""""""""""""
au FileType javascript call JavaScriptFold()
au FileType javascript setl fen
au FileType javascript setl nocindent

au FileType javascript imap <c-t> AJS.log();<esc>hi
au FileType javascript imap <c-a> alert();<esc>hi

au FileType javascript inoremap <buffer> $r return
au FileType javascript inoremap <buffer> $f //--- PH ----------------------------------------------<esc>FP2xi

function! JavaScriptFold()
    setl foldmethod=syntax
    setl foldlevelstart=1
    syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

    function! FoldText()
        return substitute(getline(v:foldstart), '{.*', '{...}', '')
    endfunction
    setl foldtext=FoldText()
endfunction

""""""""""""""""""""""""""""""
" => CoffeeScript section
"""""""""""""""""""""""""""""""
function! CoffeeScriptFold()
    setl foldmethod=indent
    setl foldlevelstart=1
endfunction
au FileType coffee call CoffeeScriptFold()

""""""""""""""""""""""""""""""
" => Load pathogen paths
""""""""""""""""""""""""""""""
"call pathogen#infect('~/.vim_runtime/sources_forked')
"call pathogen#infect('~/.vim_runtime/sources_non_forked')
"call pathogen#helptags()

""""""""""""""""""""""""""""""
" => bufExplorer plugin
""""""""""""""""""""""""""""""
"let g:bufExplorerDefaultHelp=0
"let g:bufExplorerShowRelativePath=1
"let g:bufExplorerFindActive=1
"let g:bufExplorerSortBy='name'
"map <leader>o :BufExplorer<cr>

""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
"let MRU_Max_Entries = 400
"map <leader>f :MRU<CR>

""""""""""""""""""""""""""""""
" => YankRing
""""""""""""""""""""""""""""""
"if has("win16") || has("win32")
    " Don't do anything
"else
"    let g:yankring_history_dir = '~/.vim_runtime/temp_dirs/'
"endif

""""""""""""""""""""""""""""""
" => CTRL-P
""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/ctrlp.vim/"))

  let g:ctrlp_working_path_mode = 0
  "let g:ctrlp_working_path_mode = 'ra'

  nnoremap <silent> <D-t> :CtrlP<CR>
  nnoremap <silent> <D-r> :CtrlPMRU<CR>

  "let g:ctrlp_map = '<c-f>'
  "map <c-b> :CtrlPBuffer<cr>

  let g:ctrlp_max_height = 20
  "let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee'

  let g:ctrlp_custom_ignore = {
    \ 'dir': '\.git$\|\.svn$\|\.hg$\|build$\|venv$',
    \ 'file': '\.pyc$\|\.so$\|\.class$|\.DS_Store$',
    \ }

  if executable('ag')
    let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
  elseif executable('ack-grep')
    let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
  elseif executable('ack')
    let s:ctrlp_fallback = 'ack %s --nocolor -f'
  else
    let s:ctrlp_fallback = 'find %s -type f'
  endif
  let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
  \ },
  \ 'fallback': s:ctrlp_fallback
  \ }

  if isdirectory(expand("~/.vim/bundle/ctrlp-funky/"))
    " CtrlP extensions
    let g:ctrlp_extensions = ['funky']

    "funky
    nnoremap <Leader>fu :CtrlPFunky<Cr>
  endif
endif

""""""""""""""""""""""""""""""
" => Peepopen
""""""""""""""""""""""""""""""
"map <leader>j :PeepOpen<cr>

""""""""""""""""""""""""""""""
" => ZenCoding
""""""""""""""""""""""""""""""
" Enable all functions in all modes
"let g:user_zen_mode='a'

""""""""""""""""""""""""""""""
" => snipMate (beside <TAB> support <CTRL-j>)
""""""""""""""""""""""""""""""
"ino <c-j> <c-r>=snipMate#TriggerSnippet()<cr>
"snor <c-j> <esc>i<right><c-r>=snipMate#TriggerSnippet()<cr>

""""""""""""""""""""""""""""""
" => Vim grep
""""""""""""""""""""""""""""""
let Grep_Skip_Dirs = 'RCS CVS SCCS .svn generated'
set grepprg=/bin/grep\ -nH

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F7>       :NERDTreeToggle<CR>
"map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark
map <leader>nf :NERDTreeFind<cr>

if isdirectory(expand("~/.vim/bundle/nerdtree"))
  let g:NERDShutUp=1
  let NERDTreeShowBookmarks=1
"  let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
  let NERDTreeChDirMode=0
  let NERDTreeQuitOnOpen=1
  let NERDTreeMouseMode=2
  let NERDTreeShowHidden=1
  let NERDTreeKeepTreeInNewTab=1
  let g:nerdtree_tabs_open_on_gui_startup=0
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-multiple-cursors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:multi_cursor_next_key="\<C-s>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Gundo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if version >= 703
  nnoremap <F5> :GundoToggle<CR>
endif

if version < 703
  let g:gundo_disable=1
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => UltiSnips
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"let g:UltiSnips.always_use_first_snippet = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fugitive
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/vim-fugitive/"))
  nnoremap <silent> <leader>gs :Gstatus<CR>
  nnoremap <silent> <leader>gd :Gdiff<CR>
  nnoremap <silent> <leader>gc :Gcommit<CR>
  nnoremap <silent> <leader>gb :Gblame<CR>
  nnoremap <silent> <leader>gl :Glog<CR>
  nnoremap <silent> <leader>gp :Git push<CR>
  nnoremap <silent> <leader>gr :Gread<CR>
  "nnoremap <silent> <leader>gw :Gwrite<CR>
  nnoremap <silent> <leader>gw :Gwrite<CR>:GitGutter<CR>
  nnoremap <silent> <leader>ge :Gedit<CR>
  " Mnemonic _i_nteractive
  nnoremap <silent> <leader>gi :Git add -p %<CR>
  nnoremap <silent> <leader>gg :SignifyToggle<CR>
  "nnoremap <silent> <leader>gg :GitGutterToggle<CR>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => surround.vim config
" Annotate strings with gettext http://amix.dk/blog/post/19678
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"vmap Si S(i_<esc>f)
"au FileType mako vmap Si S"i${ _(<esc>2f"a) }<esc>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Multiple Cursors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:multi_cursor_use_default_mapping=0

" Default mapping
"let g:multi_cursor_next_key='<C-n>'
"let g:multi_cursor_prev_key='<C-p>'
"let g:multi_cursor_skip_key='<C-x>'
"let g:multi_cursor_quit_key='<Esc>'

" Map start key separately from next key
"let g:multi_cursor_start_key='<F6>'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim Rails
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rubycomplete_buffer_loading = 1
"let g:rubycomplete_classes_in_global = 1
"let g:rubycomplete_rails = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim Indent Guides
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/vim-indent-guides/"))
  "nmap <silent> <Leader>ig <Plug>IndentGuidesToggle
  nmap <silent> <F8> <Plug>IndentGuidesToggle

  let g:indent_guides_start_level = 2
  let g:indent_guides_guide_size = 1

  let g:indent_guides_auto_colors = 0
  autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=black
  "autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=lightgrey
  autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=darkgrey
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => TextObj Sentence/Quote
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TextObj Sentence
if isdirectory(expand("~/.vim/bundle/vim-textobj-sentence/"))
  augroup textobj_sentence
    autocmd!
    autocmd FileType markdown call textobj#sentence#init()
    autocmd FileType textile call textobj#sentence#init()
    autocmd FileType text call textobj#sentence#init()
  augroup END
endif

" TextObj Quote
if isdirectory(expand("~/.vim/bundle/vim-textobj-quote/"))
  augroup textobj_quote
    autocmd!
    autocmd FileType markdown call textobj#quote#init()
    autocmd FileType textile call textobj#quote#init()
    autocmd FileType text call textobj#quote#init({'educate': 0})
  augroup END
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PIV
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/PIV"))
  let g:DisableAutoPHPFolding = 0
  let g:PIVAutoClose = 0
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => matchit.zip
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/matchit.zip"))
  let b:match_ignorecase = 1
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Tabular
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/tabular"))
  nmap <Leader>a& :Tabularize /&<CR>
  vmap <Leader>a& :Tabularize /&<CR>
  nmap <Leader>a= :Tabularize /=<CR>
  vmap <Leader>a= :Tabularize /=<CR>
  nmap <Leader>a=> :Tabularize /=><CR>
  vmap <Leader>a=> :Tabularize /=><CR>
  nmap <Leader>a: :Tabularize /:<CR>
  vmap <Leader>a: :Tabularize /:<CR>
  nmap <Leader>a:: :Tabularize /:\zs<CR>
  vmap <Leader>a:: :Tabularize /:\zs<CR>
  nmap <Leader>a, :Tabularize /,<CR>
  vmap <Leader>a, :Tabularize /,<CR>
  nmap <Leader>a,, :Tabularize /,\zs<CR>
  vmap <Leader>a,, :Tabularize /,\zs<CR>
  nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
  vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => SessionMan
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
if isdirectory(expand("~/.vim/bundle/sessionman.vim/"))
  nmap <leader>sl :SessionList<CR>
  nmap <leader>ss :SessionSave<CR>
  nmap <leader>sc :SessionClose<CR>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => JSON
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
let g:vim_json_syntax_conceal = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => PyMode
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable if python support not present
if !has('python')
  let g:pymode = 0
endif

if isdirectory(expand("~/.vim/bundle/python-mode"))
  let g:pymode_lint_checkers = ['pyflakes']
  let g:pymode_trim_whitespaces = 0
  let g:pymode_options = 0
  let g:pymode_rope = 0
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => TagBar
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/tagbar/"))
  nnoremap <silent> <leader>tt :TagbarToggle<CR>

  " If using go please install the gotags program using the following
  " go install github.com/jstemmer/gotags
  " And make sure gotags is in your path
  let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [  'p:package', 'i:imports:1', 'c:constants', 'v:variables',
      \ 't:types',  'n:interfaces', 'w:fields', 'e:embedded', 'm:methods',
      \ 'r:constructor', 'f:functions' ],
    \ 'sro' : '.',
    \ 'kind2scope' : { 't' : 'ctype', 'n' : 'ntype' },
    \ 'scope2kind' : { 'ctype' : 't', 'ntype' : 'n' },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
    \ }
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NeoComplCache
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/neocomplcache/"))
  let g:acp_enableAtStartup = 0
  let g:neocomplcache_enable_at_startup = 1
  let g:neocomplcache_enable_camel_case_completion = 1
  let g:neocomplcache_enable_smart_case = 1
  let g:neocomplcache_enable_underbar_completion = 1
  let g:neocomplcache_enable_auto_delimiter = 1
  let g:neocomplcache_max_list = 15
  let g:neocomplcache_force_overwrite_completefunc = 1

  " Define dictionary.
  let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
    \ }

  " Define keyword.
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns._ = '\h\w*'

  " These two lines conflict with the default digraph mapping of <C-K>
  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)

  " Noninvasive completion
  "inoremap <CR> <CR>
  " <ESC> takes you out of insert mode
  "inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
  " <CR> accepts first, then sends the <CR>
  "inoremap <expr> <CR>  pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
  " <Down> and <Up> cycle like <Tab> and <S-Tab>
  "inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
  "inoremap <expr> <Up>  pumvisible() ? "\<C-p>" : "\<Up>"
  " Jump up and down the list
  "inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
  "inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

  " Invasive completion
  imap <silent><expr><C-k> neosnippet#expandable() ?
    \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
    \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
  smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

  inoremap <expr><C-g> neocomplcache#undo_completion()
  inoremap <expr><C-l> neocomplcache#complete_common_string()
  "inoremap <expr><CR> neocomplcache#complete_common_string()

  function! CleverCr()
    if pumvisible()
      if neosnippet#expandable()
        let exp = "\<Plug>(neosnippet_expand)"
        return exp . neocomplcache#close_popup()
      else
        return neocomplcache#close_popup()
      endif
    else
      return "\<CR>"
    endif
  endfunction

  " <CR> close popup and save indent or expand snippet
  imap <expr> <CR> CleverCr()

  " <CR>: close popup
  " <s-CR>: close popup and save indent.
  inoremap <expr><s-CR> pumvisible() ? neocomplcache#close_popup()"\<CR>" : "\<CR>"
  "inoremap <expr><CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y> neocomplcache#close_popup()

  " <TAB>: completion.
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

  " Enable heavy omni completion.
  if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
  endif
  let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
  let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.go = '\h\w*\.\?'
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Snippets
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use honza's snippets.
"let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

" Enable neosnippet snipmate compatibility mode
"let g:neosnippet#enable_snipmate_compatibility = 1

" Enable neosnippets when using go
"let g:go_snippet_engine = "neosnippet"

" Disable the neosnippet preview candidate window
" When enabled, there can be too much visual noise
" especially when splits are used.
"set completeopt-=preview

" FIXME: Isn't this for Syntastic to handle?
" Haskell post write lint and check with ghcmod
" $ `cabal install ghcmod` if missing and ensure
" ~/.cabal/bin is in your $PATH.
if !executable("ghcmod")
  autocmd BufWritePost *.hs GhcModCheckAndLintAsync
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Wildfire
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/wildfire.vim/"))
  let g:wildfire_objects = {
    \ "*" : ["i'", 'i"', "i)", "i]", "i}", "ip"],
    \ "html,xml" : ["at"],
    \ }
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => AutoClose
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if isdirectory(expand("~/.vim/bundle/vim-autoclose/"))
  let g:autoclose_vim_commentmode = 1
endif

