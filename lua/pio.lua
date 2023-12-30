local projects = {}
M = {}
M.active_project = nil

--------------------------------
-- PRIVATE
--------------------------------

local run_function_in_root = function(lua_function, ...)
	local current_cwd = vim.fn.getcwd()
	vim.fn.chdir(M.active_project.root)
	local result = lua_function(...)
	vim.fn.chdir(current_cwd)
	return result
end

-- Show a list for selection
local pio_show_select = function(title, args, callback)
	local winnr = vim.fn.bufwinnr(title)
	if winnr > 0 then
		vim.fn.execute(winnr .. "wincmd w")
		vim.opt_local.noro = "modifiable"
		vim.fn.execute("%d")
	else
		vim.fn.execute("bo new")
		vim.fn.execute("silent file " .. title)
		vim.opt_local.buftype = "nofile"
		vim.opt_local.bufhidden = "wipe"
		vim.opt_local.buflisted = false
		vim.opt_local.swapfile = false
		vim.opt_local.wrap = false
		vim.opt_local.filetype = "pio"
		vim.keymap.set("n", "<CR>", function()
			local current_word = vim.fn.expand("<cWORD>")
			vim.api.nvim_command("bdelete")
			callback(current_word)
		end, { buffer = true })
	end
	vim.fn.execute("silent $read !" .. vim.g.pio_executable .. args)
	vim.api.nvim_buf_set_lines(
		vim.api.nvim_get_current_buf(),
		0,
		0,
		true,
		{ "Help: Select an entry by pressing [Enter]" }
	)
	vim.opt_local.ro = true
	vim.opt_local.modifiable = false
end

local pio_set_env = function(pioEnv)
	local splitted = vim.split(pioEnv, "env:")
	if vim.fn.stridx(pioEnv, "env:") < 0 then
		return
	end
	M.active_project.pio_env = splitted[2]
	M.active_project.pio_on_update(M.active_project)
end

-- Show a buffer to select environment
function PioSelectEnv()
	run_function_in_root(pio_show_select, "Environment", " project config | grep env:", pio_set_env)
end

local pio_set_port = function(port)
	if port ~= "" then
		M.active_project.pio_port = port
		M.active_project.pio_on_update(M.active_project)
	end
end

-- Show a buffer to select Port
-- TODO: How to prevent selection outside ports
function PioSelectPort()
	run_function_in_root(pio_show_select, "Port", " device list", pio_set_port)
end

-- Additional options for all commands
function PioAddExtraFlags(flags)
	M.active_project.pio_extra_flags = M.active_project.pio_extra_flags .. " " .. flags
end

function PioClearExtraFlags()
	M.active_project.pio_extra_flags = ""
end

local pio_db_flags = function()
	local flags = ""
	if M.active_project.pio_env ~= "" then
		flags = flags .. " -e" .. M.active_project.pio_env
	end
	flags = flags .. " " .. M.active_project.pio_extra_flags
	return flags
end

local pio_verify_flags = function()
	local flags = ""
	if M.active_project.pio_env ~= "" then
		flags = flags .. " -e" .. M.active_project.pio_env
	end
	flags = flags .. " " .. M.active_project.pio_extra_flags
	return flags
end

local pio_upload_flags = function()
	local flags = ""
	if M.active_project.pio_env ~= "" then
		flags = flags .. " -e" .. M.active_project.pio_env
	end
	if M.active_project.pio_port ~= "" then
		flags = flags .. " --upload-port " .. M.active_project.pio_port
	end
	flags = flags .. " " .. M.active_project.pio_extra_flags
	return flags
end

local pio_serial_flags = function()
	local flags = ""
	if M.active_project.pio_port ~= "" then
		flags = flags .. " --port " .. M.active_project.pio_port
	end
	flags = flags .. " " .. M.active_project.pio_extra_flags
	return flags
end

local is_pio_project = function()
	local root = vim.fn["projectroot#guess"]()
	local pfile = root .. "/platformio.ini"
	return vim.fn.filereadable(pfile) == 1
end

local ensure_executable = function()
	if not (vim.g.pio_executable and vim.fn.exists("g:pio_executable") == 1) then
		if vim.g.python3_host_prog and vim.fn.exists(vim.g.python3_host_prog) then
			vim.g.pio_executable = vim.g.python3_host_prog .. " -m platformio"
		else
			vim.g.pio_executable = "platformio"
		end
	end
end

local set_active = function(root)
	if projects[root] then
		M.active_project = projects[root]
        M.active_project.pio_on_update(M.active_project)
	end
end

--------------------------------
-- PUBLIC INTERFACE
--------------------------------

function PioCreateMakefile()
	if vim.fn.filereadable("Makefile") == 1 then
		vim.fn.execute("!rm Makefile")
	end
	local data = {
		"# CREATED BY PIO.NVIM",
		"all:",
		"\t" .. vim.g.pio_executable .. " -f -c vim run" .. pio_verify_flags(),
		"",
		"upload:",
		"\t" .. vim.g.pio_executable .. " -f -c vim run" .. pio_upload_flags() .. " -t upload",
		"",
		"clean:",
		"\t" .. vim.g.pio_executable .. " -f -c vim run -t clean",
		"",
		"program:",
		"\t" .. vim.g.pio_executable .. " -f -c vim run" .. pio_upload_flags() .. " -t program",
		"",
		"uploadfs:",
		"\t" .. vim.g.pio_executable .. " -f -c vim run" .. pio_upload_flags() .. " -t uploadfs",
	}
	-- Open the file for writing
	local file = io.open("Makefile", "w")

	-- Check if the file is successfully opened
	if file then
		-- Write lines to the file
		for _, line in ipairs(data) do
			file:write(line, "\n")
		end
		-- Close the file
		file:close()
		return true
	else
		return false
	end
end

function PioCompileDb()
	local flags = pio_db_flags()
	vim.fn.ProjectRootExe({ "!" .. vim.g.pio_executable .. " run " .. flags .. " -tcompiledb" })
end

function PioVerify()
	vim.fn.ProjectRootExe({ "lua PioCreateMakefile()" })
	vim.fn.ProjectRootExe({ "!make" })
end

function PioUpload()
	vim.fn.ProjectRootExe({ "lua PioCreateMakefile()" })
	vim.fn.ProjectRootExe({ "!make upload" })
end

function PioOpenSerial()
	vim.fn.execute("vsplit | te")
	local id = vim.api.nvim_buf_get_option(0, "channel")
	vim.api.nvim_chan_send(
		id,
		"cd "
			.. M.active_project.root
			.. " && clear && "
			.. vim.g.pio_executable
			.. " device monitor"
			.. pio_serial_flags()
			.. "\n"
	)
end

-- Call every time a buffer is entered.
-- Vimscript backend works with global variables,
-- so to have correct environment settings one has to
-- set them every time.
M.on_enter = function()
	local root = vim.fn["projectroot#guess"]()
	set_active(root)
end

-- Call on new buffers to check if they
-- belong to a pio project. There will only
-- be a single update callback per project.
M.file_setup = function(updateCallback)
	if not is_pio_project() then
		return false
	end
	local root = vim.fn["projectroot#guess"]()
	if not projects[root] then
		ensure_executable()
		local project = {}
		project.pio_extra_flags = ""
		project.pio_env = ""
		project.pio_port = ""
		project.pio_on_update = updateCallback
		project.root = root
		projects[root] = project
	end
	if not M.active_project then
		set_active(root)
	end
	return true
end

return M
