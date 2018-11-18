" Vim tries to use the first mentioned character encoding.
set fileencodings=ucs-bom,utf-8,cp932,euc-jp,sjis,iso-2022-jp
" To ALWAYS use the clipboard for ALL operations
set clipboard+=unnamedplus
set history=10000 "nvim-default
set mouse=a "nvim-default
" command-line completion operates in an enhanced mode. nvim-default
set wildmenu
set wildmode=longest:full,full
" Wait for a mapped sequence to complete.(default: 1000)
set timeoutlen=5000

set autoread "外部でファイルが変更されたら自動で読み込み nvim-default
set hidden "編集中でも他ファイルを開ける
set nobackup
set nowritebackup
set noswapfile

set undofile
set undodir=${XDG_CONFIG_HOME}/nvim/undo
set undolevels=100
"==================================================
" Search
"==================================================
set incsearch "順次検索 nvim-default
set hlsearch "検索語をハイライト nvim-default
set ignorecase "大文字小文字区別なく検索
set smartcase "大文字が含まれていたら区別する
set wrapscan "最後まで行ったら最初に戻る
set inccommand=split "s/a/b/ ときなどに対話的になる
"==================================================
" Style
"==================================================
set background=dark
set number
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set showcmd "nvim-default
set showmatch "対応する括弧を表示(1秒)
set matchtime=1
set ambiwidth=double "記号が重なるのを阻止
set guicursor=a:block1,a:blinkoff1 "カーソルの形状
set cursorline cursorcolumn "カーソル行の強調
set foldmethod=marker foldmarker=>->,<-< "折り畳みの設定
"折り畳み時のマーカーをコメントする際に使う記号の設定
set commentstring=\ %s
set helpheight=100 "ヘルプ画面を大きく表示
set laststatus=2 "ステータスラインを常時表示 nvim-default
"一行が余りにも長い場合に表示が抑制されるのを防ぐ
set display=lastline
set list
set listchars=tab:\¦\ ,trail:@,nbsp:% "不可視文字
"==================================================
" Indent
"==================================================
set smartindent "インデントを引き継ぐ
set expandtab "タブではなくスペースを挿入
set shiftwidth=2 "インデントに使われるスペース数
set tabstop=2 "タブをスペース2つに展開
set softtabstop=0 "タブで挿入される文字数(0ならtabstopの値)
set smarttab "nvim-default
set autoindent "nvim-default
"==================================================
" Keybinding
"==================================================
let mapleader = "\<space>"
" disable
noremap <F1> <Nop>
noremap! <F1> <Nop>
" Blank line
nnoremap <silent> <leader><CR> :call append(line('.'), '')<CR>
nnoremap <silent> <leader>- :call append(line('.')-1, '')<CR>
"ウィンドウの大きさを変える比率を上げる
nnoremap <C-w>< 0<C-w><
nnoremap <C-w>> 0<C-w>>
nnoremap <C-w>- 0<C-w>-
nnoremap <C-w>+ 0<C-w>+
"completion
noremap! <C-x>n <C-x><C-n>
noremap! <C-x>p <C-x><C-p>
noremap! <C-x>l <C-x><C-l>
noremap! <C-x>f <C-x><C-f>
noremap! <C-x>s <C-x><C-s>
"入力された文字に一致するコマンドを履歴から補完する
cnoremap <M-p> <Up>
cnoremap <M-n> <Down>
" emacs key bindings
noremap! <C-f> <right>
noremap! <C-b> <left>
noremap! <C-a> <home>
noremap! <C-e> <end>
noremap! <C-d> <del>

noremap j gj
noremap k gk

noremap <C-j> 3j
noremap <C-k> 3k
" buffer (next|previous)
noremap <C-l> :bn<CR>
noremap <C-h> :bp<CR>
"思いがけず強制終了してしまうのを阻止する
noremap ZQ <Nop>
"#を入力するとインデントが無効になるのを阻止する
inoremap # X#
"==================================================
" Functions
"==================================================
" ! : can overwrite name
function! s:removeTrailingBlanks()
  let line = line('.')
  let col = col('.')
  %substitute/\s\+$//c
  call cursor(line, col)
endfunction
command! -nargs=0 Rb call s:removeTrailingBlanks()

function! s:closeAllOtherBuffers()
  1,.-bdelete
  .+,$bdelete
endfunction
command! -nargs=0 Ob call s:CloseAllOtherBuffers()

"==================================================
" Events
"==================================================
augroup Insert
  autocmd!
  autocmd InsertLeave * call system('fcitx-remote -c')
augroup END

augroup QuickFix
  autocmd!
  autocmd QuickFixCmdPost *grep* cwindow
augroup END

augroup ChangeBackground
  autocmd!
  autocmd FocusGained * highlight Normal guibg=default
  autocmd FocusLost * highlight Normal guibg='#27292d'
augroup END

augroup Go
  autocmd!
  autocmd FileType go set noexpandtab
augroup END

augroup Python
  autocmd!
  autocmd FileType python set cinwords=
    \if,elif,else,for,while,try,except,finally,def,class,with
  autocmd FileType python set commentstring=\ #%s
augroup END

augroup HTML
  autocmd!
  autocmd FileType html set commentstring=\ <!--\ %s\ -->
augroup END

augroup sh
  autocmd!
  autocmd FileType sh set commentstring=\ #%s
augroup END

augroup Vim
  autocmd!
  autocmd FileType vim set commentstring=\ \"%s
augroup END
"==================================================
" Plugins
"==================================================
let s:cache = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if &runtimepath !~# '/dein.vim' "Not install dein.vim
  if !isdirectory(s:dein_repo_dir)
    call system('git clone https://github.com/Shougo/dein.vim ' . s:dein_repo_dir)
  endif
  execute 'set runtimepath+=' . s:dein_repo_dir
endif
let s:toml_dir = s:dein_dir . '/toml/dein.toml'
let s:toml_lazy_dir = s:dein_dir . '/toml/dein_lazy.toml'
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#load_toml(s:toml_dir,      {'lazy': 0})
  call dein#load_toml(s:toml_lazy_dir, {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif
if dein#check_install()
  call dein#install()
endif
"==================================================
" neovim
"==================================================
if has('nvim')
  set sh=zsh
  let g:python3_host_prog = substitute(system('which python3'),"\n","","")
  tnoremap <Esc> <C-\><C-n>
endif
"==================================================
" Spell
"==================================================
" set spell
" set spelllang=en,cjk
" highlight clear SpellBad
" highlight SpellBad gui=underline
