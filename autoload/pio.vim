function! pio#InputPioEnv()
    let g:pio_env=input("Platformio environment: ")
    execute(s:pio_callback)
endfunction

function pio#PioFlags()
    let s:flags=" -e".pio#GetPioEnv()
    if (g:pio_verbose)
        let s:flags=s:flags." --verbose"
    endif
    return s:flags
endfunction

function! pio#GetPioEnv()
    if (!exists("g:pio_env"))
         call pio#InputPioEnv()
    endif
    return g:pio_env
endfunction

function! pio#Verify()
    ProjectRootExe exec("!platformio run".pio#PioFlags())
endfunction
function! pio#Upload()
    ProjectRootExe exec("!platformio run".pio#PioFlags()." -t upload")
endfunction

function! pio#OpenSerial()
    :vs | te
    :call jobsend(b:terminal_job_id, "cd ".g:pio_root." && clear\n")
    :call jobsend(b:terminal_job_id, "platformio device monitor\n")
endfunction

function! pio#InitPlatformioProject(project_root, onPioCallback)
    if (filereadable(a:project_root.'/platformio.ini'))
        let g:pio_verbose = 0
        let g:pio_root = a:project_root
        let s:pio_callback = a:onPioCallback
        execute(s:pio_callback)
    endif
endfunction
