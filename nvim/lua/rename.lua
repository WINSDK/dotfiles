local M = {}
local uv = vim.uv or vim.loop

local function normalize(path)
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
end

local function ensure_dir(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

local function has_file(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= nil and name ~= ""
end

local function echo_ok(msg)
  vim.cmd("redraw")
  vim.api.nvim_echo({ { msg, "None" } }, false, {})
end

local function echo_err(msg)
  vim.cmd("redraw")
  vim.api.nvim_err_writeln(msg)
end

local function fail(msg)
  echo_err(msg)
  return false
end

local function dir_with_sep(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  local sep = package.config:sub(1, 1)
  if dir == "" or dir == "." then
    dir = vim.loop.cwd() or "."
  end
  if not dir:match(vim.pesc(sep) .. "$") then
    dir = dir .. sep
  end
  return dir
end

function M.rename_file(new_path)
  local buf = vim.api.nvim_get_current_buf()
  if not has_file(buf) then
    return fail("Current buffer is not visiting a file")
  end

  local old_path = normalize(vim.api.nvim_buf_get_name(buf))
  new_path = normalize(new_path or "")

  if new_path == "" then
    return fail("Provide a new path")
  end
  if old_path == new_path then
    echo_ok("No change")
    return true
  end

  ensure_dir(new_path)

  if vim.api.nvim_buf_get_option(buf, "modified") then
    vim.cmd.write()
  end

  if uv.fs_stat(new_path) then
    return fail("Target already exists: " .. new_path)
  end

  local ok, err = uv.fs_rename(old_path, new_path)
  if not ok then
    return fail("fs_rename failed: " .. tostring(err))
  end

  vim.api.nvim_buf_set_name(buf, new_path)
  vim.cmd.edit({ bang = true })
  echo_ok(("Renamed: %s -> %s"):format(old_path, new_path))
  return true
end

function M.prompt_rename()
  local cur = vim.api.nvim_buf_get_name(0)
  if cur == "" then
    return fail("Current buffer is not visiting a file")
  end
  cur = dir_with_sep(cur)
  vim.ui.input({ prompt = "New path: ", default = cur }, function(input)
    if not input or input == "" then
      return
    end
    local ok, err = pcall(M.rename_file, input)
    if not ok then
      echo_err(err)
    end
  end)
end

return M
