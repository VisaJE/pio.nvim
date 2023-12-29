" Show a list for selection
function! pio#ShowSelect(title, args, callback)
  let winnr = bufwinnr(a:title)
  if(winnr>0)
    execute winnr.'wincmd w'
    setlocal noro modifiable
    execute '%d'
  else
    bo new
    execute 'silent file '.a:title
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    setlocal filetype=pio
    let b:toMap="nnoremap <buffer> <CR> :echo ".a:callback."(expand('<cWORD>'))<CR>:bd<CR>"
    execute(b:toMap)
  endif
  execute 'silent $read !'.g:pio_executable.a:args
  execute append(0,"Help: Select an entry by pressing [Enter]")
  setlocal ro nomodifiable
endfunction

" Called within ShowSelect
function! pio#SetEnv(pioEnv)
    let splitted=split(a:pioEnv, "env:")
    if (stridx(a:pioEnv, "env:") < 0)
        return
    endif
    let g:pio_env=splitted[0]
    execute(s:pio_callback)
endfunction

" Show a buffer to select environment
function! pio#SelectEnv()
    ProjectRootExe exec('call pio#ShowSelect("Environment", " project config | grep env:", "pio#SetEnv")')
endfunction

" Called within ShowSelect
function! pio#SetPort(port)
    if (!empty(glob(a:port)))
        let g:pio_port=a:port
        execute(s:pio_callback)
    endif
endfunction

" Show a buffer to select Port
function! pio#SelectPort()
    ProjectRootExe exec('call pio#ShowSelect("Port", " device list", "pio#SetPort")')
endfunction

" Additional options for all commands
function! pio#AddExtraFlags(flags)
    let s:extra_flags = s:extra_flags." ".a:flags
endfunction

function! pio#ClearExtraFlags(flags)
    let s:extra_flags = ""
endfunction

function pio#DbFlags()
    let s:flags=""
    if (g:pio_env != "")
        let s:flags=s:flags." -e".g:pio_env
    endif
    let s:flags=s:flags." ".s:extra_flags
    return s:flags
endfunction

function pio#VerifyFlags()
    let s:flags=""
    if (g:pio_env != "")
        let s:flags=s:flags." -e".g:pio_env
    endif
    let s:flags=s:flags." ".s:extra_flags
    return s:flags
endfunction

function pio#UploadFlags()
    let s:flags=""
    if (g:pio_env != "")
        let s:flags=s:flags." -e".g:pio_env
    endif
    if (g:pio_port != "")
        let s:flags=s:flags." --upload-port ".g:pio_port
    endif
    let s:flags=s:flags." ".s:extra_flags
    return s:flags
endfunction

function pio#SerialFlags()
    let s:flags=""
    if (g:pio_port != "")
        let s:flags=s:flags." --port ".g:pio_port
    endif
    let s:flags=s:flags." ".s:extra_flags
    return s:flags
endfunction

function! pio#CreateMakefile()
    if filereadable('Makefile')
        exe '!rm Makefile'
    endif
    let data=[
        \ "# CREATED BY PIO.NVIM",
        \ "all:",
        \ "\t".g:pio_executable." -f -c vim run".pio#VerifyFlags(),
        \ "",
        \ "upload:",
        \ "\t".g:pio_executable." -f -c vim run".pio#UploadFlags()." -t upload",
        \ "",
        \ "clean:",
        \ "\t".g:pio_executable." -f -c vim run -t clean",
        \ "",
        \ "program:",
        \ "\t".g:pio_executable." -f -c vim run".pio#UploadFlags()." -t program",
        \ "",
        \ "uploadfs:",
        \ "\t".g:pio_executable." -f -c vim run".pio#UploadFlags()." -t uploadfs",
        \ ]
    if writefile(data, 'Makefile')
        echomsg 'write error'
        return 1
    endif
    return 0
endfunction

function! pio#CompileDb()
    ProjectRootExe exec("!".g:pio_executable." run".pio#DbFlags(). " -tcompiledb")
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
        call jobsend(b:terminal_job_id, g:pio_executable." device monitor".pio#SerialFlags()."\n")
    else
        call jobsend(b:terminal_job_id, "Cd ".g:pio_root."\r")
        call jobsend(b:terminal_job_id, g:pio_executable." device monitor".pio#SerialFlags()."\r")
    endif
endfunction
