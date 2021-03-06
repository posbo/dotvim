" vim: fdm=marker ts=2 sts=2 sw=2

" detect OS {{{
  let s:is_windows = has('win32') || has('win64')
  let s:is_cygwin = has('win32unix')
  let s:is_macvim = has('gui_macvim')
"}}}

" dotvim settings {{{
  if !exists('g:dotvim_settings')
    let g:dotvim_settings = {}
  endif

  " initialize default settings
  let s:settings = {}
  let s:settings.default_indent = 2
  let s:settings.max_column = 120
  let s:settings.autocomplete_method = 'neocomplcache'
  if has('patch885') && has('lua')
    let s:settings.autocomplete_method = 'neocomplete'
  elseif has('patch584') && filereadable(expand("~/.vim/bundle/YouCompleteMe/python/ycm_core.*"))
    let s:settings.autocomplete_method = 'ycm'
  endif

  let s:settings.plugin_groups = []
  call add(s:settings.plugin_groups, 'core')
  call add(s:settings.plugin_groups, 'web')
  call add(s:settings.plugin_groups, 'ruby')
  call add(s:settings.plugin_groups, 'scm')
  call add(s:settings.plugin_groups, 'editing')
  call add(s:settings.plugin_groups, 'visual')
  call add(s:settings.plugin_groups, 'indents')
  call add(s:settings.plugin_groups, 'navigation')
  call add(s:settings.plugin_groups, 'autocomplete')
  call add(s:settings.plugin_groups, 'misc')
  if s:is_windows
    call add(s:settings.plugin_groups, 'windows')
  endif

  for key in keys(s:settings)
    if has_key(g:dotvim_settings, key)
      let s:[key] = g:dotvim_settings[key]
    else
      let s:[key] = s:settings[key]
    endif
  endfor
"}}}

" setup & neobundle {{{
  set nocompatible
  if s:is_windows
    set rtp+=~/.vim
  endif
  set rtp+=~/.vim/bundle/neobundle.vim
  call neobundle#rc(expand('~/.vim/bundle/'))
  NeoBundleFetch 'Shougo/neobundle.vim'
"}}}

" functions {{{
  function! Preserve(command) "{{{
    " preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    execute a:command
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endfunction "}}}
  function! StripTrailingWhitespace() "{{{
    call Preserve("%s/\\s\\+$//e")
  endfunction "}}}
  function! EnsureExists(path) "{{{
    if !isdirectory(expand(a:path))
      call mkdir(expand(a:path))
    endif
  endfunction "}}}
  function! CloseWindowOrKillBuffer() "{{{
    let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))

    " never bdelete a nerd tree
    if matchstr(expand("%"), 'NERD') == 'NERD'
      wincmd c
      return
    endif

    if number_of_windows_to_this_buffer > 1
      wincmd c
    else
      bdelete
    endif
  endfunction "}}}
"}}}

" base configuration {{{
  set timeoutlen=300                                  "mapping timeout
  set ttimeoutlen=50                                  "keycode timeout

  set mouse=a                                         "enable mouse
  set mousehide                                       "hide when characters are typed
  set history=1000                                    "number of command lines to remember
  set ttyfast                                         "assume fast terminal connection
  set viewoptions=folds,options,cursor,unix,slash     "unix/windows compatibility
  set encoding=utf-8                                  "set encoding for text
  if exists('$TMUX')
    set clipboard=
  else
    set clipboard=unnamed                             "sync with OS clipboard
  endif
  set hidden                                          "allow buffer switching without saving
  set autoread                                        "auto reload if file saved externally
  set fileformats+=mac                                "add mac to auto-detection of file format line endings
  set nrformats-=octal                                "always assume decimal numbers
  set showcmd
  set tags=tags;/
  set showfulltag
  set keywordprg=":help"                              "remap K to vim help
  set modeline
  set modelines=5

  if s:is_windows && !s:is_cygwin
    " ensure correct shell in gvim
    set shell=c:\windows\system32\cmd.exe
  endif

  " whitespace
  set backspace=indent,eol,start                      "allow backspacing everything in insert mode
  set autoindent                                      "automatically indent to match adjacent lines
  set smartindent                                     "smart indenting for additional languages
  set expandtab                                       "spaces instead of tabs
  set smarttab                                        "use shiftwidth to enter tabs
  let &tabstop=s:default_indent                       "number of spaces per tab for display
  let &softtabstop=s:default_indent                   "number of spaces per tab in insert mode
  let &shiftwidth=s:default_indent                    "number of spaces when indenting
  set list                                            "highlight whitespace
  set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
  set shiftround
  set linebreak
  set showbreak=↪\ 

  set scrolloff=1                                     "always show content after scroll
  set scrolljump=5                                    "minimum number of lines to scroll
  set display+=lastline
  set wildmenu                                        "show list for autocomplete
  set wildmode=list:longest:full                      "priority for tab completion
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store

  set splitbelow
  set splitright

  " disable sounds
  set noerrorbells
  set novisualbell
  set t_vb=

  " searching
  set hlsearch                                        "highlight searches
  set incsearch                                       "incremental searching
  set ignorecase                                      "ignore case for searching
  set smartcase                                       "do case-sensitive if there's a capital letter
  if executable('ack')
    set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
    set grepformat=%f:%l:%c:%m
  endif
  if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
  endif

  " vim file/folder management {{{
    " persistent undo
    if exists('+undofile')
      set undofile
      set undodir=~/.vim/.cache/undo
    endif

    " backups
    set backup
    set backupdir=~/.vim/.cache/backup

    " swap files
    set directory=~/.vim/.cache/swap
    set noswapfile

    call EnsureExists('~/.vim/.cache')
    call EnsureExists(&undodir)
    call EnsureExists(&backupdir)
    call EnsureExists(&directory)
  "}}}

  let mapleader = ","
  let g:mapleader = ","
"}}}

" ui configuration {{{
  set showmatch                                       "automatically highlight matching braces/brackets/etc.
  set matchtime=2                                     "tens of a second to show matching parentheses
  set laststatus=2
  set number
  set lazyredraw
  set noshowmode
  set foldenable                                      "enable folds by default
  set foldmethod=syntax                               "fold via syntax of files
  set foldlevelstart=99                               "open all folds by default
  let g:xml_syntax_folding=1                          "enable xml folding

  set cursorline
  autocmd WinLeave * setlocal nocursorline
  autocmd WinEnter * setlocal cursorline
  " let &colorcolumn=s:max_column
  " set cursorcolumn
  " autocmd WinLeave * setlocal nocursorcolumn
  " autocmd WinEnter * setlocal cursorcolumn

  if has('conceal')
    set conceallevel=1
    set listchars+=conceal:Δ
  endif

  if has('gui_running')
    set lines=999 columns=999                         "open maximized
    set guioptions+=t                                 "tear off menu items
    set guioptions-=T                                 "toolbar icons

    if s:is_macvim
      set gfn=Ubuntu_Mono:h14
      set transparency=2
    endif

    if s:is_windows
      set gfn=Ubuntu_Mono:h10
    endif

    if has('gui_gtk')
      set gfn=Ubuntu\ Mono\ 11
    endif
  else
    set t_Co=256

    if $TERM_PROGRAM == 'iTerm.app'
      " different cursors for insert vs normal mode
      if exists('$TMUX')
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
      else
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
      endif
    endif
  endif
"}}}

" plugin/mapping configuration {{{
  if count(s:plugin_groups, 'core') "{{{
    NeoBundle 'matchit.zip'
    NeoBundle 'tpope/vim-surround'
    NeoBundle 'tpope/vim-repeat'
    NeoBundle 'tpope/vim-dispatch'
    NeoBundle 'tpope/vim-eunuch'
    NeoBundle 'tpope/vim-unimpaired' "{{{
      nmap <c-up> [e
      nmap <c-down> ]e
      vmap <c-up> [egv
      vmap <c-down> ]egv
    "}}}
    NeoBundleDepends 'Shougo/vimproc', {
      \ 'build': {
        \ 'mac': 'make -f make_mac.mak',
        \ 'unix': 'make -f make_unix.mak',
        \ 'cygwin': 'make -f make_cygwin.mak',
        \ 'windows': '"C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\nmake.exe" make_msvc32.mak',
      \ },
    \ }
  endif "}}}
  if count(s:plugin_groups, 'web') "{{{
    NeoBundle 'pangloss/vim-javascript'
    NeoBundle 'maksimr/vim-jsbeautify' "{{{
      nnoremap <leader>fjs :call JsBeautify()<cr>
    "}}}
    NeoBundle 'leafgarland/typescript-vim'
    NeoBundle 'kchmck/vim-coffee-script'
    NeoBundle 'groenewege/vim-less'
    NeoBundle 'mmalecki/vim-node.js'
    NeoBundle 'leshill/vim-json'
    NeoBundle 'cakebaker/scss-syntax.vim'
    NeoBundle 'hail2u/vim-css3-syntax'
    NeoBundle 'ap/vim-css-color'
    NeoBundle 'othree/html5.vim'
    NeoBundle 'gregsexton/MatchTag'
    NeoBundle 'wavded/vim-stylus'
    NeoBundle 'digitaltoad/vim-jade'
    NeoBundle 'juvenn/mustache.vim'
    NeoBundle 'mattn/zencoding-vim'
    " NeoBundle 'othree/javascript-libraries-syntax.vim' "{{{
      let g:used_javascript_libs='jquery,requirejs'
    "}}}
  endif "}}}
  if count(s:plugin_groups, 'ruby') "{{{
    NeoBundle 'tpope/vim-rails'
    NeoBundle 'tpope/vim-bundler'
  endif "}}}
  if count(s:plugin_groups, 'scm') "{{{
    " NeoBundle 'sjl/splice.vim'
    NeoBundle 'gregsexton/gitv'
    NeoBundle 'mhinz/vim-signify' "{{{
      let g:signify_update_on_bufenter=0
    "}}}
    NeoBundle 'tpope/vim-fugitive' "{{{
      nnoremap <silent> <leader>gs :Gstatus<CR>
      nnoremap <silent> <leader>gd :Gdiff<CR>
      nnoremap <silent> <leader>gc :Gcommit<CR>
      nnoremap <silent> <leader>gb :Gblame<CR>
      nnoremap <silent> <leader>gl :Glog<CR>
      nnoremap <silent> <leader>gp :Git push<CR>
      nnoremap <silent> <leader>gw :Gwrite<CR>
      nnoremap <silent> <leader>gr :Gremove<CR>
      autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>
      autocmd BufReadPost fugitive://* set bufhidden=delete
    "}}}
  endif "}}}
  if count(s:plugin_groups, 'autocomplete') "{{{
    NeoBundle 'teramako/jscomplete-vim'
    if s:autocomplete_method == 'ycm' "{{{
      NeoBundle 'Valloric/YouCompleteMe' "{{{
        let g:ycm_complete_in_comments_and_strings=1
        let g:ycm_key_list_select_completion=['<C-n>', '<Down>']
        let g:ycm_key_list_previous_completion=['<C-p>', '<Up>']
        let g:ycm_filetype_blacklist={'unite': 1}
      "}}}
      NeoBundle 'SirVer/ultisnips' "{{{
        let g:UltiSnipsExpandTrigger="<tab>"
        let g:UltiSnipsJumpForwardTrigger="<tab>"
        let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
        let g:UltiSnipsSnippetsDir='~/.vim/snippets'
      "}}}
    else
      NeoBundle 'Shougo/neosnippet' "{{{
        let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim/snippets'
        let g:neosnippet#enable_snipmate_compatibility=1

        imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ? "\<C-n>" : "\<TAB>")
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
        imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
        smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
      "}}}
    endif "}}}
    if s:autocomplete_method == 'neocomplete' "{{{
      NeoBundle 'Shougo/neocomplete.vim' "{{{
        let g:neocomplete#enable_at_startup=1
        let g:neocomplete#data_directory='~/.vim/.cache/neocomplete'
        let g:neocomplete#enable_auto_delimiter=1
      "}}}
    endif "}}}
    if s:autocomplete_method == 'neocomplcache' "{{{
      NeoBundle 'Shougo/neocomplcache' "{{{
        let g:neocomplcache_enable_at_startup=1
        let g:neocomplcache_enable_auto_delimiter=1
        " let g:neocomplcache_force_overwrite_completefunc=1
        " let g:neocomplcache_auto_completion_start_length=1
        let g:neocomplcache_max_list=10
        let g:neocomplcache_temporary_dir='~/.vim/.cache/neocon'
        " let g:neocomplcache_enable_auto_select=1
        " let g:neocomplcache_enable_cursor_hold_i=1
        " let g:neocomplcache_cursor_hold_i_time=300
        let g:neocomplcache_enable_fuzzy_completion=1

        if !exists('g:neocomplcache_omni_functions')
          let g:neocomplcache_omni_functions = {}
        endif

        " enable general omni completion
        let g:neocomplcache_omni_functions.css      = 'csscomplete#CompleteCSS'
        let g:neocomplcache_omni_functions.html     = 'htmlcomplete#CompleteTags'
        let g:neocomplcache_omni_functions.markdown = 'htmlcomplete#CompleteTags'
        let g:neocomplcache_omni_functions.python   = 'pythoncomplete#Complete'
        let g:neocomplcache_omni_functions.xml      = 'xmlcomplete#CompleteTags'
        let g:neocomplcache_omni_functions.ruby     = 'rubycomplete#Complete'

        " js completion
        let g:jscomplete_use = [ 'dom' ]
        let g:neocomplcache_omni_functions.javascript = 'jscomplete#CompleteJS'
      "}}}
    endif "}}}
    NeoBundle 'honza/vim-snippets'
  endif "}}}
  if count(s:plugin_groups, 'editing') "{{{
    NeoBundle 'editorconfig/editorconfig-vim'
    NeoBundle 'tpope/vim-speeddating'
    NeoBundle 'tomtom/tcomment_vim'
    NeoBundle 'terryma/vim-expand-region'
    NeoBundle 'terryma/vim-multiple-cursors'
    NeoBundle 'chrisbra/NrrwRgn'
    NeoBundle 'dahu/vim-fanfingtastic'
    NeoBundle 'godlygeek/tabular' "{{{
      nmap <Leader>a& :Tabularize /&<CR>
      vmap <Leader>a& :Tabularize /&<CR>
      nmap <Leader>a= :Tabularize /=<CR>
      vmap <Leader>a= :Tabularize /=<CR>
      nmap <Leader>a: :Tabularize /:<CR>
      vmap <Leader>a: :Tabularize /:<CR>
      nmap <Leader>a:: :Tabularize /:\zs<CR>
      vmap <Leader>a:: :Tabularize /:\zs<CR>
      nmap <Leader>a, :Tabularize /,<CR>
      vmap <Leader>a, :Tabularize /,<CR>
      nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
      vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    "}}}
    NeoBundle 'Raimondi/delimitMate' "{{{
      let delimitMate_expand_cr=1
      au FileType markdown,vim let b:loaded_delimitMate=1
    "}}}
    " EasyMotion {{{
      " NeoBundle 'Lokaltog/vim-easymotion'
      NeoBundle 'skwp/vim-easymotion'
      let g:EasyMotion_keys = 'asdfghjklqwertyuiopzxcvbnm'

      autocmd ColorScheme * highlight EasyMotionTarget ctermfg=32 guifg=#0087df
      autocmd ColorScheme * highlight EasyMotionShade ctermfg=237 guifg=#3a3a3a
    "}}}
  endif "}}}
  if count(s:plugin_groups, 'navigation') "{{{
    NeoBundle 'EasyGrep' "{{{
      let g:EasyGrepRecursive=1
      let g:EasyGrepAllOptionsInExplorer=1
      let g:EasyGrepCommand=1
    "}}}
    NeoBundle 'sjl/gundo.vim' "{{{
      let g:gundo_right=1
      nnoremap <silent> <F5> :GundoToggle<CR>
    "}}}
    NeoBundle 'kien/ctrlp.vim', { 'depends': 'tacahiroy/ctrlp-funky' } "{{{
      let g:ctrlp_clear_cache_on_exit=1
      let g:ctrlp_max_height=40
      let g:ctrlp_show_hidden=0
      let g:ctrlp_follow_symlinks=1
      let g:ctrlp_working_path_mode=0
      let g:ctrlp_max_files=20000
      let g:ctrlp_cache_dir='~/.vim/.cache/ctrlp'
      let g:ctrlp_extensions=['funky']

      nmap \ [ctrlp]
      nnoremap [ctrlp] <nop>

      nnoremap [ctrlp]t :CtrlPBufTag<cr>
      nnoremap [ctrlp]T :CtrlPTag<cr>
      nnoremap [ctrlp]l :CtrlPLine<cr>
      nnoremap [ctrlp]o :CtrlPFunky<cr>
      nnoremap [ctrlp]b :CtrlPBuffer<cr>
    "}}}
    NeoBundle 'Shougo/unite.vim', { 'depends': ['tsukkee/unite-tag','Shougo/unite-outline'] } "{{{
      call unite#filters#matcher_default#use(['matcher_fuzzy'])
      call unite#filters#sorter_default#use(['sorter_rank'])
      call unite#set_profile('files', 'smartcase', 1)

      let g:unite_data_directory='~/.vim/.cache/unite'
      let g:unite_enable_start_insert=1
      let g:unite_source_history_yank_enable=1
      let g:unite_source_file_rec_max_cache_files=5000
      let g:unite_prompt='» '

      if executable('ag')
        let g:unite_source_grep_command='ag'
        let g:unite_source_grep_default_opts='--nocolor --nogroup --hidden'
        let g:unite_source_grep_recursive_opt=''
      elseif executable('ack')
        let g:unite_source_grep_command='ack'
        let g:unite_source_grep_default_opts='--no-heading --no-color -a'
        let g:unite_source_grep_recursive_opt=''
      endif

      function! s:unite_settings()
        nmap <buffer> Q <plug>(unite_exit)
        nmap <buffer> <esc> <plug>(unite_exit)
        imap <buffer> <esc> <plug>(unite_exit)
      endfunction
      autocmd FileType unite call s:unite_settings()

      nmap <space> [unite]
      nnoremap [unite] <nop>

      if s:is_windows
        nnoremap <silent> [unite]<space> :<C-u>Unite -resume -auto-resize -buffer-name=mixed file_rec buffer file_mru bookmark<cr><c-u>
        nnoremap <silent> [unite]f :<C-u>Unite -resume -auto-resize -buffer-name=files file_rec<cr><c-u>
      else
        nnoremap <silent> [unite]<space> :<C-u>Unite -resume -auto-resize -buffer-name=mixed file_rec/async buffer file_mru bookmark<cr><c-u>
        nnoremap <silent> [unite]f :<C-u>Unite -resume -auto-resize -buffer-name=files file_rec/async<cr><c-u>
      endif
      nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
      nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
      nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
      nnoremap <silent> [unite]/ :<C-u>Unite -auto-resize -buffer-name=search grep:.<cr>
      nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
      nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>
      nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>
    "}}}
    " NeoBundle 'Shougo/vimfiler' "{{{
    "   let g:vimfiler_as_default_explorer=1
    "   let g:vimfiler_data_directory='~/.vim/.cache/vimfiler'
    "   nnoremap <F2> :VimFilerExplorer<CR>
    "   nnoremap <F3> :VimFilerBufferDir --explorer<CR>
    " "}}}
    NeoBundle 'scrooloose/nerdtree' "{{{
      let NERDTreeShowHidden=1
      let NERDTreeQuitOnOpen=0
      let NERDTreeShowLineNumbers=1
      let NERDTreeChDirMode=0
      let NERDTreeShowBookmarks=1
      let NERDTreeIgnore=['\.git','\.hg']
      let NERDTreeBookmarksFile='~/.vim/.cache/NERDTreeBookmarks'
      nnoremap <F2> :NERDTreeToggle<CR>
      nnoremap <F3> :NERDTreeFind<CR>
    "}}}
    NeoBundle 'majutsushi/tagbar' "{{{
      nnoremap <silent> <F9> :TagbarToggle<CR>
    "}}}
  endif "}}}
  if count(s:plugin_groups, 'visual') "{{{
    NeoBundle 'bling/vim-bufferline' "{{{
      let g:bufferline_echo=0
      let g:bufferline_rotate=1
    "}}}
    " NeoBundle 'Lokaltog/powerline', { 'rtp': 'powerline/bindings/vim' }
    " NeoBundle 'zhaocai/linepower.vim'
    " NeoBundle 'myusuf3/numbers.vim', { 'gui': 1 }
    NeoBundle 'kshenoy/vim-signature'
    " NeoBundle 'zhaocai/GoldenView.Vim' "{{{
      let g:goldenview__enable_default_mapping=0
      nmap <F4> <Plug>ToggleGoldenViewAutoResize
    "}}}
    NeoBundle 'roman/golden-ratio' "{{{
      let g:golden_ratio_autocommand=0
      let g:golden_ratio_wrap_ignored=0
      nnoremap <F4> :GoldenRatioToggle<cr>
    "}}}
  endif "}}}
  if count(s:plugin_groups, 'indents') "{{{
    NeoBundle 'nathanaelkane/vim-indent-guides' "{{{
      let g:indent_guides_start_level=1
      let g:indent_guides_guide_size=1
      let g:indent_guides_enable_on_vim_startup=1
      let g:indent_guides_color_change_percent=3
      if !has('gui_running')
        let g:indent_guides_auto_colors=0
        autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd ctermbg=235
        autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=236
      endif
    "}}}
  endif "}}}
  if count(s:plugin_groups, 'misc') "{{{
    NeoBundle 'tpope/vim-markdown'
    if executable('redcarpet') && executable('instant-markdown-d')
      NeoBundle 'suan/vim-instant-markdown'
    endif
    NeoBundle 'guns/xterm-color-table.vim'
    NeoBundle 'vimwiki'
    NeoBundle 'bufkill.vim'
    NeoBundle 'mhinz/vim-startify' "{{{
      let g:startify_session_dir = '~/.vim/.cache/sessions'
      let g:startify_show_sessions = 1
    "}}}
    NeoBundle 'scrooloose/syntastic' "{{{
      let g:syntastic_error_symbol = '✗'
      let g:syntastic_style_error_symbol = '✠'
      let g:syntastic_warning_symbol = '∆'
      let g:syntastic_style_warning_symbol = '≈'
    "}}}
    NeoBundle 'mattn/gist-vim', { 'depends': 'mattn/webapi-vim' } "{{{
      let g:gist_post_private=1
      let g:gist_show_privates=1
    "}}}
    NeoBundle 'Shougo/vimshell' "{{{
      if s:is_macvim
        let g:vimshell_editor_command='mvim'
      else
        let g:vimshell_editor_command='vim'
      endif
      let g:vimshell_right_prompt='getcwd()'
      let g:vimshell_temporary_directory='~/.vim/.cache/vimshell'
      let g:vimshell_vimshrc_path='~/.vim/vimshrc'

      nnoremap <leader>c :VimShell -split<cr>
    "}}}
  endif "}}}
  if count(s:plugin_groups, 'windows') "{{{
    NeoBundle 'PProvost/vim-ps1'
    NeoBundle 'OrangeT/vim-csharp'
  endif "}}}

  nnoremap <leader>nbu :Unite neobundle/update -no-start-insert<cr>
"}}}

" mappings {{{
  " formatting shortcuts
  nmap <leader>fef :call Preserve("normal gg=G")<CR>
  nmap <leader>f$ :call StripTrailingWhitespace()<CR>
  vmap <leader>s :sort<cr>

  " toggle paste
  map <F6> :set invpaste<CR>:set paste?<CR>

  " remap arrow keys
  nnoremap <down> :bprev<CR>
  nnoremap <up> :bnext<CR>
  nnoremap <left> :tabnext<CR>
  nnoremap <right> :tabprev<CR>

  " smash escape
  inoremap jk <esc>
  inoremap kj <esc>

  " change cursor position in insert mode
  inoremap <C-h> <left>
  inoremap <C-l> <right>

  if mapcheck('<space>/') == ''
    nnoremap <space>/ :vimgrep //gj **/*<left><left><left><left><left><left><left><left>
  endif

  " sane regex {{{
    nnoremap / /\v
    vnoremap / /\v
    nnoremap ? ?\v
    vnoremap ? ?\v
    cnoremap s/ s/\v
  "}}}

  " folds {{{
    nnoremap zr zr:echo &foldlevel<cr>
    nnoremap zm zm:echo &foldlevel<cr>
    nnoremap zR zR:echo &foldlevel<cr>
    nnoremap zM zM:echo &foldlevel<cr>
  " }}}

  " screen line scroll
  nnoremap <silent> j gj
  nnoremap <silent> k gk

  " auto center {{{
    nnoremap <silent> n nzz
    nnoremap <silent> N Nzz
    nnoremap <silent> * *zz
    nnoremap <silent> # #zz
    nnoremap <silent> g* g*zz
    nnoremap <silent> g# g#zz
    nnoremap <silent> <C-o> <C-o>zz
    nnoremap <silent> <C-i> <C-i>zz
  "}}}

  " reselect visual block after indent
  vnoremap < <gv
  vnoremap > >gv

  " reselect last paste
  nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

  " find current word in quickfix
  nnoremap <leader>fw :execute "vimgrep ".expand("<cword>")." %"<cr>:copen<cr>
  " find last search in quickfix
  nnoremap <leader>ff :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>

  " shortcuts for windows {{{
    nnoremap <leader>v <C-w>v<C-w>l
    nnoremap <leader>s <C-w>s
    nnoremap <leader>vsa :vert sba<cr>
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l
  "}}}

  " tab shortcuts
  map <leader>tn :tabnew<CR>
  map <leader>tc :tabclose<CR>

  " make Y consistent with C and D. See :help Y.
  nnoremap Y y$

  " hide annoying quit message
  nnoremap <C-c> <C-c>:echo<cr>

  " window killer
  nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>

  " quick buffer open
  nnoremap <leader>o :ls<cr>:e #

  if neobundle#is_sourced('vim-dispatch')
    nnoremap <leader>tag :Dispatch ctags -R<cr>
  endif

  " general
  nmap <leader>l :set list! list?<cr>
  noremap <cr> :set hlsearch! hlsearch?<cr>

  map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
        \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
        \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

  " helpers for profiling {{{
    nnoremap <silent> <leader>DD :exe ":profile start profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
    nnoremap <silent> <leader>DP :exe ":profile pause"<cr>
    nnoremap <silent> <leader>DC :exe ":profile continue"<cr>
    nnoremap <silent> <leader>DQ :exe ":profile pause"<cr>:noautocmd qall!<cr>
  "}}}
"}}}

" autocmd {{{
  " go back to previous position of cursor if any
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \  exe 'normal! g`"zvzz' |
    \ endif

  autocmd FileType js,scss,css autocmd BufWritePre <buffer> call StripTrailingWhitespace()
  autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
  autocmd FileType css,scss nnoremap <silent> <leader>S vi{:sort<CR>
  autocmd FileType python setlocal foldmethod=indent
"}}}

" vundle rtp load sequence requires the filetypes to be loaded after all bundles are loaded
filetype off
filetype plugin indent on
syntax enable

" color schemes {{{
  NeoBundle 'altercation/vim-colors-solarized'
  NeoBundle 'nanotech/jellybeans.vim'
  NeoBundle 'tomasr/molokai'
  NeoBundle 'chriskempson/vim-tomorrow-theme'
  NeoBundle 'w0ng/vim-hybrid'
  NeoBundle 'sjl/badwolf'
  NeoBundle 'jelera/vim-gummybears-colorscheme'
  NeoBundle 'zeis/vim-kolor' "{{{
    let g:kolor_underlined=1
  "}}}

  autocmd ColorScheme * highlight Normal guibg=#121212 ctermbg=233
  autocmd ColorScheme * highlight SignColumn ctermfg=244 ctermbg=232 guifg=#808080 guibg=#080808
  " autocmd ColorScheme * highlight Pmenu guibg=#000000 ctermbg=232
  colorscheme gummybears
"}}}

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

NeoBundleCheck
