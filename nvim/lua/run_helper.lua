local PLATFORM = (function() 
	local format = package.cpath:match("%p[\\|/]?%p(%a+)")
	if format == "dll" then
	  return "windows"
	elseif format == "so" then
	  return "linux"
	elseif format == "dylib" then
	  return "macos"
	end
end)()
local CMD_DELIM = (function()
	if PLATFORM == "windows" then
		return "\\"
	else
		return "/"
	end
end)()

local function get_platform_cmd()
	if PLATFORM == "windows" then
	  return "15 new | term://powershell"
	elseif PLATFORM == "linux" then
	  return "15 new | term://bash"
	elseif PLATFORM == "macos" then
	  return "15 new | term://zsh"
	end
end

local function cargo_run_target_exists(root) 
	if io.open(root .. CMD_DELIM .. "Cargo.toml", "r") then
		return true
	else
		return false
	end
end

--- C:/Users/.../Documents/Projects/main.rs => main.exe or main
local function abs_path_to_exec(str) 
	local pos = -1
	for idx = 1, #str do
		local char = str:sub(idx, idx)
		if char == CMD_DELIM then
			pos = idx
		end
	end

	if pos == -1 then
		print("failed to generate abs path")
		return
	end

	local str = str:sub(pos + 1, -4)
	if PLATFORM == "windows" then
		return str .. ".exe"
	else
		return str
	end
end

local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

local function open_term(cmd, insert_mode)
  -- default arguement
  insert_mode = insert_mode or false
  vim.cmd("15 new | term " .. cmd)
  if insert_mode then
    vim.cmd("startinsert")
  end
end

local comms = {}

-- FIXME: Required cuz of trying to call null values from vim
function comms.default()
	return {
		debug = function() end,
		release = function() end,
		test = function() end,
		clean = function() end,
	}
end

function comms.rust(path)
	local cargo_exists = cargo_run_target_exists(path)
	local file_path = vim.api.nvim_buf_get_name(0)
	local self = comms.default()

	local function rust_call(args)
		args = args or ""

		if file_path:sub(-6) == "lib.rs" then
			return
		end

		local rustc = "rustc " .. args ..  ' "' .. file_path .. '"' .. "&&" .. abs_path_to_exec(file_path)
		if file_path:sub(-3) == ".rs" then
      open_term(rustc, true)
		end
	end

	function self.release()
		if cargo_exists then
      open_term("cargo run --release", true)
		else
			rust_call("-C opt-level=3")
		end
	end

	function self.debug()
		if cargo_exists then
      open_term("cargo run", true)
		else
			rust_call()
		end
	end

	function self.clean()
		if cargo_exists then
      open_term("cargo clean")
		else
			if PLATFORM == "windows" then
				exe, pdb = file_path:sub(0, -4) .. ".exe", file_path:sub(0, -4) .. ".pdb"
				if os.remove(exe) and os.remove(pdb) then
					print("removed: " .. exe, ", " .. pdb)
				end
			else
				exe = file_path:sub(0, -4)
				if os.remove(file_path:sub(0, -4)) then
					print("removed: ", exe)
				end
			end
		end
	end

	function self.test()
		if cargo_exists then
      open_term("cargo test")
		end
	end

	return self
end

function comms.python(path)
 	local file_path = vim.api.nvim_buf_get_name(0)
 	local self = comms.default()

  local python_cmd = ""
  if executable("py") then
    python_cmd = "py"
  else
    python_cmd = "python3"
  end

	function self.debug() 
    open_term(python_cmd .. ' "' .. file_path .. '"', true)
	end

	return self
end

function comms.c(path)
	local self = comms.default()

  function self.debug()
    -- TODO: add makefile check etc
  end

  return self
end

return function(filetype)
	return comms[filetype](vim.fn.getcwd())
end
