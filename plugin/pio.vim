if exists('g:loaded_pio')
  finish
endif
let g:loaded_pio = 1

" Needs to be called in vimrc to detect platformio projects
function! pio#InitPlugin(onPioCallback)
    let g:pio_root = get(g:, "pio_root", ProjectRootGuess())
    if (filereadable(g:pio_root.'/platformio.ini'))
        if (!exists("g:pio_executable"))
            if (exists("g:python3_host_prog"))
                let g:pio_executable = g:python3_host_prog." -m platformio"
            else
                let g:pio_executable = "platformio"
            endif
        endif
        let s:extra_flags = get(s:, "extra_flags", "")
        let s:pio_callback = a:onPioCallback
        let g:pio_env= get(g:, "pio_env", "")
        let g:pio_port= get(g:, "pio_port", "")
        execute(s:pio_callback)
    endif
endfunction
