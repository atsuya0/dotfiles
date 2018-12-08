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
set lazyredraw " the screen will not be redrawn while executing macros, registers and other commands that have not been typed.
set autoread "外部でファイルが変更されたら自動で読み込み nvim-default
set hidden "編集中でも他ファイルを開ける
set nobackup
set nowritebackup
set noswapfile

if has('nvim')
  set sh=zsh
  let g:python3_host_prog = substitute(system('which python3'),"\n","","")
  tnoremap <Esc> <C-\><C-n>
endif
"==================================================
" undo
"==================================================
set undofile
set undolevels=100
if has('nvim')
  set undodir=$XDG_CONFIG_HOME/nvim/undo
else
  set undodir=$HOME/.vim/undo
endif
"==================================================
" Search
"==================================================
set incsearch "順次検索 nvim-default
set hlsearch "検索語をハイライト nvim-default
set ignorecase "大文字小文字区別なく検索
set smartcase "大文字が含まれていたら区別する
set wrapscan "最後まで行ったら最初に戻る
if has('nvim')
  set inccommand=split "s/a/b/ ときなどに対話的になる
endif
"==================================================
" Style
"==================================================
set background=dark
set number
set relativenumber
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
" Functions and Commands
"==================================================
function! s:removeTrailingBlanks()
  let line = line('.')
  let col = col('.')
  %substitute/\s\+$//c
  call cursor(line, col)
endfunction
command! -nargs=0 RemoveTrailingBlanks call s:removeTrailingBlanks()

command! -nargs=0 OnlyCurrentBuf 1,.-bdelete | .+,$bdelete

function! s:changeFocus()
  for buf in getbufinfo()
    if buf.name =~ '\[denite\]$'
      return
    endif
  endfor
  highlight Normal guibg=default
  highlight NormalNC guibg='#27292d'
endfunction

"==================================================
" Keybinding
"==================================================
let mapleader = "\<space>"
" Disable
noremap <F1> <Nop>
noremap! <F1> <Nop>
noremap ZQ <Nop>
" Insert blank line.
nnoremap <silent> <C-s>j o<esc>
nnoremap <silent> <C-s>k :call append(line('.')-1, '')<CR>
" Insert space.
nnoremap <silent> <C-s>h i<space><esc>
nnoremap <silent> <C-s>l a<space><esc>
"ウィンドウの大きさを変える比率を上げる
nnoremap <C-w>< 0<C-w><
nnoremap <C-w>> 0<C-w>>
nnoremap <C-w>- 0<C-w>-
nnoremap <C-w>+ 0<C-w>+
" Completion
noremap! <C-x>n <C-x><C-n>
noremap! <C-x>p <C-x><C-p>
noremap! <C-x>l <C-x><C-l>
noremap! <C-x>f <C-x><C-f>
noremap! <C-x>s <C-x><C-s>
"入力された文字に一致するコマンドを履歴から補完する
cnoremap <M-p> <Up>
cnoremap <M-n> <Down>
" Emacs key bindings
" <C-h>, <C-w>, <C-u>
noremap! <C-f> <right>
noremap! <C-b> <left>
noremap! <C-a> <C-o>^
noremap! <C-e> <end>
noremap! <C-n> <down>
noremap! <C-p> <up>
noremap! <C-d> <del>
noremap! <C-k> <C-o>d$
noremap! <C-y> <C-o>p
noremap! <M-f> <C-o>w
noremap! <M-b> <C-o>b
noremap! <M-d> <C-o>dw
" Move the cursor up or down.
noremap j gj
noremap k gk
noremap <C-j> 3j
noremap <C-k> 3k
" Go to next or previous buffer.
noremap <C-l> :bn<CR>
noremap <C-h> :bp<CR>
" // -> /\/
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
"==================================================
" Events
"==================================================
augroup IME
  autocmd!
  autocmd InsertLeave * call system('fcitx-remote -c')
augroup END

augroup ChangeFocus
  autocmd!
  autocmd WinEnter * call s:changeFocus()
  autocmd FocusGained * highlight Normal guibg=default
  autocmd FocusLost * highlight Normal guibg='#27292d'
augroup END

augroup QuickFix
  autocmd!
  autocmd QuickFixCmdPost *grep* cwindow
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
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir) " Download dein.vim
    call system('git clone https://github.com/Shougo/dein.vim ' . s:dein_repo_dir)
  endif
  execute 'set runtimepath+=' . s:dein_repo_dir
endif
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#load_toml(s:dein_dir . '/toml/dein.toml',      {'lazy': 0})
  call dein#load_toml(s:dein_dir . '/toml/dein_lazy.toml', {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif
if dein#check_install()
  call dein#install()
endif

"==================================================
" Spell
"==================================================
" set spell
" set spelllang=en,cjk
" highlight clear SpellBad
" highlight SpellBad gui=underline
