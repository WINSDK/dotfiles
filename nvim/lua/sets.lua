local set = vim.opt
set.rtp:append("~/.fzf")

set.syntax = "enable"
set.mouse = 'a'
set.relativenumber = true
set.number = true
set.encoding = "utf-8"
set.history = 500
set.backspace = "indent,eol,start"

set.synmaxcol = 500
set.clipboard:append("unnamedplus")
set.diffopt:append("iwhite")
set.shortmess:append("c")

vim.cmd("set laststatus=0 noshowmode noruler")

set.cmdheight = 1
set.guifont = "Hack Nerd Font:h15"

set.autoindent = true
set.smartindent = true
set.lazyredraw = true

set.ignorecase = true
set.smartcase = true
set.incsearch = true
set.hlsearch = true
set.scrolloff = 2
set.pumheight = 22

set.termguicolors = true

set.tabstop = 4
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true

set.gcr = "a:block-blinkon0"
set.updatetime = 1000
set.timeoutlen = 300

set.guicursor = "n-v-c:block"
set.inccommand = "nosplit"

vim.g.gruvbox_material_palette = "mix"
vim.g.gruvbox_material_sign_column_background = "none"
vim.g.gruvbox_material_disable_italic_comment = 1
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
set.background = "dark"
vim.cmd("colorscheme gruvbox-material")

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.g.completion_matching_strategy_list = { 'exact', 'substring', 'fuzzy' }
vim.g.mapleader = " "

vim.cmd("let fzf_layout = { 'down' : '~30%' }")

if vim.fn.executable('rg') then
  vim.g.rg_derive_root = true
  vim.cmd("let $FZF_DEFAULT_COMMAND = 'rg --files'")
  vim.cmd("let $FZF_DEFAULT_OPTS = '--reverse'")
end

if not vim.fn.has("gui_running") then
  vim.g.t_Co = 256
end

function colorcolumn()
  local filetype = vim.bo.filetype
  local choices = {
    c         = 80,
    cpp       = 80,
    python    = 80,
    gitcommit = 80,
    markdown  = 80,
    rust     = 100,
  }

  if choices[filetype] then
    set.colorcolumn = tostring(choices[filetype])
  end
end

vim.api.nvim_create_autocmd(
  "Filetype",
  { command = "lua colorcolumn()" }
)

vim.api.nvim_create_autocmd(
  "BufWinEnter",
  { command = [[call system("kitty @ --to=$KITTY_LISTEN_ON set-tab-title " . expand('%:t'))]] }
)

vim.api.nvim_create_autocmd(
  "VimLeave",
  { command = [[call system("kitty @ --to=$KITTY_LISTEN_ON set-tab-title fish")]] }
)
