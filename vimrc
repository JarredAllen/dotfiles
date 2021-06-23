"
" A vimrc file which sets reasonable defaults and other things that I like
" Written by: Jarred Allen
"

" Disable some VI-compatibility features
set nocompatible

" Disabling built-in filetype for autocomplete plugins to take over
filetype off

" Commands for running Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Vundle plugins
" Having Vundle and vim-plug are probably redundant, but I'm too lazy to fix
" this.

" Local vimrc (have vimrc commands for a specific directory tree)
Plugin 'LucHermitte/lh-vim-lib'
Plugin 'LucHermitte/local_vimrc'

" Vim Surround (Provide nice options for surrounding things with parens,
" changing the parens around a thing, &c)
Plugin 'tpope/vim-surround'
" Vim Repeat (idk what it does, but it ain't broke, so I'm not fixing it)
Plugin 'tpope/vim-repeat'

" Vim Autoformat (automatically format files properly on write)
Plugin 'Chiel92/vim-autoformat'

" JuliaEditorSupport plugin (do nice things with Julia)
Plugin 'JuliaEditorSupport/julia-vim'
" Disable tab replacement of latex unicode specifiers (it breaks coc.nvim autocomplete)
let g:latex_to_unicode_tab = 0
" Enable autoreplacement of latex unicode specifiers
let g:latex_to_unicode_auto = 1

" coc.nvim (autocompletion with Language Server Protocol)
Plugin 'neoclide/coc.nvim', {'branch': 'release'}

" Finishing up Vundle
call vundle#end()

" Automatically format files on write, but don't autoindent as fallback
" (vim autoindent can be weird if an unknown filetype is used).
" It will still retab and remove trailing whitespace for unknown files.
"
" To autoindent a file, type `gg=G` in normal mode
let g:autoformat_autoindent = 0
au BufWrite * :Autoformat

" Configuration options for coc.nvim
set hidden
set nobackup
set nowritebackup
set updatetime=300 " in ms. Longer time = slower user experience
set shortmess+=c
set signcolumn=number " One column for errors and line numbers. Also keeps column present always
" Use tabs to autocomplete code
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" Navigation GoTos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use `K` to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" Highlight the current symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)
" Use CTRL-S for selections ranges
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
" Put info into the statusline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
" Set errors and warnings to show up in black font for legibility
highlight CocErrorSign ctermfg=Black guifg=#000000
highlight CocWarningSign ctermfg=Black guifg=#000000
highlight CocInfoSign ctermfg=Black guifg=#000000


" Enable syntax highlighting
syntax on

" Enable tab autocompletion in command environment
set wildmenu
" Increases the height of the command window to 2
set cmdheight=2
" Shows the last command in the bottom of the screen
set showcmd


" When searching, ignore case unless the search text contains upper-case
" letters. Also, don't highlight the thing being searched.
set ignorecase
set smartcase
set nohlsearch


" Allow one backspace to go over a line's indentation and the line break.
" Useful for writing code with indentation
set backspace=indent,eol,start
" Automatically try to set the correct indentation in real time
set autoindent
" Have Vim interpret tabs as 4 spaces wide and replace tabs with spaces
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" Options suggested in /etc/vim/vimrc
set showmatch       " Show matching brackets.
set autowrite       " Automatically save before commands like :next and :make

" Show line number on current line and relative line numbers on all other
" lines
set number
set relativenumber
" Move the window if the cursor gets within 2 lines of the edge
" Useful for always being able to see the context of the cursor location
set scrolloff=2


" Assign :W to be the same as :w (and :Wq as :wq), because I make that typo a lot
command W w
command Wq wq

" Assign :WS to writing with sudo
command WS w !sudo tee %

" Better folding behavior by default
autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" Avoids redrawing inside of a macro, to speed it up
set lazyredraw

" Preserve undo for each file when Vim is closed
set undofile

" Make Q repeat the previous macro
nnoremap Q @@

" Make j and k go by wrapped lines when used individually, but by buffer lines
" if it has a number.
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')

" I like this color scheme
colorscheme slate
