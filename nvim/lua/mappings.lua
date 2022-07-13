local ops = { noremap = true, silent = true }

local function nnoremap(key, com) vim.keymap.set('n', key, com, ops) end
local function inoremap(key, com) vim.keymap.set('i', key, com, ops) end
local function map(key, com) vim.keymap.set({'n', 'n', 'o'}, key, com, ops) end

vim.api.nvim_create_user_command(
    'Rename', 
    function (...) vim.lsp.buf.rename() end,
    {}
)

vim.api.nvim_create_user_command(
    'Format', 
    function(...) vim.lsp.buf.formatting() end,
    {}
)

-- Ignore :W command
vim.api.nvim_create_user_command('W', 'w', { nargs = '*' })

-- Disable arrow keys
map("<F1>", function() end)
map("<Up>", function() end)
map("<Down>", function() end)
map("<Left>", function() end)
map("<Right>", function() end)

-- Leaders this fuckery is the only way I can get this to work for some reason
nnoremap("<Leader>t", "<Cmd>terminal<CR>")
nnoremap("<Leader>n", "<Cmd>bnext<CR>")
nnoremap("<Leader>b", "<Cmd>bprev<CR>")
nnoremap("<Leader>v", "<Cmd>bdelete<CR>")
nnoremap("<Leader>c", "<Cmd>Rg<CR>")
nnoremap("<Leader>r", vim.lsp.buf.rename)

-- Language commands
nnoremap("<F5>", function() require("runner").debug() end)
nnoremap("<F6>", function() require("runner").release() end)
nnoremap("<F7>", function() require("runner").test() end)
nnoremap("<F8>", function() require("runner").clean() end)

-- Best keymaps in vim
nnoremap("<Tab>", "<Cmd>Files<CR>")
inoremap("jj", "<Esc>")
