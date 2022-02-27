local function nnoremap(k, c) vim.api.nvim_set_keymap('n', k, c, { noremap = true, silent = true }) end
local function inoremap(k, c) vim.api.nvim_set_keymap('i', k, c, { noremap = true, silent = true }) end
local function map(k, c) vim.api.nvim_set_keymap('', k, c, { noremap = true, silent = true }) end

-- LSP shorter mappings
vim.cmd([[command! Format lua vim.lsp.buf.formatting()]])
vim.cmd([[command! Rename lua vim.lsp.buf.rename()]])

-- Disable arrow keys
map("<F1>", "<Nop>")
map("<Up>", "<Nop>")
map("<Down>", "<Nop>")
map("<Left>", "<Nop>")
map("<Right>", "<Nop>")

-- Leaders this fuckery is the only way I can get this to work for some reason
nnoremap("<Leader>t", "<Cmd>terminal<CR>")
nnoremap("<Leader>n", "<Cmd>bnext<CR>")
nnoremap("<Leader>b", "<Cmd>bprev<CR>")
nnoremap("<Leader>v", "<Cmd>bdelete<CR>")
nnoremap("<Leader>c", "<Cmd>Rg<CR>")
nnoremap("<Leader>r", "<Cmd>lua vim.lsp.buf.rename()<CR>")

-- Language commands
nnoremap("<F5>", [[<Cmd>lua require("run_helper")(vim.bo.filetype).debug()<CR>  ]])
nnoremap("<F6>", [[<Cmd>lua require("run_helper")(vim.bo.filetype).release()<CR>]])
nnoremap("<F7>", [[<Cmd>lua require("run_helper")(vim.bo.filetype).test()<CR>   ]])
nnoremap("<F8>", [[<Cmd>lua require("run_helper")(vim.bo.filetype).clean()<CR>  ]])

-- Best keymaps in vim
nnoremap("<Tab>", "<Cmd>Files<CR>")
inoremap("jj", "<Esc>")
nnoremap(",", [[<Cmd>RustHoverActions<CR>]])
