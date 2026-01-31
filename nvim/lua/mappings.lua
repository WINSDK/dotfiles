local ops = { noremap = true, silent = true }

local function nnoremap(key, com) vim.keymap.set("n", key, com, ops) end
local function inoremap(key, com) vim.keymap.set("i", key, com, ops) end

vim.api.nvim_create_user_command("Make", function(opts)
  local cmd = opts.args ~= "" and ("make " .. opts.args) or "make"
  vim.cmd("botright split | resize 15 | terminal " .. cmd)
  vim.cmd("startinsert")
end, { nargs = "*", complete = "shellcmd" })

vim.api.nvim_create_user_command(
  "Format",
  function(...)
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

    if filetype == "ocaml" then
      if vim.fn.executable("dune") == 1 then
        vim.cmd("!dune fmt > /dev/null 2>&1")
      end
    else
      vim.lsp.buf.format({ async = true })
    end
  end,
  {}
)

vim.api.nvim_create_user_command(
  "Code",
  function (...) vim.lsp.buf.code_action() end,
  {}
)

-- Treat :W as :w command.
vim.api.nvim_create_user_command("W", "w", { nargs = "*" })

-- Disable arrow keys.
nnoremap("<F1>", function() end)
nnoremap("<Up>", function() end)
nnoremap("<Down>", function() end)
nnoremap("<Left>", function() end)
nnoremap("<Right>", function() end)

local function apply_action(title_or_prefix)
  vim.lsp.buf.code_action({
    apply  = true,
    filter = function(action) -- match exact title or prefix.
      local t = vim.fn.trim(action.title)
      return t == title_or_prefix or vim.startswith(t, title_or_prefix)
    end,
  })
end

nnoremap("<Leader>n", function()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype

  if ft ~= "c" and ft ~= "cpp" then
    return apply_action("Open ")
  end

  -- *.ipp *.hpp split.
  local path = vim.api.nvim_buf_get_name(buf)
  if path:match("%.hpp$") then
    local ipp = path:gsub("%.hpp$", ".ipp")
    if vim.fn.filereadable(ipp) == 1 then
      return vim.cmd("edit " .. vim.fn.fnameescape(ipp))
    end
  elseif path:match("%.ipp$") then
    local hpp = path:gsub("%.ipp$", ".hpp")
    if vim.fn.filereadable(hpp) == 1 then
      return vim.cmd("edit " .. vim.fn.fnameescape(hpp))
    end
  end

  vim.cmd("ClangdSwitchSourceHeader")
end)
nnoremap("<Leader>b", "<Cmd>Buffers<CR>")
nnoremap("<Leader>c", "<Cmd>Rg<CR>")
nnoremap("<Leader>f", vim.lsp.buf.format)
nnoremap("<Leader>r", vim.lsp.buf.rename)

-- Best keymaps in vim.
nnoremap("<Tab>", "<Cmd>Files<CR>")
inoremap("jj", "<Esc>")

-- Set bold border only on hover.
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = "bold"
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    nnoremap("~",  vim.diagnostic.open_float)
    nnoremap("`",  vim.lsp.buf.hover)
    nnoremap("gd", vim.lsp.buf.definition)
    nnoremap("gi", vim.lsp.buf.implementation)
    nnoremap("gt", vim.lsp.buf.type_definition)
    nnoremap("gr", vim.lsp.buf.references)
  end,
})
