-- Initialize in lua: return true if is platformio project

M = {}
M.setup = function()
	vim.g.pio_root = vim.g.pio_root or vim.fn["projectroot#guess"]()
	local pfile = vim.g.pio_root .. "/platformio.ini"
	if vim.fn.filereadable(pfile) == 1 then
		if not (vim.g.pio_executable and vim.fn.exists("g:pio_executable") == 1) then
			if vim.g.python3_host_prog and vim.fn.exists(vim.g.python3_host_prog) then
				vim.g.pio_executable = vim.g.python3_host_prog .. " -m platformio"
			else
				vim.g.pio_executable = "platformio"
			end
		end
		vim.g.pio_extra_flags = vim.pio_extra_flags or ""
		vim.g.pio_env = vim.g.pio_env or ""
		vim.g.pio_port = vim.g.pio_port or ""
		return true
	end
	return false
end

return M
