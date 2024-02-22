"
" A vimrc file which sets reasonable defaults and other things that I like
" Written by: Jarred Allen

" I like this color scheme
colorscheme slate

" Disable some VI-compatibility features
set nocompatible

" Disabling built-in filetype for autocomplete plugins to take over
filetype off

" Commands for running Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Vim plugins

" Local vimrc (have vimrc commands for a specific directory tree)
Plugin 'LucHermitte/lh-vim-lib'
Plugin 'LucHermitte/local_vimrc'

" Vim Surround (Provide nice options for surrounding things with parens,
" changing the parens around a thing, &c)
Plugin 'tpope/vim-surround'
" Vim Repeat (idk what it does, but it ain't broke, so I'm not fixing it)
Plugin 'tpope/vim-repeat'

" VimTeX (better functionality for editing latex in vim
Plugin 'lervag/vimtex'

" Vim Autoformat (automatically format files properly on write)
" Use `taplo` to format `.toml` files.
let g:formatdef_taplo = '"taplo fmt -"'
let g:formatters_toml = ['taplo']
" Load the plugin
Plugin 'vim-autoformat/vim-autoformat'

" JuliaEditorSupport plugin (do nice things with Julia)
Plugin 'JuliaEditorSupport/julia-vim'
" Enable autoreplacement of latex unicode specifiers
let g:latex_to_unicode_auto = 1
" Disable tab replacement of latex unicode specifiers (it breaks coc.nvim autocomplete)
" This is the default for Julia editors, but doesn't work here (see above for how)
let g:latex_to_unicode_tab = 0

" coc.nvim (autocompletion with Language Server Protocol)
Plugin 'neoclide/coc.nvim', {'branch': 'release'}

" Plugins to integrate better with git
" Git commands from within Vim
Plugin 'tpope/vim-fugitive'
" Diffs in the sidebar
Plugin 'airblade/vim-gitgutter'

" Finishing up Vundle
call vundle#end()

" Enable detection of filetype
filetype plugin on

" When not editing a tex file, the Tex command does nothing (when editing a
" tex file, definition comes from .vim/after/ftplugin/tex.vim).
command Tex :

" Automatically format files on write
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0
au BufWrite * :Autoformat

" Configuration options for coc.nvim
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
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

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
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

" Remember the position in the document when this file was last opened, and jump there
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Assign :W to be the same as :w (and :Wq as :wq), because I make that typo a lot
command W w
command Wq wq

" Assign :WS to writing with sudo (in case you edit a root file on accident)
command WS w !sudo tee %

" Better folding behavior by default
autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif

" Run command `:DiffSaved` to compare the current buffer to how it exists on disk
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

" Set colors in the sign bar:
highlight SignColumn ctermbg=NONE
highlight GitGutterAdd ctermfg=green ctermbg=NONE
highlight GitGutterChange ctermfg=magenta ctermbg=NONE
