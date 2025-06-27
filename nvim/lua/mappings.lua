local ops = { noremap = true, silent = true }

local function nnoremap(key, com) vim.keymap.set("n", key, com, ops) end
local function inoremap(key, com) vim.keymap.set("i", key, com, ops) end

vim.api.nvim_create_user_command(
  "Rename",
  function (...) vim.lsp.buf.rename() end,
  {}
)

vim.api.nvim_create_user_command(
  "Format",
  function(...)
      if vim.bo.filetype == "python" then
        if vim.fn.executable("autopep8") == 1 then
          vim.cmd("!autopep8 % --in-place")
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

-- Ignore :W command
vim.api.nvim_create_user_command("W", "w", { nargs = "*" })

-- Disable arrow keys
nnoremap("<F1>", function() end)
nnoremap("<Up>", function() end)
nnoremap("<Down>", function() end)
nnoremap("<Left>", function() end)
nnoremap("<Right>", function() end)

local function apply_action(title_or_prefix)
  vim.lsp.buf.code_action({
    apply  = true,
    filter = function(action) -- match exact title or prefix
      local t = vim.fn.trim(action.title)
      return t == title_or_prefix or vim.startswith(t, title_or_prefix)
    end,
  })
end

nnoremap("<Leader>n", function()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
  if filetype == "c" or filetype == "cpp" then
    vim.cmd("ClangdSwitchSourceHeader")
  else
    apply_action('Open ')
  end
end)
nnoremap("<Leader>b", "<Cmd>Buffers<CR>")
nnoremap("<Leader>c", "<Cmd>Rg<CR>")
nnoremap("<Leader>f", vim.lsp.buf.format)
nnoremap("<Leader>r", vim.lsp.buf.rename)

-- Best keymaps in vim
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
    nnoremap("gs", vim.lsp.buf.document_symbol)
    nnoremap("ge", vim.lsp.buf.declaration)
    nnoremap("gj", vim.lsp.buf.code_action)
  end,
})
