# Simple platformio wrappers for neovim
This plugin defines some convenient functions for platformio projects.

## An example of vimrc:
`
call plug#begin('~/.config/nvim/plugged')
Plug 'dbakker/vim-projectroot'
Plug 'VisaJE/pio.nvim'
call plug#end()

let g:rootmarkers=['platformio.ini', '.projectroot','.git','.hg',...]

function! SetPioMaps()
    nnoremap <space>av :call pio#Verify()<CR>
    nnoremap <space>au :call pio#Upload()<CR>
    nnoremap <space>as :call pio#OpenSerial()<CR>
    nnoremap <space>ac :call pio#SelectEnv()<CR>
    nnoremap <space>ap :call pio#SelectPort()<CR>
endfunction

autocmd FileType cpp,ino call pio#InitPlugin("call SetPioMaps()")
`

## Setup
* Depends on dbakker/vim-projectroot
1. Install platformio either to python3_host_prog environment
  or point to executable with  g:pio_executable.
1. Define your unique platformio setup in a callback
2. Call pio#InitPlugin(callback)

## Example usage
Open up main.cpp. Call `pio#SelectEnv()` to select an environment of listed
options. Call `pio#SelectPort()` to select output port for monitoring and
uploading. Call `pio#Upload()` to upload with :make, use `:copen<CR>` to open
up quickfixes if compilation fails. Finally, open up a serial monitor with
`pio#OpenSerial()`.
