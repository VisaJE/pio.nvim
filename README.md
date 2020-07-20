# Simple platformio wrappers for neovim
This plugin defines some convenient functions for platformio projects.

## An example of vimrc:
`function! SetPioMaps()
    nnoremap <leader>av :call pio#Verify()<CR>
    nnoremap <leader>au :call pio#Upload()<CR>
    nnoremap <leader>as :call pio#OpenSerial()<CR>
    nnoremap <leader>ac :call pio#InputPioEnv()<CR>
endfunction

autocmd FileType cpp,ino call pio#InitPlatformioProject(projectroot#guess(), "call SetPioMaps() | call SetTabWidth(2) | call UpdateStatus()")
`

## Setup
* Depends on dbakker/vim-projectroot
1. Install via whatever. 
2. Define your unique platformio setup in a callback
2. Call pio#InitPlatformioProject(root, callback) with "root" pointing to the folder with platformio.ini 

