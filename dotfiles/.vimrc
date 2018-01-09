set nocompatible " (Neovim Default)

" Vim-Plug Setup
call plug#begin('~/.vim/plugged')
    " Colorschemes
    Plug 'jonathanfilip/vim-lucius'
        let g:lucius_style = 'dark'
        let g:lucius_contrast = 'low'
        let g:lucius_contrast_bg = 'high'
    Plug 'https://bitbucket.org/kisom/eink.vim.git'
    Plug 'robertmeta/nofrils'
    Plug 'ggustafsson/Static-Color-Scheme'

    " Editing Behavior
    Plug 'editorconfig/editorconfig-vim'
    Plug 'Raimondi/delimitMate'
        let delimitMate_expand_cr    = 1
        let delimitMate_expand_space = 1
        au FileType python       let b:delimitMate_nesting_quotes = ['"', "'"]
        au FileType markdown,mkd let b:delimitMate_nesting_quotes = ['`']
        au FileType clojure      let b:delimitMate_quotes = '"'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-surround'

    " Features
    Plug 'mattn/emmet-vim'
        let g:user_emmet_install_global = 0
        au FileType html,css EmmetInstall
    Plug 'scrooloose/nerdtree'
        map <leader>f :NERDTreeToggle<CR>
        let g:NERDTreeRespectWildIgnore = 1
    Plug 'majutsushi/tagbar'
        map <leader>t :TagbarToggle<CR>

    Plug 'neomake/neomake'
        au BufWritePost * Neomake
        let g:neomake_open_list = 2
        let g:neomake_list_height = 7
        let g:neomake_error_sign = {'text': '✖', 'texthl': 'ErrorMsg'}
        let g:neomake_warning_sign = {'text': '❢', 'texthl': 'WarningMsg'}
        let g:neomake_message_sign = {'text': '➤', 'texthl': 'MoreMsg'}
        let g:neomake_info_sign = {'text': 'ℹ', 'texthl': 'ModeMsg'}

        let g:neomake_python_pylama_args = ["--linters", "pyflakes,pep8,pydocstyle,mccabe", "--ignore", "D213"]
        let g:neomake_sh_shellcheck_args = ["-f", "gcc", "-x"]
    Plug 'fmoralesc/vim-pad'
        let g:pad#dir = '~/.vim-pad'

    " File Types
    " See sheerun/vim-polyglot for more suggestions
    Plug 'cespare/vim-toml'
    Plug 'fatih/vim-go'
        let g:go_fmt_fail_silently = 1
        au BufRead,BufNewFile *.sigil setlocal filetype=gotexttmpl
    Plug 'hail2u/vim-css3-syntax'
        au BufRead,BufNewFile *.css setlocal filetype=scss
    Plug 'hdima/python-syntax'
    Plug 'hynek/vim-python-pep8-indent'
    Plug 'kballard/vim-fish'
    Plug 'lambdatoast/elm.vim'
    Plug 'othree/yajs.vim'
    Plug 'othree/es.next.syntax.vim'
    Plug 'lambdatoast/elm.vim'
    Plug 'othree/html5.vim'
    Plug 'plasticboy/vim-markdown'
    Plug 'raichoo/purescript-vim'
    Plug 'rust-lang/rust.vim'
    Plug 'tpope/vim-git'
    Plug 'vimoutliner/vimoutliner'
    Plug 'yosssi/vim-ace'

    " == Still Evaluating ==

    " -- Miscellaneous --

    Plug 'junegunn/rainbow_parentheses.vim'
        au FileType lisp,clojure,scheme RainbowParentheses
    Plug 'simnalamburt/vim-mundo'
        nnoremap <leader>u :GundoToggle<CR>
    Plug 'junegunn/goyo.vim'
    Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
    Plug 'tpope/vim-fireplace'

    " -- Completion --

    " TODO: re-enable --clang-completer at some point
    Plug 'Valloric/YouCompleteMe', { 'do': './install.py --tern-completer --gocode-completer --racer-completer' }
        let g:ycm_rust_src_path = '/usr/local/src/rust/current/src'
        let g:ycm_python_binary_path = '/usr/bin/python3'
        let g:ycm_autoclose_preview_window_after_insertion = 1
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'ervandew/supertab'
        " make YCM compatible with UltiSnips (using supertab)
        let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
        let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
        let g:SuperTabDefaultCompletionType = '<C-n>'

        " better key bindings for UltiSnipsExpandTrigger
        let g:UltiSnipsExpandTrigger = "<tab>"
        let g:UltiSnipsJumpForwardTrigger = "<tab>"
        let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

    " -- File / Filename Searching --

    Plug 'mileszs/ack.vim'
        if executable('ag')
            let g:ackprg = 'ag --vimgrep'
        endif

    Plug 'ctrlpvim/ctrlp.vim'
        if executable('ag')
            let g:ctrlp_user_command = 'ag -l --nocolor -g "" %s'
            let g:ctrlp_use_caching = 0
        endif

    "Plug 'Shougo/unite.vim'
    "    let g:unite_source_rec_async_command = ['ag', '--follow', '--vimgrep', '--hidden', '--ignore-case', '-g', '']
    "    let g:unite_source_grep_command = 'ag'
    "    let g:unite_source_grep_default_opts = '--vimgrep --hidden --smart-case'
    "    let g:unite_source_grep_recursive_opt = 'j
    "Plug 'Shougo/vimproc.vim', { 'do': 'make' }

    " -- Git integration --

    "Plug 'tpope/vim-fugitive'
    "Plug 'gregsexton/gitv'
    "Plug 'airblade/vim-gitgutter'

    " -- Wiki / Taskwarrior Integration --

    Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
        let g:vimwiki_auto_chdir = 1
    Plug 'tbabej/taskwiki'
        let g:taskwiki_disable_concealcursor = 'yes'
    Plug 'powerman/vim-plugin-AnsiEsc'
    Plug 'blindFS/vim-taskwarrior'

call plug#end()

" Appearance
syntax on " (Neovim Default)
set background=dark
colorscheme lucius
set ruler
set colorcolumn=81
set nofoldenable
set showcmd
set ttyfast " (Neovim Default)
set listchars=trail:·,precedes:«,extends:»,nbsp:_,tab:▸· " More: ⌇ ► ▸ ❯ ⇥
set list

" Searching
set hlsearch " (Neovim Default)
set incsearch " (Neovim Default)
set ignorecase
set smartcase

" Behavior
if filereadable($VIMRUNTIME . "/macros/matchit.vim")
    source $VIMRUNTIME/macros/matchit.vim
endif
set backspace=indent,eol,start " (Neovim Default)
set mouse=a "Enables the mouse in terminals (Neovim Default)
set completeopt+=longest
set clipboard=unnamedplus
set wildmode=longest:full,full

" Editing Defaults
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=80
set smarttab " (Neovim Default)
set expandtab
set copyindent
set smartindent
inoremap # X<C-H>#

" File Globbing
set wildignore+=*.py[co]
set wildignore+=*.sw[po]
set wildignore+=.DS_Store
set wildignore+=[Tt]humbs.db
set wildignore+=*.6
set wildignore+=node_modules/*

" Misc
au FileType markdown,text setlocal spell textwidth=0 linebreak
au FileType markdown,text nnoremap j gj
au FileType markdown,text nnoremap gj j
au FileType markdown,text nnoremap k gk
au FileType markdown,text nnoremap gk k
au FileType markdown,text nnoremap $ g$
au FileType markdown,text nnoremap g$ $
au FileType markdown,text nnoremap ^ g^
au FileType markdown,text nnoremap g^ ^
au FileType markdown,text nnoremap 0 g0
au FileType markdown,text nnoremap g0 0
au FileType mail setlocal formatoptions+=aw textwidth=72 colorcolumn=+1 spell nomodeline
au FileType votl,go,make setlocal nolist
au FileType gitcommit setlocal colorcolumn+=51
au FileType javascript setlocal foldmethod=syntax foldlevelstart=1 |
  \ syntax region foldBraces start=/{/ end=/}/ transparent fold keepend extend
au FileType rust compiler cargo
au BufRead,BufNewFile Cargo.toml,Cargo.lock compiler cargo
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
set backupcopy=yes
