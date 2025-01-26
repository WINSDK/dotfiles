local set = vim.opt

set.syntax = "enable"
set.mouse = "a"
set.relativenumber = true
set.number = true
set.encoding = "utf-8"
set.history = 500
set.backspace = "indent,eol,start"
set.spell = true

set.synmaxcol = 500
set.clipboard:append("unnamedplus")
set.diffopt:append("iwhite")
set.shortmess:append("c")

set.laststatus = 3

set.cmdheight = 1

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

vim.cmd.colorscheme("gruvbox-material")

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.g.completion_matching_strategy_list = { "exact", "substring", "fuzzy" }
vim.g.mapleader = " "

-- Set filetype to cpp for .metal files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.metal",
  callback = function()
    vim.bo.filetype = "cpp"
  end
})

vim.api.nvim_create_autocmd("Filetype", {
  pattern = "*",
  callback = function()
    local filetype = vim.bo.filetype
    local sets = {
      python = { width = "80", tab = 4 },
      gitcommit = { width = "80", tab = 4 },
      markdown = { width = "80", tab = 4 },
      c = { width = "100", tab = 4 },
      cpp = { width = "100", tab = 4 },
      rust = { width = "100", tab = 4 },
      lua = { width = "100", tab = 2 },
      ocaml = { width = "100", tab = 2 },
      dune = { width = "100", tab = 1 },
      css = { width = "80", tab = 2 },
      html = { width = "80", tab = 1 },
    }

    if sets[filetype] then
      vim.opt.colorcolumn = sets[filetype].width
      vim.opt.tabstop = sets[filetype].tab
      vim.opt.shiftwidth = sets[filetype].tab
      vim.opt.softtabstop = sets[filetype].tab
    else
      vim.opt.colorcolumn = "100"
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.softtabstop = 4
    end
  end,
})
