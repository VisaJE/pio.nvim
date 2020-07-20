function! pio#InputPioEnv()
    let g:pio_env=input("Platformio environment: ")
    let g:statusextra = "[PIO] \uf06c ".g:pio_env." "
    call SetStatusLine()
endfunction

function! pio#GetPioEnv()
    if (!exists("g:pio_env"))
         call pio#InputPioEnv()
    endif
    return g:pio_env
endfunction

function! pio#SetMaps()
    nnoremap <leader>av :ProjectRootExe exec("!platformio run -e".pio#GetPioEnv())<CR>
    nnoremap <leader>au :ProjectRootExe exec("!platformio run -e".pio#GetPioEnv()." -t upload")<CR>
    function! OpenSerial()
        :vs | te
        :call jobsend(b:terminal_job_id, "cd ".g:pio_root." && clear\n")
        :call jobsend(b:terminal_job_id, "platformio device monitor\n")
    endfunction
    nnoremap <leader>as :call OpenSerial()<CR>
    nnoremap <leader>ac :call pio#InputPioEnv()<CR>
endfunction

function! pio#InitPlatformioProject(project_root, onPioCallback)
    if (filereadable(a:project_root.'/platformio.ini'))
        execute(a:onPioCallback)
        let g:pio_root = a:project_root
        let g:statusextra = "[PIO] "
        call SetStatusLine()
        call pio#SetMaps()
    endif
endfunction

