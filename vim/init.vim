if has('nvim')
  set sh=zsh
  let g:python3_host_prog = substitute(system('which python3'),"\n","","")
  tnoremap <Esc> <C-\><C-n>
endif
"ファイルを読み込む際の文字コード
set fileencodings=utf-8,cp932,euc-jp,sjis,iso-2022-jp
set clipboard+=unnamedplus
set history=10000 "nvim-default
set mouse=a "nvim-default
set list
set listchars=tab:\¦\ ,trail:@,nbsp:%
"タブを押すと共通の文字列まで補完しステータスラインに
"補完候補を表示する。更にタブを押すと完全補完を行い
"タブで候補を変えていく。
set wildmenu "コマンドの補完を拡張 nvim-default
set wildmode=longest:full,full
"一行が余りにも長い場合に表示が抑制されるのを防ぐ
set display=lastline
"綴り修正
set spell
set spelllang=en,cjk
"grepを実行するとQuickFixリストを表示
augroup QuickFixConf
  autocmd!
  autocmd QuickFixCmdPost *grep* cwindow
augroup END

"ファイル-----------------------------------------------------------
set hidden "編集中でも他ファイルを開ける
set nobackup "バックアップ取らない
set nowritebackup
set noswapfile "スワップファイルを作らない
set autoread "外部でファイルが変更されたら自動で読み込み nvim-default
set undofile
set undodir=${XDG_CONFIG_HOME}/undo

"検索---------------------------------------------------------------
set incsearch "順次検索 nvim-default
set hlsearch "検索語をハイライト nvim-default
set ignorecase "大文字小文字区別なく検索
set smartcase "大文字が含まれていたら区別する
set wrapscan "最後まで行ったら最初に戻る
set inccommand=split "s/a/b/ ときなどに対話的になる

"外観---------------------------------------------------------------
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

"インデント---------------------------------------------------------
set smartindent "インデントを引き継ぐ
set expandtab "タブではなくスペースを挿入
set shiftwidth=2 "インデントに使われるスペース数
set tabstop=2 "タブをスペース2つに展開
set softtabstop=0 "タブで挿入される文字数(0ならtabstopの値)
set smarttab "nvim-default
set autoindent "nvim-default

"キーマップ---------------------------------------------------------
let mapleader = "\<space>"
"ESCと間違えて押すときがあるので無効化にする。
noremap <F1> <Nop>
noremap! <F1> <Nop>
"ESCを押した時にIMEを無効化
noremap <silent> <esc> <esc>:call system('fcitx-remote -c')<CR>
noremap! <silent> <esc> <esc>:call system('fcitx-remote -c')<CR>
" Blank line
nnoremap <Leader>j o<esc>
nnoremap <Leader>k O<esc>
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
" インサートモードでemacsのキーバインドを使う
noremap! <C-f> <esc>la
noremap! <C-b> <esc>i
noremap! <C-a> <esc>I
noremap! <C-e> <esc>A
noremap! <M-d> <esc>lx

noremap j gj
noremap k gk

noremap <C-j> 3j
noremap <C-k> 3k
" Moving cursor to other windows
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
"思いがけず強制終了してしまうのを阻止する
nnoremap ZQ <Nop>
"#を入力するとインデントが無効になるのを阻止する
inoremap # X#

"関数-------------------------------------------
function! s:removeTrailingBlanks()
  let line = line('.')
  let col = col('.')
  %s/\s\+$//
  call cursor(line, col)
endfunction
command! Rtb call s:removeTrailingBlanks()

"イベント-------------------------------------------
augroup go_conf
  autocmd!
  autocmd FileType go set noexpandtab
augroup END

augroup python_conf
  autocmd!
  "特定の文字列でインデントする
  autocmd FileType python set smartindent cinwords=
  \if,elif,else,for,while,try,except,finally,def,class,with
  autocmd FileType python set commentstring=\ #%s
augroup END

augroup html_conf
  autocmd!
  autocmd FileType html set commentstring=\ <!--\ %s\ -->
augroup END

augroup sh_conf
  autocmd!
  autocmd FileType sh set commentstring=\ #%s
augroup END

augroup vim_conf
  autocmd!
  autocmd FileType vim set commentstring=\ \"%s
augroup END

"プラグイン---------------------------------------------------------
if has('nvim')
  let s:dein_dir = $HOME . '/.cache/dein/'
  let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
  "プラグインマネージャが存在しなければインストール
  if &runtimepath !~# '/dein.vim'
    if !isdirectory(s:dein_repo_dir)
      call system('git clone https://github.com/Shougo/dein.vim ' . s:dein_repo_dir)
    endif
    execute 'set runtimepath+=' . s:dein_repo_dir
  endif
  "toml形式で別ファイルに記述しているプラグインを読み込む
  let s:toml_dir = s:dein_dir . '/toml/dein.toml'
  let s:toml_lazy_dir = s:dein_dir . '/toml/dein_lazy.toml'
  if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)
    call dein#load_toml(s:toml_dir,      {'lazy': 0})
    call dein#load_toml(s:toml_lazy_dir, {'lazy': 1})
    call dein#end()
    call dein#save_state()
  endif
  "インストールしていないものがあれば行う
  if dein#check_install()
    call dein#install()
  endif
  colorscheme one
endif
"filetype plugin indent on "vimがよしなにshiftwidthなどを変えてくる
syntax enable

"-------------------------------------------
"綴り誤りをアンダーラインで際立たせる
highlight clear SpellBad
highlight clear SpellCap
highlight clear SpellRare
highlight SpellBad cterm=underline
