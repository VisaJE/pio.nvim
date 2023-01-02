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
    let s:env=pio#GetPioEnv()
    let s:flags=""
    if (s:env != "")
        let s:flags=s:flags." -e".s:env
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

function! pio#CreateMakefile()
    if filereadable('Makefile')
        exe '!rm Makefile'
    endif
    let data=[
        \ "# CREATED BY PIO.NVIM",
        \ "all:",
        \ "\t".g:pio_executable." -f -c vim run".pio#PioFlags(),
        \ "",
        \ "upload:",
        \ "\t".g:pio_executable." -f -c vim run".pio#PioFlags()." -t upload",
        \ "",
        \ "clean:",
        \ "\t".g:pio_executable." -f -c vim run".pio#PioFlags()." -t clean",
        \ "",
        \ "program:",
        \ "\t".g:pio_executable." -f -c vim run".pio#PioFlags()." -t program",
        \ "",
        \ "uploadfs:",
        \ "\t".g:pio_executable." -f -c vim run".pio#PioFlags()." -t uploadfs",
        \ ]
    if writefile(data, 'Makefile')
        echomsg 'write error'
        return 1
    endif
    return 0
endfunction

function! pio#CompileDb()
    ProjectRootExe exec("!".g:pio_executable." run".pio#PioFlags(). " -tcompiledb")
endfunction

function! pio#Verify()
    ProjectRootExe exec("call pio#CreateMakefile() || !make")
endfunction

function! pio#Upload()
    ProjectRootExe exec("call pio#CreateMakefile() || !make upload")
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
        let s:extra_flags = ""
        let g:pio_root = a:project_root
        let s:pio_callback = a:onPioCallback
        execute(s:pio_callback)
    endif
endfunction
