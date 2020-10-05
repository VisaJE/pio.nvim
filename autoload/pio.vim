function! pio#InputPioEnv()
    let g:pio_env=input("Platformio environment: ")
    execute(s:pio_callback)
endfunction

function! pio#AddExtraFlags(flags)
    let s:extra_flags = s:extra_flags." ".a:flags
endfunction

function! pio#ClearExtraFlags(flags)
    let s:extra_flags = ""
endfunction

function pio#PioFlags()
    let s:flags=" -e".pio#GetPioEnv()
    if (g:pio_verbose)
        let s:flags=s:flags." --verbose"
    endif
    let s:flags=s:flags." ".s:extra_flags
    return s:flags
endfunction

function! pio#GetPioEnv()
    if (!exists("g:pio_env"))
         call pio#InputPioEnv()
    endif
    return g:pio_env
endfunction

function! pio#CompileDb()
    ProjectRootExe exec("!".g:pio_executable." run".pio#PioFlags(). " -tcompiledb")
endfunction

function! pio#Verify()
    ProjectRootExe exec("!".g:pio_executable." run".pio#PioFlags())
endfunction
function! pio#Upload()
    ProjectRootExe exec("!".g:pio_executable." run".pio#PioFlags()." -t upload")
endfunction

function! pio#OpenSerial()
    vs | te
    if has("unix")
        call jobsend(b:terminal_job_id, "cd ".g:pio_root." && clear\n")
        call jobsend(b:terminal_job_id, g:pio_executable." device monitor\n")
    else
        call jobsend(b:terminal_job_id, "Cd ".g:pio_root."\r")
        call jobsend(b:terminal_job_id, g:pio_executable." device monitor\r")
    endif
endfunction

function! pio#InitPlatformioProject(project_root, onPioCallback)
    if (filereadable(a:project_root.'/platformio.ini'))
        if (!exists("g:pio_executable"))
            if (exists("g:python3_host_prog"))
                let g:pio_executable = g:python3_host_prog." -m platformio"
            else
                let g:pio_executable = "platformio"
            endif
        endif
        let g:pio_verbose = 0
        let s:extra_flags = ""
        let g:pio_root = a:project_root
        let s:pio_callback = a:onPioCallback
        execute(s:pio_callback)
    endif
endfunction
