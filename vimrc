"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer:
"       Kurt Dillen
"
" Version:
"       2.0.0 - 2016-01-10
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
"     -> Spell checking
"     -> Misc
"     -> Helper functions
"     -> GUI Related
"     -> Fast editing and reloading of vimrc configs
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim Environment
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
    else
      set encoding=utf8
    endif
  " }

  " Arrow Key Fix {
    if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
        inoremap <silent> <C-[>OC <RIGHT>
    endif
  " }
" }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim Options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vundle Install
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle Install {
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Bundles
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Bundles {
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
      let g:kd_bundle_groups=['general', 'neocomplcache', 'programming', 'asciidoc', 'ruby', 'puppet', 'docker', 'javascript', 'html', 'misc',]

  endif

  " To override all the included bundles, add the following to your
  " .vimrc.before.local file:
  "   let g:override_kd_bundles = 1
  if !exists("g:override_kd_bundles")

    " General {
      if count(g:kd_bundle_groups, 'general')
        Bundle 'scrooloose/nerdtree'
        Bundle 'jistr/vim-nerdtree-tabs'
        Bundle 'tpope/vim-surround'
        Bundle 'tpope/vim-repeat'
        Bundle 'spf13/vim-autoclose'
        Bundle 'ctrlpvim/ctrlp.vim'
        Bundle 'tacahiroy/ctrlp-funky'
        Bundle 'terryma/vim-multiple-cursors'
        Bundle 'easymotion/vim-easymotion'
        if has("python") || has("python3")
          Bundle 'sjl/gundo.vim'
        else
          Bundle 'mbbill/undotree'
        endif
        Bundle 'nathanaelkane/vim-indent-guides'
        Bundle 'mhinz/vim-signify'
        Bundle 'bronson/vim-trailing-whitespace'
        if (has("python") || has("python3")) && exists('g:kd_use_powerline') && !exists('g:kd_use_old_powerline')
          Bundle 'Lokaltog/powerline', {'rtp':'/powerline/bindings/vim'}
        elseif exists('g:kd_use_powerline') && exists('g:kd_use_old_powerline')
          Bundle 'Lokaltog/vim-powerline'
        else
          Bundle 'bling/vim-airline'
        endif
        Bundle 'powerline/fonts'
        Bundle 'rhysd/conflict-marker.vim'
        if !exists('g:kd_no_views')
          Bundle 'vim-scripts/restore_view.vim'
        endif
        Bundle 'osyo-manga/vim-over'
        Bundle 'gcmt/wildfire.vim'
        Bundle 'blackcobra1973/kd-vim-colors'
      endif
    " }

    " Extra General {
      if count(g:kd_bundle_groups, 'extra')
        Bundle 'jiangmiao/auto-pairs'
        Bundle 'vim-scripts/sessionman.vim'
        Bundle 'matchit.zip'
        Bundle 'bling/vim-bufferline'
        Bundle 'tpope/vim-abolish.git'
        Bundle 'kana/vim-textobj-user'
        Bundle 'kana/vim-textobj-indent'
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

    " Python {
      if count(g:kd_bundle_groups, 'python')
        " Pick either python-mode or pyflakes & pydoc
        Bundle 'klen/python-mode'
        Bundle 'yssource/python.vim'
        Bundle 'python_match.vim'
        Bundle 'pythoncomplete'
      endif
    " }

    " Javascript {
      if count(g:kd_bundle_groups, 'javascript')
        Bundle 'elzr/vim-json'
        Bundle 'groenewege/vim-less'
        Bundle 'pangloss/vim-javascript'
        Bundle 'briancollins/vim-jst'
        Bundle 'kchmck/vim-coffee-script'
      endif
    " }

    " Scala {
      if count(g:kd_bundle_groups, 'scala')
        Bundle 'derekwyatt/vim-scala'
        Bundle 'derekwyatt/vim-sbt'
        Bundle 'xptemplate'
      endif
    " }

    " Haskell {
      if count(g:kd_bundle_groups, 'haskell')
        Bundle 'travitch/hasksyn'
        Bundle 'dag/vim2hs'
        Bundle 'Twinside/vim-haskellConceal'
        Bundle 'Twinside/vim-haskellFold'
        Bundle 'lukerandall/haskellmode-vim'
        Bundle 'eagletmt/neco-ghc'
        Bundle 'eagletmt/ghcmod-vim'
        Bundle 'Shougo/vimproc.vim'
        Bundle 'adinapoli/cumino'
        Bundle 'bitc/vim-hdevtools'
      endif
    " }

    " HTML {
      if count(g:kd_bundle_groups, 'html')
        Bundle 'amirh/HTML-AutoCloseTag'
        Bundle 'hail2u/vim-css3-syntax'
        Bundle 'gorodinskiy/vim-coloresque'
        Bundle 'tpope/vim-haml'
        Bundle 'mattn/emmet-vim'
      endif
    " }

    " Ruby {
      if count(g:kd_bundle_groups, 'ruby')
        Bundle 'tpope/vim-rails'
        let g:rubycomplete_buffer_loading = 1
        "let g:rubycomplete_classes_in_global = 1
        "let g:rubycomplete_rails = 1
      endif
    " }

    " Puppet {
      if count(g:kd_bundle_groups, 'puppet')
        Bundle 'rodjek/vim-puppet'
      endif
    " }

    " Go Lang {
      if count(g:kd_bundle_groups, 'go')
        "Bundle 'Blackrush/vim-gocode'
        Bundle 'fatih/vim-go'
      endif
    " }

    " Elixir {
      if count(g:kd_bundle_groups, 'elixir')
        Bundle 'elixir-lang/vim-elixir'
        Bundle 'carlosgaldino/elixir-snippets'
        Bundle 'mattreduce/vim-mix'
      endif
    " }

    " Docker {
      if count(g:kd_bundle_groups, 'docker')
        Bundle 'blackcobra1973/Dockerfile.vim'
      endif
    " }

    " Asciidoc {
      if count(g:kd_bundle_groups, 'asciidoc')
        Bundle 'blackcobra1973/asciidoc-vim'
      endif
    " }

    " Misc {
      if count(g:kd_bundle_groups, 'misc')
        Bundle 'rust-lang/rust.vim'
        Bundle 'tpope/vim-markdown'
        Bundle 'spf13/vim-preview'
        Bundle 'tpope/vim-cucumber'
        Bundle 'cespare/vim-toml'
        Bundle 'quentindecock/vim-cucumber-align-pipes'
        Bundle 'saltstack/salt-vim'
      endif
    " }

  endif
" }

" Use local bundles config if available {
  if filereadable(expand("~/.vimrc.bundles.local"))
    source ~/.vimrc.bundles.local
  endif
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
" General {
  set background=dark         " Assume a dark background

  " Allow to trigger background
  function! ToggleBG()
    let s:tbg = &background
    " Inversion
    if s:tbg == "dark"
      set background=light
    else
      set background=dark
    endif
  endfunction
  noremap <leader>bg :call ToggleBG()<CR>

  filetype plugin indent on   " Automatically detect file types.
  syntax on                   " Syntax highlighting
  "set mouse=a                 " Automatically enable mouse usage
  "set mousehide               " Hide the mouse cursor while typing
  scriptencoding utf-8        " Set encoding to UTF8
  set history=1000            " Sets how many lines of history VIM has to remember
  set autoread                " Set to auto read when a file is changed from the outside
  set ffs=unix,dos,mac        " Use Unix as the standard file type

  " Most prefer to automatically switch to the current file directory when
  " a new buffer is opened; to prevent this behavior, add the following to
  " your .vimrc.before.local file:
  "   let g:kd_no_autochdir = 1
  if !exists('g:kd_no_autochdir')
    autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
    " Always switch to the current file directory
  endif

  "set autowrite                       " Automatically write a file when leaving a modified buffer
  set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
  set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
  set virtualedit=onemore             " Allow for cursor beyond last character
  "set spell                           " Spell checking on
  "set hidden                          " Allow buffer switching without saving
  set iskeyword-=.                    " '.' is an end of word designator
  set iskeyword-=#                    " '#' is an end of word designator
  set iskeyword-=-                    " '-' is an end of word designator

  " Instead of reverting the cursor to the last position in the buffer, we
  " set it to the first line when editing a git commit message
  au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

  " Enable filetype plugins
  "filetype plugin on
  "filetype indent on

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

  " Misc
  highlight FoldColumn ctermfg=darkyellow ctermbg=darkgrey

  " Setting up the directories {

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => Files, backups and undo
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Turn backup off, since most stuff is in SVN, git etc anyway...
    set nobackup
    set nowb
    set noswapfile
    "set backup                  " Backups are nice ...

    if has('persistent_undo')
      set undofile                " So is persistent undo ...
      set undolevels=1000         " Maximum number of changes that can be undone
      set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
    endif

    set viminfo='20,\"500         " Keep a .viminfo file.
    set viminfo+='100,f1          " Save marks and stuff
    set viminfo^=%                " Remember info about open buffers on close

    " To disable views add the following to your .vimrc.before.local file:
    "   let g:kd_no_views = 1
    if !exists('g:kd_no_views')
      " Add exclusions to mkview and loadview
      " eg: *.*, svn-commit.tmp
      let g:skipview_files = [
        \ '\[example pattern\]'
        \ ]
    endif
  " }
" }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim UI {

  if !exists('g:override_kd_bundles') && filereadable(expand("~/.vim/bundle/vim-colors-solarized/colors/solarized.vim"))
    let g:solarized_termcolors=256
    let g:solarized_termtrans=1
    let g:solarized_contrast="normal"
    let g:solarized_visibility="normal"
    color solarized             " Load a colorscheme
  else
    let g:solarized_termcolors=256
  endif

  colorscheme grb256

  set tabpagemax=15               " Only show 15 tabs
  set modeline                    " Enable modeline (Vim settings in a file)
  "set showmode                    " Display the current mode
  set noshowmode                  " Hide the default mode text (e.g. -- INSERT -- below the statusline)
  set cursorline                  " Highlight current line

  highlight clear SignColumn      " SignColumn should match background
  highlight clear LineNr          " Current line number row will have same background color in relative mode
  "highlight clear CursorLineNr    " Remove highlight color from current line number

  if has('cmdline_info')
    set ruler                   " Show the ruler
    "set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
    set showcmd                 " Show partial commands in status line and
                                " Selected characters/lines in visual mode
  endif

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
  if has('statusline')
    " Always show the status line
    " Improved status line: always visible, shows [+] modification, read only
    " status, git branch, etc.
    set laststatus=2

    " Broken down into easily includeable segments
    set statusline=%<%f\                     " Filename
    set statusline+=%w%h%m%r                 " Options
    set statusline+=%{SyntasticStatuslineFlag()}  " Syntastic
    if !exists('g:override_kd_bundles')
      set statusline+=%{fugitive#statusline()} " Git Hotness
    endif
    set statusline+=\ [%{&ff}/%Y]            " Filetype
    set statusline+=\ [%{getcwd()}]          " Current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
  endif

  hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red

  " Show (partial) command in status line.
  set showcmd

  set backspace=indent,eol,start  " Backspace for dummies
  "set backspace=eol,start,indent  " Backspace for dummies
  set linespace=0                 " No extra spaces between rows
  set number                      " Line numbers on
  set showmatch                   " Show matching brackets/parenthesis
  set mat=2                       " How many tenths of a second to blink when matching brackets
  set incsearch                   " Find as you type search
  set hlsearch                    " Highlight search terms
  set winminheight=0              " Windows can be 0 line high
  set ignorecase                  " Case insensitive search
  set smartcase                   " Case sensitive when uc present
  set wildmenu                    " Show list instead of just completing
  "set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
  set wildmode=longest:full       " Command <Tab> completion, list matches, then longest common part, then all.
  set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
  "set whichwrap+=<,>,h,l          " Backspace and cursor keys wrap too
  set scrolljump=5                " Lines to scroll when cursor leaves screen
  set scrolloff=3                 " Minimum lines to keep above and below cursor
  set foldenable                  " Auto fold code
  set list
  set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
  set bs=2                        " Allow backspacing over everything in insert mode
  set so=7                        " Set 7 lines to the cursor - when moving vertically using j/k
  "set so=10                       " Set 10 lines to the cursor
  set cmdheight=2                 " Height of the command bar
  set hid                         " A buffer becomes hidden when it is abandoned
  set lazyredraw                  " Don't redraw while executing macros (good performance config)
  set magic                       " For regular expressions turn magic on
  set showfulltag                 " Auto-complete things?

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

  " Ignore compiled files
  set wildignore=*.o,*~,*.pyc
  if has("win32") || has("win64")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
  else
    set wildignore+=.git\*,.hg\*,.svn\*
  endif
" }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim Formatting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Formatting {
  set nowrap                      " Do not wrap long lines
  "set wrap "Wrap lines
  "set autoindent                  " Indent at the same level of the previous line
  set shiftwidth=2                " Use indents of 2 spaces
  set expandtab                   " Tabs are spaces, not tabs
  set tabstop=2                   " An indentation every four columns
  set softtabstop=2               " Let backspace delete indent
  set smarttab                    " Be smart when using tabs ;)
  set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
  set splitright                  " Puts new vsplit windows to the right of the current
  set splitbelow                  " Puts new split windows to the bottom of the current
  "set matchpairs+=<:>             " Match, to be used with %
  "set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
  set pastetoggle=<F2>            " pastetoggle (sane indentation on pastes)
  "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks

  " Remove trailing whitespaces and ^M chars
  " To disable the stripping of whitespace, add the following to your
  " .vimrc.before.local file:
  "   let g:kd_keep_trailing_whitespace = 1
  autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> if !exists('g:kd_keep_trailing_whitespace') | call StripTrailingWhitespace() | endif
  "autocmd FileType go autocmd BufWritePre <buffer> Fmt
  autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
  autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
  " preceding line best in a plugin but here for now.

  autocmd BufNewFile,BufRead *.coffee set filetype=coffee
  au BufNewFile,BufRead *.cjs setfiletype javascript
  au BufNewFile,BufRead *.thtml setfiletype php
  au BufNewFile,BufRead *.pl setfiletype prolog
  au BufNewFile,BufRead *.json setfiletype json
  au BufNewFile,BufRead *.asc setfiletype asciidoc
  autocmd BufNewFile,BufRead *.csv setf csv
  autocmd BufNewFile,BufRead *.txt setlocal textwidth=0
  au FileType * setl fo-=cro        " disable autocomment

  " Workaround vim-commentary for Haskell
  autocmd FileType haskell setlocal commentstring=--\ %s
  " Workaround broken colour highlighting in Haskell
  autocmd FileType haskell,rust setlocal nospell

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

  " Linebreak on 500 characters
  "set lbr
  "set tw=500
  set tw=0

  set noai                              " Disable Auto indent
  "set ai                                " Auto indent
  "set si                                " Smart indent
  "set wrap                              " Wrap lines

  """"""""""""""""""""""""""""""
  " => Vim grep
  """"""""""""""""""""""""""""""
  let Grep_Skip_Dirs = 'RCS CVS SCCS .svn generated'
  set grepprg=/bin/grep\ -nH

" }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key (re)Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key (re)Mappings {

  " The default leader is '\', but many people prefer ',' as it's in a standard
  " location. To override this behavior and set it back to '\' (or any other
  " character) add the following to your .vimrc.before.local file:
  "   let g:kd_leader='\'
  if !exists('g:kd_leader')
    let mapleader = ','
    let g:mapleader = ","
  else
    let mapleader=g:kd_leader
  endif
  if !exists('g:kd_localleader')
    let maplocalleader = '_'
  else
    let maplocalleader=g:kd_localleader
  endif

  " The default mappings for editing and applying the kd configuration
  " are <leader>ev and <leader>sv respectively. Change them to your preference
  " by adding the following to your .vimrc.before.local file:
  "   let g:kd_edit_config_mapping='<leader>ec'
  "   let g:kd_apply_config_mapping='<leader>sc'
  if !exists('g:kd_edit_config_mapping')
    let s:kd_edit_config_mapping = '<leader>ev'
  else
    let s:kd_edit_config_mapping = g:kd_edit_config_mapping
  endif
  if !exists('g:kd_apply_config_mapping')
    let s:kd_apply_config_mapping = '<leader>sv'
  else
    let s:kd_apply_config_mapping = g:kd_apply_config_mapping
  endif

  " Easier moving in tabs and windows
  " The lines conflict with the default digraph mapping of <C-K>
  " If you prefer that functionality, add the following to your
  " .vimrc.before.local file:
  "   let g:kd_no_easyWindows = 1
  if !exists('g:kd_no_easyWindows')
    map <C-J> <C-W>j<C-W>_
    map <C-K> <C-W>k<C-W>_
    map <C-L> <C-W>l<C-W>_
    map <C-H> <C-W>h<C-W>_
  endif
  " Wrapped lines goes down/up to next row, rather than next line in file.
  noremap j gj
  noremap k gk

  " End/Start of line motion keys act relative to row/wrap width in the
  " presence of `:set wrap`, and relative to line for `:set nowrap`.
  " Default vim behaviour is to act relative to text line in both cases
  " If you prefer the default behaviour, add the following to your
  " .vimrc.before.local file:
  "   let g:kd_no_wrapRelMotion = 1
  if !exists('g:kd_no_wrapRelMotion')
    " Same for 0, home, end, etc
    function! WrapRelativeMotion(key, ...)
      let vis_sel=""
      if a:0
        let vis_sel="gv"
      endif
      if &wrap
        execute "normal!" vis_sel . "g" . a:key
      else
        execute "normal!" vis_sel . a:key
      endif
    endfunction

    " Map g* keys in Normal, Operator-pending, and Visual+select
    noremap $ :call WrapRelativeMotion("$")<CR>
    noremap <End> :call WrapRelativeMotion("$")<CR>
    noremap 0 :call WrapRelativeMotion("0")<CR>
    noremap <Home> :call WrapRelativeMotion("0")<CR>
    noremap ^ :call WrapRelativeMotion("^")<CR>
    " Overwrite the operator pending $/<End> mappings from above
    " to force inclusive motion with :execute normal!
    onoremap $ v:call WrapRelativeMotion("$")<CR>
    onoremap <End> v:call WrapRelativeMotion("$")<CR>
    " Overwrite the Visual+select mode mappings from above
    " to ensure the correct vis_sel flag is passed to function
    vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
    vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
    vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
    vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
    vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>
  endif

  " The following two lines conflict with moving to top and
  " bottom of the screen
  " If you prefer that functionality, add the following to your
  " .vimrc.before.local file:
  "   let g:kd_no_fastTabs = 1
  if !exists('g:kd_no_fastTabs')
    map <S-H> gT
    map <S-L> gt
  endif

  " Stupid shift key fixes
  if !exists('g:kd_no_keyfixes')
    if has("user_commands")
      command! -bang -nargs=* -complete=file E e<bang> <args>
      command! -bang -nargs=* -complete=file W w<bang> <args>
      command! -bang -nargs=* -complete=file Wq wq<bang> <args>
      command! -bang -nargs=* -complete=file WQ wq<bang> <args>
      command! -bang Wa wa<bang>
      command! -bang WA wa<bang>
      command! -bang Q q<bang>
      command! -bang QA qa<bang>
      command! -bang Qa qa<bang>
    endif

    cmap Tabe tabe
  endif

  " Yank from the cursor to the end of the line, to be consistent with C and D.
  nnoremap Y y$

  " Code folding options
  nmap <leader>f0 :set foldlevel=0<CR>
  nmap <leader>f1 :set foldlevel=1<CR>
  nmap <leader>f2 :set foldlevel=2<CR>
  nmap <leader>f3 :set foldlevel=3<CR>
  nmap <leader>f4 :set foldlevel=4<CR>
  nmap <leader>f5 :set foldlevel=5<CR>
  nmap <leader>f6 :set foldlevel=6<CR>
  nmap <leader>f7 :set foldlevel=7<CR>
  nmap <leader>f8 :set foldlevel=8<CR>
  nmap <leader>f9 :set foldlevel=9<CR>

  " Most prefer to toggle search highlighting rather than clear the current
  " search results. To clear search highlighting rather than toggle it on
  " and off, add the following to your .vimrc.before.local file:
  "   let g:kd_clear_search_highlight = 1
  if exists('g:kd_clear_search_highlight')
    nmap <silent> <leader>/ :nohlsearch<CR>
  else
    nmap <silent> <leader>/ :set invhlsearch<CR>
  endif
  " Find merge conflict markers
  map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

  " Shortcuts
  " Change Working Directory to that of the current file
  cmap cwd lcd %:p:h
  cmap cd. lcd %:p:h

  " Visual shifting (does not exit Visual mode)
  vnoremap < <gv
  vnoremap > >gv

  " Allow using the repeat operator with a visual selection (!)
  " http://stackoverflow.com/a/8064607/127816
  vnoremap . :normal .<CR>

  " Some helpers to edit mode
  " http://vimcasts.org/e/14
  cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
  map <leader>ew :e %%
  map <leader>es :sp %%
  map <leader>ev :vsp %%
  map <leader>et :tabe %%

  " Adjust viewports to the same size
  map <Leader>= <C-w>=

  " Map <Leader>ff to display all lines with keyword under cursor
  " and ask which one to jump to
  nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

  " Easier horizontal scrolling
  map zl zL
  map zh zH

  " Easier formatting
  nnoremap <silent> <leader>q gwip

  " FIXME: Revert this f70be548
  " fullscreen mode for GVIM and Terminal, need 'wmctrl' in you PATH
  map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>

  " Fast saving
  nmap <leader>w :w!<cr>

  " For when you forget to sudo.. Really Write the file.
  cmap w!! w !sudo tee % >/dev/null
  " :W sudo saves the file
  " (useful for handling the permission-denied error)
  " command W w !sudo tee % > /dev/null

  " Visual mode pressing * or # searches for the current selection
  " Super useful! From an idea by Michael Naumann
  vnoremap <silent> * :call VisualSelection('f', '')<CR>
  vnoremap <silent> # :call VisualSelection('b', '')<CR>

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " => Show what syntax is used
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
" }

""""""""""""""""""""""""""""""
" => Plugins
""""""""""""""""""""""""""""""
" Plugins {

    " GoLang {
        if count(g:kd_bundle_groups, 'go')
            let g:go_highlight_functions = 1
            let g:go_highlight_methods = 1
            let g:go_highlight_structs = 1
            let g:go_highlight_operators = 1
            let g:go_highlight_build_constraints = 1
            let g:go_fmt_command = "goimports"
            let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
            let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
            au FileType go nmap <Leader>s <Plug>(go-implements)
            au FileType go nmap <Leader>i <Plug>(go-info)
            au FileType go nmap <Leader>e <Plug>(go-rename)
            au FileType go nmap <leader>r <Plug>(go-run)
            au FileType go nmap <leader>b <Plug>(go-build)
            au FileType go nmap <leader>t <Plug>(go-test)
            au FileType go nmap <Leader>gd <Plug>(go-doc)
            au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
            au FileType go nmap <leader>co <Plug>(go-coverage)
        endif
        " }

    " TextObj Sentence {
        if count(g:kd_bundle_groups, 'writing')
            augroup textobj_sentence
              autocmd!
              autocmd FileType markdown call textobj#sentence#init()
              autocmd FileType textile call textobj#sentence#init()
              autocmd FileType text call textobj#sentence#init()
            augroup END
        endif
    " }

    " TextObj Quote {
        if count(g:kd_bundle_groups, 'writing')
            augroup textobj_quote
                autocmd!
                autocmd FileType markdown call textobj#quote#init()
                autocmd FileType textile call textobj#quote#init()
                autocmd FileType text call textobj#quote#init({'educate': 0})
            augroup END
        endif
    " }

    " PIV {
        if isdirectory(expand("~/.vim/bundle/PIV/"))
            let g:DisableAutoPHPFolding = 0
            let g:PIVAutoClose = 0
        endif
    " }

    " Misc {
        if isdirectory(expand("~/.vim/bundle/nerdtree/"))
            let g:NERDShutUp=1
        endif
        if isdirectory(expand("~/.vim/bundle/matchit.zip"))
            let b:match_ignorecase = 1
        endif
    " }

    " OmniComplete {
        " To disable omni complete, add the following to your .vimrc.before.local file:
        "   let g:kd_no_omni_complete = 1
        if !exists('g:kd_no_omni_complete')
            if has("autocmd") && exists("+omnifunc")
                autocmd Filetype *
                    \if &omnifunc == "" |
                    \setlocal omnifunc=syntaxcomplete#Complete |
                    \endif
            endif

            hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
            hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
            hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

            " Some convenient mappings
            "inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
            if exists('g:kd_map_cr_omni_complete')
                inoremap <expr> <CR>     pumvisible() ? "\<C-y>" : "\<CR>"
            endif
            inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
            inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
            inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
            inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

            " Automatically open and close the popup menu / preview window
            au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
            set completeopt=menu,preview,longest
        endif
    " }

    " Ctags {
        set tags=./tags;/,~/.vimtags

        " Make tags placed in .git/tags file available in all levels of a repository
        let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
        if gitroot != ''
            let &tags = &tags . ',' . gitroot . '/.git/tags'
        endif
    " }

    " AutoCloseTag {
        " Make it so AutoCloseTag works for xml and xhtml files as well
        au FileType xhtml,xml ru ftplugin/html/autoclosetag.vim
        nmap <Leader>ac <Plug>ToggleAutoCloseMappings
    " }

    " SnipMate {
        " Setting the author var
        " If forking, please overwrite in your .vimrc.local file
        let g:snips_author = 'Steve Francia <steve.francia@gmail.com>'
    " }

    " AutoClose {
      if isdirectory(expand("~/.vim/bundle/vim-autoclose/"))
        let g:autoclose_vim_commentmode = 1
      endif
    " }

    " Nerd Tree {
        if isdirectory(expand("~/.vim/bundle/nerdtree"))
            map <F7>       :NERDTreeToggle<CR>
            "map <C-e> <plug>NERDTreeTabsToggle<CR>
            map <leader>nb :NERDTreeFromBookmark
            map <leader>nf :NERDTreeFind<cr>
            "map <leader>e :NERDTreeFind<CR>
            "nmap <leader>nt :NERDTreeFind<CR>

            let NERDTreeShowBookmarks=1
            "let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
            let NERDTreeChDirMode=0
            let NERDTreeQuitOnOpen=1
            let NERDTreeMouseMode=2
            let NERDTreeShowHidden=1
            let NERDTreeKeepTreeInNewTab=1
            let g:nerdtree_tabs_open_on_gui_startup=0
        endif
    " }

    " Tabularize {
        if isdirectory(expand("~/.vim/bundle/tabular"))
            nmap <Leader>a& :Tabularize /&<CR>
            vmap <Leader>a& :Tabularize /&<CR>
            nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
            vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
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
    " }

    " Session List {
        set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
        if isdirectory(expand("~/.vim/bundle/sessionman.vim/"))
            nmap <leader>sl :SessionList<CR>
            nmap <leader>ss :SessionSave<CR>
            nmap <leader>sc :SessionClose<CR>
        endif
    " }

    " JSON {
        nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
        let g:vim_json_syntax_conceal = 0
    " }

    " PyMode {
        " Disable if python support not present
        if !has('python') && !has('python3')
            let g:pymode = 0
        endif

        if isdirectory(expand("~/.vim/bundle/python-mode"))
            let g:pymode_lint_checkers = ['pyflakes']
            let g:pymode_trim_whitespaces = 0
            let g:pymode_options = 0
            let g:pymode_rope = 0
        endif
    " }

    " CTRL-P {
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
            \ 'dir':  '\.git$\|\.hg$\|\.svn$',
            \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

          if executable('ag')
            let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
          elseif executable('ack-grep')
            let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
          elseif executable('ack')
            let s:ctrlp_fallback = 'ack %s --nocolor -f'
          " On Windows use "dir" as fallback command.
          elseif WINDOWS()
            let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
          else
            let s:ctrlp_fallback = 'find %s -type f'
          endif
          if exists("g:ctrlp_user_command")
            unlet g:ctrlp_user_command
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
    "}

    " TagBar {
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
    "}

    " Rainbow {
        if isdirectory(expand("~/.vim/bundle/rainbow/"))
          let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
        endif
    "}

    " Fugitive {
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
    "}

    " YouCompleteMe {
        if count(g:kd_bundle_groups, 'youcompleteme')
            let g:acp_enableAtStartup = 0

            " enable completion from tags
            let g:ycm_collect_identifiers_from_tags_files = 1

            " remap Ultisnips for compatibility for YCM
            let g:UltiSnipsExpandTrigger = '<C-j>'
            let g:UltiSnipsJumpForwardTrigger = '<C-j>'
            let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

            " Enable omni completion.
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
            autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
            autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
            autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
            autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
            autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
            autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

            " Haskell post write lint and check with ghcmod
            " $ `cabal install ghcmod` if missing and ensure
            " ~/.cabal/bin is in your $PATH.
            if !executable("ghcmod")
                autocmd BufWritePost *.hs GhcModCheckAndLintAsync
            endif

            " For snippet_complete marker.
            if !exists("g:kd_no_conceal")
                if has('conceal')
                    set conceallevel=2 concealcursor=i
                endif
            endif

            " Disable the neosnippet preview candidate window
            " When enabled, there can be too much visual noise
            " especially when splits are used.
            set completeopt-=preview
        endif
    " }

    " neocomplete {
        if count(g:kd_bundle_groups, 'neocomplete')
            let g:acp_enableAtStartup = 0
            let g:neocomplete#enable_at_startup = 1
            let g:neocomplete#enable_smart_case = 1
            let g:neocomplete#enable_auto_delimiter = 1
            let g:neocomplete#max_list = 15
            let g:neocomplete#force_overwrite_completefunc = 1


            " Define dictionary.
            let g:neocomplete#sources#dictionary#dictionaries = {
                        \ 'default' : '',
                        \ 'vimshell' : $HOME.'/.vimshell_hist',
                        \ 'scheme' : $HOME.'/.gosh_completions'
                        \ }

            " Define keyword.
            if !exists('g:neocomplete#keyword_patterns')
                let g:neocomplete#keyword_patterns = {}
            endif
            let g:neocomplete#keyword_patterns['default'] = '\h\w*'

            " Plugin key-mappings {
                " These two lines conflict with the default digraph mapping of <C-K>
                if !exists('g:kd_no_neosnippet_expand')
                    imap <C-k> <Plug>(neosnippet_expand_or_jump)
                    smap <C-k> <Plug>(neosnippet_expand_or_jump)
                endif
                if exists('g:kd_noninvasive_completion')
                    inoremap <CR> <CR>
                    " <ESC> takes you out of insert mode
                    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
                    " <CR> accepts first, then sends the <CR>
                    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
                    " <Down> and <Up> cycle like <Tab> and <S-Tab>
                    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
                    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
                    " Jump up and down the list
                    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
                    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
                else
                    " <C-k> Complete Snippet
                    " <C-k> Jump to next snippet point
                    imap <silent><expr><C-k> neosnippet#expandable() ?
                                \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
                                \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
                    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

                    inoremap <expr><C-g> neocomplete#undo_completion()
                    inoremap <expr><C-l> neocomplete#complete_common_string()
                    "inoremap <expr><CR> neocomplete#complete_common_string()

                    " <CR>: close popup
                    " <s-CR>: close popup and save indent.
                    inoremap <expr><s-CR> pumvisible() ? neocomplete#smart_close_popup()."\<CR>" : "\<CR>"

                    function! CleverCr()
                        if pumvisible()
                            if neosnippet#expandable()
                                let exp = "\<Plug>(neosnippet_expand)"
                                return exp . neocomplete#smart_close_popup()
                            else
                                return neocomplete#smart_close_popup()
                            endif
                        else
                            return "\<CR>"
                        endif
                    endfunction

                    " <CR> close popup and save indent or expand snippet
                    imap <expr> <CR> CleverCr()
                    " <C-h>, <BS>: close popup and delete backword char.
                    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
                    inoremap <expr><C-y> neocomplete#smart_close_popup()
                endif
                " <TAB>: completion.
                inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
                inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

                " Courtesy of Matteo Cavalleri

                function! CleverTab()
                    if pumvisible()
                        return "\<C-n>"
                    endif
                    let substr = strpart(getline('.'), 0, col('.') - 1)
                    let substr = matchstr(substr, '[^ \t]*$')
                    if strlen(substr) == 0
                        " nothing to match on empty string
                        return "\<Tab>"
                    else
                        " existing text matching
                        if neosnippet#expandable_or_jumpable()
                            return "\<Plug>(neosnippet_expand_or_jump)"
                        else
                            return neocomplete#start_manual_complete()
                        endif
                    endif
                endfunction

                imap <expr> <Tab> CleverTab()
            " }

            " Enable heavy omni completion.
            if !exists('g:neocomplete#sources#omni#input_patterns')
                let g:neocomplete#sources#omni#input_patterns = {}
            endif
            let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
            let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
    " }

    " NeoComplCache {
        elseif count(g:kd_bundle_groups, 'neocomplcache')
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

            " Plugin key-mappings {
                " These two lines conflict with the default digraph mapping of <C-K>
                imap <C-k> <Plug>(neosnippet_expand_or_jump)
                smap <C-k> <Plug>(neosnippet_expand_or_jump)
                if exists('g:kd_noninvasive_completion')
                    inoremap <CR> <CR>
                    " <ESC> takes you out of insert mode
                    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
                    " <CR> accepts first, then sends the <CR>
                    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
                    " <Down> and <Up> cycle like <Tab> and <S-Tab>
                    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
                    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
                    " Jump up and down the list
                    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
                    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
                else
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
                    inoremap <expr><s-CR> pumvisible() ? neocomplcache#close_popup()."\<CR>" : "\<CR>"
                    "inoremap <expr><CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

                    " <C-h>, <BS>: close popup and delete backword char.
                    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
                    inoremap <expr><C-y> neocomplcache#close_popup()
                endif
                " <TAB>: completion.
                inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
                inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"
            " }

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
    " }

    " Normal Vim omni-completion {
    " To disable omni complete, add the following to your .vimrc.before.local file:
    "   let g:kd_no_omni_complete = 1
        elseif !exists('g:kd_no_omni_complete')
            " Enable omni-completion.
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
            autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
            autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
            autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
            autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
            autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
            autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
        endif
    " }

    " Snippets {
        if count(g:kd_bundle_groups, 'neocomplcache') ||
          \ count(g:kd_bundle_groups, 'neocomplete')

          " Use honza's snippets.
          "let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

          " Enable neosnippet snipmate compatibility mode
          "let g:neosnippet#enable_snipmate_compatibility = 1

          " For snippet_complete marker.
          "if !exists("g:kd_no_conceal")
          "    if has('conceal')
          "        set conceallevel=2 concealcursor=i
          "    endif
          "endif

          " Enable neosnippets when using go
          let g:go_snippet_engine = "neosnippet"

          " Disable the neosnippet preview candidate window
          " When enabled, there can be too much visual noise
          " especially when splits are used.
          "set completeopt-=preview
        endif
    " }

    " FIXME: Isn't this for Syntastic to handle?
    " Haskell post write lint and check with ghcmod
    " $ `cabal install ghcmod` if missing and ensure
    " ~/.cabal/bin is in your $PATH.
    if !executable("ghcmod")
        autocmd BufWritePost *.hs GhcModCheckAndLintAsync
    endif

    " UndoTree {
        if isdirectory(expand("~/.vim/bundle/undotree/"))
            nnoremap <Leader>u :UndotreeToggle<CR>
            " If undotree is opened, it is likely one wants to interact with it.
            let g:undotree_SetFocusWhenToggle=1
        endif
    " }

    " Gundo {
        if isdirectory(expand("~/.vim/bundle/gundo.vim/"))
          if version >= 703
            nnoremap <F5> :GundoToggle<CR>
          endif

          if version < 703
            let g:gundo_disable=1
          endif
        endif
    " }

    " Syntastic {
        if isdirectory(expand("~/.vim/bundle/syntastic/"))
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
        endif
    " }

    " VIM Indent_Guides {
        if isdirectory(expand("~/.vim/bundle/vim-indent-guides/"))
            nmap <silent> <F8> <Plug>IndentGuidesToggle
            let g:indent_guides_start_level = 2
            let g:indent_guides_guide_size = 1
            let g:indent_guides_enable_on_vim_startup = 0
            let g:indent_guides_auto_colors = 0

            autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=black
            "autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=lightgrey
            autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=darkgrey
        endif
    " }

    " WildFire {
      if isdirectory(expand("~/.vim/bundle/wildfire.vim/"))
        let g:wildfire_objects = {
          \ "*" : ["i'", 'i"', "i)", "i]", "i}", "ip"],
          \ "html,xml" : ["at"],
          \ }
      endif
    " }

    " vim-airline {
        " Set configuration options for the statusline plugin vim-airline.
        " Use the powerline theme and optionally enable powerline symbols.
        " To use the symbols , , , , , , and .in the statusline
        " segments add the following to your .vimrc.before.local file:
        "   let g:airline_powerline_fonts=1
        " If the previous symbols do not render for you then install a
        " powerline enabled font.

        " See `:echo g:airline_theme_map` for some more choices
        " Default in terminal vim is 'dark'
        if isdirectory(expand("~/.vim/bundle/vim-airline/"))
          if !exists('g:airline_theme')
            "let g:airline_theme = 'solarized'
            let g:airline_theme='murmur'
          endif

          let g:airline_detect_modified=1     " enable modified detection
          let g:airline_detect_paste=1        " enable paste detection
          let g:airline_detect_iminsert=0     " enable iminsert detection
          let g:airline_inactive_collapse=1   " determine whether inactive windows should have the left section collapsed to
                                              " only the filename of that buffer.
          "let g:airline_powerline_fonts=0     " enable/disable usage of patched powerline font symbols

          if !exists('g:airline_symbols')
            let g:airline_symbols = {}
          endif

          if !exists('g:airline_powerline_fonts')
            " Use the default set of separators with a few customizations
            "let g:airline_left_sep='›'  " Slightly fancier than '>'
            "let g:airline_left_sep = '»'
            let g:airline_left_sep = '▶'
            "let g:airline_right_sep='‹' " Slightly fancier than '<'
            "let g:airline_right_sep = '«'
            let g:airline_right_sep = '◀'

            " unicode symbols
            "let g:airline_symbols.linenr = '␊'
            "let g:airline_symbols.linenr = '␤'
            let g:airline_symbols.linenr = '¶'
            let g:airline_symbols.branch = '⎇'
            "let g:airline_symbols.paste = 'ρ'
            let g:airline_symbols.paste = 'Þ'
            "let g:airline_symbols.paste = '∥'
            let g:airline_symbols.whitespace = 'Ξ'
          endif

          let g:airline#extensions#quickfix#quickfix_text = 'Quickfix'      " configure the title text for quickfix buffers
          let g:airline#extensions#quickfix#location_text = 'Location'      " configure the title text for location list buffers
          let g:airline#extensions#bufferline#enabled = 1                   " enable/disable bufferline integration
          let g:airline#extensions#bufferline#overwrite_variables = 1       " determine whether bufferline will overwrite
                                                                            " customization variables
          let g:airline#extensions#branch#enabled = 1                       " enable/disable fugitive/lawrencium integration
          let g:airline#extensions#branch#empty_message = ''                " change the text for when no branch is detected
          let g:airline#extensions#branch#use_vcscommand = 0                " use vcscommand.vim if available
          let g:airline#extensions#branch#displayed_head_limit = 10         " truncate long branch names to a fixed length
          let g:airline#extensions#branch#format = 0                        " customize formatting of branch name >
                                                                            " default value leaves the name unmodifed
          let g:airline#extensions#branch#format = 1                        " to only show the tail, e.g. a branch 'feature/foo'
                                                                            " show 'foo'

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
        endif
    " }
" }


""""""""""""""""""""""""""""""
" => GUI Settings
""""""""""""""""""""""""""""""
" GUI Settings {

    " GVIM- (here instead of .gvimrc)
    if has('gui_running')
        set guioptions-=T           " Remove the toolbar
        set lines=40                " 40 lines of text instead of 24
        if !exists("g:kd_no_big_font")
            if LINUX() && has("gui_running")
                set guifont=Andale\ Mono\ Regular\ 12,Menlo\ Regular\ 11,Consolas\ Regular\ 12,Courier\ New\ Regular\ 14
            elseif OSX() && has("gui_running")
                set guifont=Andale\ Mono\ Regular:h12,Menlo\ Regular:h11,Consolas\ Regular:h12,Courier\ New\ Regular:h14
            elseif WINDOWS() && has("gui_running")
                set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
            endif
        endif
    else
        if &term == 'xterm' || &term == 'screen'
            set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
        endif
        "set term=builtin_ansi       " Make arrow and other keys work
    endif

    " Set extra options when running in GUI mode
    "if has("gui_running")
    "  set guioptions-=T
    "  set guioptions-=e
    "  set t_Co=256
    "  set guitablabel=%M\ %t
    "endif
" }

""""""""""""""""""""""""""""""
" => Functions
""""""""""""""""""""""""""""""
" Functions {
    " Initialize directories {
    function! InitializeDirectories()
      let parent = $HOME
      let prefix = 'vim'
      let dir_list = {
        \ 'backup': 'backupdir',
        \ 'views': 'viewdir',
        \ 'swap': 'directory' }

      if has('persistent_undo')
        let dir_list['undo'] = 'undodir'
      endif

      " To specify a different directory in which to place the vimbackup,
      " vimviews, vimundo, and vimswap files/directories, add the following to
      " your .vimrc.before.local file:
      "   let g:kd_consolidated_directory = <full path to desired directory>
      "   eg: let g:kd_consolidated_directory = $HOME . '/.vim/'
      if exists('g:kd_consolidated_directory')
        let common_dir = g:kd_consolidated_directory . prefix
      else
        let common_dir = parent . '/.' . prefix
      endif

      for [dirname, settingname] in items(dir_list)
        let directory = common_dir . dirname . '/'
        if exists("*mkdir")
          if !isdirectory(directory)
            call mkdir(directory)
          endif
        endif
        if !isdirectory(directory)
          echo "Warning: Unable to create backup directory: " . directory
          echo "Try: mkdir -p " . directory
        else
          let directory = substitute(directory, " ", "\\\\ ", "g")
          exec "set " . settingname . "=" . directory
        endif
      endfor
    endfunction

    call InitializeDirectories()
    " }

    " Initialize NERDTree as needed {
    function! NERDTreeInitAsNeeded()
        redir => bufoutput
        buffers!
        redir END
        let idx = stridx(bufoutput, "NERD_tree")
        if idx > -1
            NERDTreeMirror
            NERDTreeFind
            wincmd l
        endif
    endfunction
    " }

    " Strip whitespace {
    function! StripTrailingWhitespace()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        %s/\s\+$//e
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction
    " }

    " Shell command {
    function! s:RunShellCommand(cmdline)
        botright new

        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nobuflisted
        setlocal noswapfile
        setlocal nowrap
        setlocal filetype=shell
        setlocal syntax=shell

        call setline(1, a:cmdline)
        call setline(2, substitute(a:cmdline, '.', '=', 'g'))
        execute 'silent $read !' . escape(a:cmdline, '%#')
        setlocal nomodifiable
        1
    endfunction

    command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
    " e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %
    " }

    function! s:ExpandFilenameAndExecute(command, file)
        execute a:command . " " . expand(a:file, ":p")
    endfunction

    """"""""""""""""""""""""""""""
    " => JavaScript section
    """""""""""""""""""""""""""""""
    function! JavaScriptFold()
      setl foldmethod=syntax
      setl foldlevelstart=1
      syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

      function! FoldText()
        return substitute(getline(v:foldstart), '{.*', '{...}', '''}')
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
      endif
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
" }

" Use local vimrc if available {
    if filereadable(expand("~/.vimrc.local"))
        source ~/.vimrc.local
    endif
" }

" Use local gvimrc if available and gui is running {
    if has('gui_running')
        if filereadable(expand("~/.gvimrc.local"))
            source ~/.gvimrc.local
        endif
    endif
" }

