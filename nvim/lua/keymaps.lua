local ops = { noremap = true, silent = true }

local function nnoremap(key, com) vim.keymap.set("n", key, com, ops) end
local function inoremap(key, com) vim.keymap.set("i", key, com, ops) end

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

  vim.cmd("LspClangdSwitchSourceHeader")
end)
nnoremap("<Leader>b", "<Cmd>Buffers<CR>")
nnoremap("<Leader>c", "<Cmd>Rg<CR>")
nnoremap("<Leader>r", vim.lsp.buf.rename)
nnoremap(
  "<Leader>f",
  function()
    require("conform").format({ async = true, lsp_fallback = true })
  end
)

-- Best keymaps in vim.
nnoremap("<Tab>", "<Cmd>Files<CR>")
inoremap("jj", "<Esc>")

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
